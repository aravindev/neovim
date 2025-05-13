require "nvchad.options"

-- add yours here!

-- local o = vim.o
vim.o.cursorlineopt = "both" -- to enable cursorline!
vim.o.wrap = true
vim.o.undofile = true
vim.cmd [[command! DiffOrig if &diff | diffupdate | else | vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis | wincmd p | set wrap | endif]]

-- Code naviation using Ctrl-I/O. Avoid removing deleted buffers from jumplist (https://github.com/neovim/neovim/issues/25365)
vim.o.jumpoptions = ""

-- folding https://essais.co/better-folding-in-neovim/

vim.o.foldmethod = "indent"
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.opt.fillchars = { fold = "\\" } -- The backslash escapes a space
vim.o.foldtext = "CustomFoldText()"
function CustomFoldText()
  local indentation = vim.fn.indent(vim.v.foldstart - 1)
  local foldSize = 1 + vim.v.foldend - vim.v.foldstart
  local foldSizeStr = " " .. foldSize .. " lines "
  local foldLevelStr = string.rep("+--", vim.v.foldlevel)
  local expansionString = string.rep(" ", indentation)
  return expansionString .. foldLevelStr .. foldSizeStr
end

-- Show Nvdash home screen when all buffers are closed
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})

-- Git

vim.schedule(function()
  require("gitsigns").setup {
    numhl = true,
  }
end)

-- Set the workspace folders for COPILOT
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    local cwd = vim.fn.getcwd() -- Use getcwd to get the current working directory
    vim.g.copilot_workspace_folders = { cwd } -- Set it to a list with the current directory
  end,
})

-- See https://www.reddit.com/r/neovim/comments/1jstr7z/how_to_wrap_diagnostic_virtual_lines/
-- start of diagnostics config
-- Get the window id for a buffer
-- @param bufnr integer
local function buf_to_win(bufnr)
  local current_win = vim.fn.win_getid()

  -- Check if current window has the buffer
  if vim.fn.winbufnr(current_win) == bufnr then
    return current_win
  end

  -- Otherwise, find a visible window with this buffer
  local win_ids = vim.fn.win_findbuf(bufnr)
  local current_tabpage = vim.fn.tabpagenr()

  for _, win_id in ipairs(win_ids) do
    if vim.fn.win_id2tabwin(win_id)[1] == current_tabpage then
      return win_id
    end
  end

  return current_win
end

-- Split a string into multiple lines, each no longer than max_width
-- The split will only occur on spaces to preserve readability
-- @param str string
-- @param max_width integer
local function split_line(str, max_width)
  if #str <= max_width then
    return { str }
  end

  local lines = {}
  local current_line = ""

  for word in string.gmatch(str, "%S+") do
    -- If adding this word would exceed max_width
    if #current_line + #word + 1 > max_width then
      -- Add the current line to our results
      table.insert(lines, current_line)
      current_line = word
    else
      -- Add word to the current line with a space if needed
      if current_line ~= "" then
        current_line = current_line .. " " .. word
      else
        current_line = word
      end
    end
  end

  -- Don't forget the last line
  if current_line ~= "" then
    table.insert(lines, current_line)
  end

  return lines
end

---@param diagnostic vim.Diagnostic
local function virtual_lines_format(diagnostic)
  local win = buf_to_win(diagnostic.bufnr)
  local sign_column_width = vim.fn.getwininfo(win)[1].textoff
  local text_area_width = vim.api.nvim_win_get_width(win) - sign_column_width
  local center_width = 5
  local left_width = 1

  ---@type string[]
  local lines = {}
  for msg_line in diagnostic.message:gmatch "([^\n]+)" do
    local max_width = text_area_width - diagnostic.col - center_width - left_width
    vim.list_extend(lines, split_line(msg_line, max_width))
  end

  return table.concat(lines, "\n")
end

local orig_diagnostic_config = require("nvchad.lsp").diagnostic_config

-- Override the diagnostic_config function from nvchad
-- see: https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/lsp/init.lua
require("nvchad.lsp").diagnostic_config = function()
  -- Call the original function first
  orig_diagnostic_config()
  -- Then apply your own settings to override
  vim.diagnostic.config {
    virtual_text = false, -- Disable virtual text
    virtual_lines = { format = virtual_lines_format },
    severity_sort = { reverse = false },
  }
end

-- Re-draw diagnostics each line change to account for virtual_text changes

local last_line = vim.fn.line "."

vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  callback = function()
    local current_line = vim.fn.line "."

    -- Check if the cursor has moved to a different line
    if current_line ~= last_line then
      vim.diagnostic.hide()
      vim.diagnostic.show()
    end

    -- Update the last_line variable
    last_line = current_line
  end,
})

-- Re-render diagnostics when the window is resized

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.diagnostic.hide()
    vim.diagnostic.show()
  end,
})

-- end of diagnostics config
