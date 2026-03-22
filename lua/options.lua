require "nvchad.options"

vim.o.cursorlineopt = "both"
vim.o.wrap = true
vim.o.undofile = true
vim.o.jumpoptions = "" -- preserve jumplist for Ctrl-I/O across deleted buffers

vim.cmd [[command! DiffOrig if &diff | diffupdate | else | vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis | wincmd p | set wrap | endif]]
