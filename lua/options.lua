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
