-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "github_dark",

  hl_override = {
    -- lighten or darken base46 theme variable
    -- this will use the black color from base46.theme & lighten it by 2x
    -- negative number will darken it
    Normal = {
      bg = { "black", -40 },
    },
    -- For floating terminal background
    NormalFloat = {
      bg = { "black", -30 },
    },
    -- Fix NvimTree colors
    NvimTreeNormal = {
      bg = { "black", -50 },
      fg = { "white", 10 },
    },
    NvimTreeNormalNC = {
      bg = { "black", -50 },
      fg = { "white", 10 },
    },
    NvimTreeWinSeparator = {
      fg = { "grey", 0 },
      bg = { "black", -35 },
    },
  },
}

M.term = {
  -- hl = "Normal:term,WinSeparator:WinSeparator",
  -- sizes = { sp = 0.3, vsp = 0.2 },
  float = {
    relative = "editor",
    row = 0.1,
    col = 0.045,
    width = 0.9,
    height = 0.8,
    border = "single",
  },
}
local function shorten_path(path)
  local max_len = 100
  if #path > max_len then
    local first = path:sub(1, 1)
    local last = path:sub(-max_len + 5) -- Keep more of the end
    return first .. "..." .. last
  end
  return path
end
M.nvdash = { load_on_startup = true }
M.ui = {
  statusline = {
    -- From here: https://github.com/NvChad/ui/blob/v2.5/lua/nvchad/stl/utils.lua#L12
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "folder", "cwd", "cursor" },
    modules = {
      folder = function()
        local path = vim.fn.expand "%:p:h"
        if path == "" then
          path = "%#St_file_info#" .. "[No Name]" .. "%#St_file_sep#"
        end
        path = shorten_path(path)
        return "%#St_file_info#" .. path .. "%#St_file_sep#"
      end,
    },
  },
  tabufline = {
    lazyload = false,
  },
}

return M
