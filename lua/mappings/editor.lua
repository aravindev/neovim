local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "<leader>x", function()
  local bufnr = vim.fn.bufnr()
  local windows = vim.fn.win_findbuf(bufnr)
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local buffers = vim.tbl_filter(function(buf)
    return buf.name ~= ""
  end, vim.fn.getbufinfo { buflisted = 1 })

  local leftmost_win = wins[1]
  for _, win in ipairs(wins) do
    if win < leftmost_win then
      leftmost_win = win
    end
  end
  if #windows == 1 and current_win == leftmost_win then
    if #buffers > 1 then
      vim.cmd "bp|bd #"
    else
      vim.cmd "bd"
    end
  elseif #windows > 1 then
    vim.cmd "close"
  else
    vim.cmd "bd"
  end
end, { noremap = true, silent = true, desc = "Close buffer or split" })

map({ "n", "i" }, "<F12>", function()
  require("maximizer").toggle()
end, { desc = "Maximizer Toggle" })

-- Copilot
map("i", "<C-Right>", "<Plug>(copilot-accept-word)", { desc = "Copilot Accept Word" })
map(
  "i",
  "<S-Right>",
  'copilot#Accept("\\<CR>")',
  { expr = true, replace_keycodes = false, desc = "Copilot Accept Line" }
)
vim.g.copilot_no_tab_map = true
