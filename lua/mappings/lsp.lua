local map = vim.keymap.set

-- Basic LSP mappings
map("n", "<leader>rn", vim.lsp.buf.rename,      { desc = "Rename Symbol" })
map("n", "<leader>gd", vim.lsp.buf.definition,  { desc = "Goto Definition" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>fc", vim.lsp.buf.format,      { desc = "Format Code" })

-- Diagnostics
map("n", "]d", function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = "LSP Next Diagnostic" })

map("n", "[d", function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = "LSP Previous Diagnostic" })

map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "LSP Toggle Diagnostics" })

map("n", "<leader>sw", function()
  local bufname = vim.fn.expand "%:p:h"
  vim.lsp.buf.add_workspace_folder(bufname)
end, { desc = "LSP Add Workspace Folder" })

-- Telescope LSP
map("n", "<leader>f?", function()
  require("telescope.builtin").diagnostics { layout_strategy = "vertical" }
end, { desc = "Telescope LSP Diagnostics" })

map("n", "<leader>fr", function()
  require("telescope.builtin").lsp_references { layout_strategy = "vertical" }
end, { desc = "Telescope LSP References" })

map("n", "<leader>fd", function()
  require("telescope.builtin").lsp_definitions { layout_strategy = "vertical" }
end, { desc = "Telescope LSP Definitions" })

map("n", "<leader>fs", function()
  require("telescope.builtin").lsp_dynamic_workspace_symbols { layout_strategy = "vertical" }
end, { desc = "Telescope LSP Workspace Symbols" })

-- Provider memory: remember the last K-selected provider per buffer.
-- Stores { id, module } so it works for both cycling (id) and mouse filtering (module).
-- Mouse hover is excluded to avoid overwriting the keyboard selection.
local _hover_provider_memory = {} -- [bufnr] -> { id, module }
local _keyboard_hover_bufs = {}   -- [bufnr] -> true when last hover was keyboard-triggered

local function get_provider_module(provider_id)
  local ok, providers = pcall(require, "hover.providers")
  if not ok then return nil end
  for _, p in ipairs(providers.providers) do
    if p.id == provider_id then return p.module end
  end
end

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(args)
    local winid = tonumber(args.match)
    if not winid then return end
    local provider_id = vim.w[winid] and vim.w[winid].hover_provider
    if not provider_id then return end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
        and vim.b[buf].hover_preview == winid
        and _keyboard_hover_bufs[buf]
      then
        _hover_provider_memory[buf] = {
          id = provider_id,
          module = get_provider_module(provider_id),
        }
        _keyboard_hover_bufs[buf] = nil
        break
      end
    end
  end,
})

local function cycle_to_provider(bufnr, target_id, attempts)
  if attempts <= 0 then return end
  vim.defer_fn(function()
    local win = vim.b[bufnr] and vim.b[bufnr].hover_preview
    if not (win and vim.api.nvim_win_is_valid(win)) then
      cycle_to_provider(bufnr, target_id, attempts - 1)
      return
    end
    if vim.w[win].hover_provider == target_id then return end
    require("hover").hover()
    cycle_to_provider(bufnr, target_id, attempts - 1)
  end, 200)
end

map("n", "K", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local hover_win = vim.b[bufnr].hover_preview
  local is_open = hover_win and vim.api.nvim_win_is_valid(hover_win)
  _keyboard_hover_bufs[bufnr] = true
  require("hover").hover()
  if not is_open then
    local memory = _hover_provider_memory[bufnr]
    if memory then
      cycle_to_provider(bufnr, memory.id, 8)
    end
  end
end, { desc = "hover.nvim" })

-- Mouse hover disabled to avoid interference with K hover
-- vim.o.mousemoveevent = true
