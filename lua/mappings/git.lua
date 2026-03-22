local map = vim.keymap.set

map("n", "]c", function()
  require("gitsigns").nav_hunk("next", { preview = false })
  require("gitsigns").preview_hunk_inline()
end, { desc = "GIT Preview next hunk" })

map("n", "[c", function()
  require("gitsigns").nav_hunk("prev", { preview = false })
  require("gitsigns").preview_hunk_inline()
end, { desc = "GIT Preview prev hunk" })

local function start_lazygit()
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.expand "%:p:h" .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then return end
  require("nvchad.term").toggle {
    id = "lazygit",
    pos = "float",
    float = {
      relative = "editor",
      row = 0.1,
      col = 0.045,
      width = 0.9,
      height = 0.8,
      border = "single",
    },
    size = 0.8,
    cmd = "lazygit -w " .. git_root .. " && exit",
    clear_cmd = true,
  }
end

map("n", "<leader>gg", start_lazygit, { desc = "Git Open Lazygit" })

map("n", "<leader>dd", function()
  vim.cmd "DiffOrig"
end, { desc = "Git buffer diff to write" })
