require "nvchad.options"

vim.o.cursorlineopt = "both"
vim.o.wrap = true
vim.o.undofile = true
vim.o.jumpoptions = "" -- preserve jumplist for Ctrl-I/O across deleted buffers
vim.o.exrc = true -- load workspace-local .nvim.lua (run :trust once per file)
if vim.env.SHELL == nil or vim.env.SHELL == "/bin/sh" then
  vim.o.shell = "bash"
end

-- Use OSC 52 for clipboard, but only when there is no local X/Wayland clipboard to talk to.
local has_local_clipboard = (vim.env.DISPLAY or vim.env.WAYLAND_DISPLAY) ~= nil
if vim.env.SSH_TTY ~= nil or not has_local_clipboard then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy "+",
      ["*"] = require("vim.ui.clipboard.osc52").copy "*",
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste "+",
      ["*"] = require("vim.ui.clipboard.osc52").paste "*",
    },
  }
end

-- Treat C++ template implementation files (.tpp) as cpp, ROS .launch as xml.
vim.filetype.add { extension = { tpp = "cpp", launch = "xml" } }

vim.cmd [[command! DiffOrig if &diff | diffupdate | else | vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis | wincmd p | set wrap | endif]]
