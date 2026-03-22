-- Multiline input float for dap-repl.
-- <S-CR> in dap-repl opens a scratch buffer with source context prepended as
-- comments so Copilot has meaningful context. <C-CR> executes, <Esc>/q discards.

local M = {}

local type_to_ft = {
  python   = "python",
  cppdbg   = "cpp",
  codelldb = "cpp",
}

local CONTEXT_LINES = 20  -- lines above/below current frame to include

local function comment_prefix(ft)
  if ft == "python" then return "# "
  elseif ft == "cpp" or ft == "c" then return "// "
  else return "# "
  end
end

local function build_context_block(ft)
  local ok, dap = pcall(require, "dap")
  if not ok then return {} end
  local session = dap.session()
  if not session then return {} end

  local frame = session.current_frame
  if not frame or not frame.source or not frame.source.path then return {} end

  local path = frame.source.path
  local center = frame.line or 1
  local first = math.max(1, center - CONTEXT_LINES)
  local last  = center + CONTEXT_LINES

  local file = io.open(path, "r")
  if not file then return {} end

  local prefix = comment_prefix(ft)
  local lines = {}
  local n = 0
  for raw in file:lines() do
    n = n + 1
    if n >= first and n <= last then
      local marker = (n == center) and ">>>" or "   "
      table.insert(lines, prefix .. marker .. " " .. raw)
    end
    if n > last then break end
  end
  file:close()

  if #lines == 0 then return {} end

  local header = prefix .. "--- context: " .. vim.fn.fnamemodify(path, ":~:.") .. " ---"
  local footer = prefix .. "--- end context ---"
  local block = { header }
  vim.list_extend(block, lines)
  table.insert(block, footer)
  table.insert(block, "")  -- blank line before cursor
  return block
end

local function close_wins(wins)
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_close(w, true)
    end
  end
end

function M.open()
  local dap = require "dap"
  if not dap.session() then
    vim.notify("No active DAP session", vim.log.levels.WARN)
    return
  end

  local adapter_type = dap.session().config.type or ""
  local ft = type_to_ft[adapter_type] or "text"

  -- Dimensions
  local ui_width  = vim.o.columns
  local ui_height = vim.o.lines
  local width     = math.floor(ui_width * 0.6)
  local height    = math.floor(ui_height * 0.4)
  local row       = math.floor((ui_height - height) / 2) - 1
  local col       = math.floor((ui_width  - width)  / 2)

  -- Main scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype  = ft
  vim.bo[buf].buftype   = "nofile"
  vim.bo[buf].swapfile  = false

  local context = build_context_block(ft)
  if #context > 0 then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, context)
  end

  local main_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width    = width,
    height   = height,
    row      = row,
    col      = col,
    style    = "minimal",
    border   = "rounded",
    title    = " DAP multiline input (" .. ft .. ") ",
    title_pos = "center",
  })

  -- Hint bar directly below the main float
  local hint_buf = vim.api.nvim_create_buf(false, true)
  local hint_text = "  <CR> / <C-CR> execute    q / <Esc> discard  "
  vim.api.nvim_buf_set_lines(hint_buf, 0, -1, false, { hint_text })
  vim.bo[hint_buf].modifiable = false

  local hint_win = vim.api.nvim_open_win(hint_buf, false, {
    relative  = "editor",
    width     = width,
    height    = 1,
    row       = row + height + 1,  -- just below the rounded border
    col       = col,
    style     = "minimal",
    border    = "none",
    focusable = false,
  })
  vim.api.nvim_set_option_value("winhl", "Normal:Comment", { win = hint_win })

  local wins = { main_win, hint_win }

  -- Move cursor to first editable line (after context block)
  local context_end = #context  -- last line of context block (1-indexed)
  vim.api.nvim_win_set_cursor(main_win, { math.max(1, context_end), 0 })
  vim.cmd "startinsert"

  local function execute_and_close()
    local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    -- User input starts at the line where the cursor was placed (#context, 1-indexed).
    -- The blank separator is that line; the user overwrites it when typing.
    local start = (#context > 0) and #context or 1
    local input_lines = vim.list_slice(all_lines, start)
    -- Strip trailing blank lines
    while #input_lines > 0 and input_lines[#input_lines]:match "^%s*$" do
      table.remove(input_lines)
    end
    close_wins(wins)
    if #input_lines == 0 then return end

    local repl = require "dap.repl"
    if #input_lines == 1 then
      repl.execute(input_lines[1])
    else
      -- Execute the block (assignments, defs, etc.) first, then the last line
      -- separately so its return value is captured and shown in the REPL.
      -- (debugpy uses exec() for multiline blocks which discards expression values)
      local block = table.concat(vim.list_slice(input_lines, 1, #input_lines - 1), "\n")
      local last  = input_lines[#input_lines]
      repl.execute(block)
      vim.defer_fn(function() repl.execute(last) end, 50)
    end
  end

  local function discard_and_close()
    close_wins(wins)
  end

  local opts = { buffer = buf, nowait = true }
  vim.keymap.set({ "n", "i" }, "<C-CR>", execute_and_close, opts)
  vim.keymap.set("n",          "<CR>",   execute_and_close, opts)
  -- <Esc> in insert mode → normal mode (default vim, do NOT discard)
  -- <Esc>/<q> in normal mode → discard
  vim.keymap.set("n", "<Esc>", discard_and_close, opts)
  vim.keymap.set("n", "q",     discard_and_close, opts)
end

return M
