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
    float_opts = {
      relative = "editor",
      row = 0.01,
      col = 0.01,
      width = 0.98,
      height = 0.95,
      border = "single",
    },
    size = 0.95,
    cmd = "lazygit -w " .. git_root .. " && exit",
    clear_cmd = true,
  }

  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_create_autocmd("TermClose", {
    buf = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })
end

map("n", "<leader>gg", start_lazygit, { desc = "GIT Open Lazygit" })

map("n", "<leader>dd", function()
  vim.cmd "DiffOrig"
end, { desc = "GIT Buffer diff to write" })

map("n", "<leader>gh", function()
  vim.cmd "DiffviewFileHistory %"
end, { desc = "GIT File history" })

map("n", "<leader>gH", function()
  require("git_utils").open_file_at_commit()
end, { desc = "GIT Open file at commit" })

map("n", "<leader>gD", function()
  require("git_utils").diff_with_ref()
end, { desc = "GIT Diff with branch/commit" })
