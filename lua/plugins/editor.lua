return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "diff",
          "python",
          "cpp",
          "lua",
          "markdown",
          "comment",
        },
        highlight = {
          enable = true,
        },
      }
    end,
  },

  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      { "<leader>sr", "<cmd>SessionSearch<CR>",         desc = "Session Search" },
      { "<leader>ss", "<cmd>AutoSession save<CR>",        desc = "Session Save" },
      { "<leader>st", "<cmd>SessionToggleAutoSave<CR>",  desc = "Session Toggle Autosave" },
      { "<leader>sd", "<cmd>SessionDelete<CR>",          desc = "Session Delete" },
    },
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      pre_save_cmds = {
        function()
          local ok, dapui = pcall(require, "dapui")
          if ok then pcall(dapui.close) end
        end,
      },
      session_lens = {
        picker = "telescope",
        load_on_setup = true,
        mappings = {
          delete_session    = { "i", "<C-d>" },
          alternate_session = { "i", "<C-s>" },
          copy_session      = { "i", "<C-y>" },
        },
        picker_opts = {
          border = true,
        },
      },
    },
  },

  {
    "0x00-ketsu/maximizer.nvim",
    config = function()
      require("maximizer").setup {}
    end,
  },
}
