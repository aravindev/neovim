return {
  {
    "github/copilot.vim",
    lazy = false,
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = "claude-haiku-4.5",
      temperature = 0.1,
      sticky = { "#selection" },
      window = {
        layout = "vertical",
        width = 0.5,
      },
      separator = "━━",
      auto_fold = true, -- Automatically folds non-assistant messages
      mappings = {
        submit_prompt = {
          insert = "<C-CR>",
        },
      },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.conceallevel = 0
        end,
      })
      vim.api.nvim_set_hl(0, "CopilotChatHeader", { fg = "#7CFFFF", bold = true })
      vim.api.nvim_set_hl(0, "CopilotChatSeparator", { fg = "#374151" })
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>cct", ":CopilotChatToggle<cr>",    desc = "CopilotChat - Toggle Chat" },
      { "<leader>ccT", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      {
        "<leader>ccq",
        function()
          local input = vim.fn.input "Quick Chat: "
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
    },
  },
}
