local map = vim.keymap.set

-- Search Everywhere (custom unified picker)
map("n", "<leader>fe", function()
  require("configs.search_everywhere")()
end, { desc = "Search Everywhere" })

map("n", "<leader>fq", function()
  require("telescope.builtin").resume()
end, { desc = "Telescope Resume" })

map("v", "<leader>fg", function()
  require("telescope.builtin").grep_string()
end, { desc = "Telescope Grep String" })

map("n", "<leader>fa", function()
  require("telescope.builtin").grep_string {
    shorten_path = true,
    word_match = "-w",
    only_sort_text = false,
    search = "",
    prompt_title = "Fuzzy Live Grep",
  }
end, { desc = "Telescope Fuzzy Search" })

-- UFO folding
map("n", "zR", function()
  require("ufo").openAllFolds()
end, { desc = "UFO Open All Folds" })

map("n", "zM", function()
  require("ufo").closeAllFolds()
end, { desc = "UFO Close All Folds" })

map("n", "zr", function()
  require("ufo").openFoldsExceptKinds()
end, { desc = "UFO Open Folds" })

map("n", "zm", function()
  require("ufo").closeFoldsWith()
end, { desc = "UFO Close Folds" })

-- Aerial
map("n", "<leader>a", function()
  require("aerial").toggle()
end, { desc = "Aerial Toggle" })
