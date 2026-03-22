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

-- Diagnostics: wrap long virtual lines to window width
-- See https://www.reddit.com/r/neovim/comments/1jstr7z/how_to_wrap_diagnostic_virtual_lines/

local function buf_to_win(bufnr)
  local current_win = vim.fn.win_getid()
  if vim.fn.winbufnr(current_win) == bufnr then
    return current_win
  end
  local win_ids = vim.fn.win_findbuf(bufnr)
  local current_tabpage = vim.fn.tabpagenr()
  for _, win_id in ipairs(win_ids) do
    if vim.fn.win_id2tabwin(win_id)[1] == current_tabpage then
      return win_id
    end
  end
  return current_win
end

local function split_line(str, max_width)
  if #str <= max_width then
    return { str }
  end
  local lines = {}
  local current_line = ""
  for word in string.gmatch(str, "%S+") do
    if #current_line + #word + 1 > max_width then
      table.insert(lines, current_line)
      current_line = word
    else
      current_line = current_line ~= "" and (current_line .. " " .. word) or word
    end
  end
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
  orig_diagnostic_config()
  vim.diagnostic.config {
    virtual_text = false,
    virtual_lines = { format = virtual_lines_format },
    severity_sort = { reverse = false },
  }
end

-- Re-draw diagnostics on line change to account for virtual line wrapping
local last_line = vim.fn.line "."

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    local current_line = vim.fn.line "."
    if current_line ~= last_line then
      vim.diagnostic.hide()
      vim.diagnostic.show()
    end
    last_line = current_line
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.diagnostic.hide()
    vim.diagnostic.show()
  end,
})

-- NvimTree: auto-reveal current file in the tree
local nvim_tree_api = require "nvim-tree.api"

vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if vim.fn.bufname() == "NvimTree_1" then
      return
    end
    nvim_tree_api.tree.find_file { buf = vim.fn.bufnr() }
  end,
})

-- NvimTree: transparent background for readability
vim.cmd [[hi NvimTreeNormal guibg=NONE ctermbg=NONE]]
vim.cmd [[hi NvimTreeNormalNC guibg=NONE ctermbg=NONE]]

-- MRU buffer ordering in tabufline
require "configs.buf_order"
