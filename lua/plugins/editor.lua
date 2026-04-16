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
          local ok_dap, dap = pcall(require, "dap")
          if ok_dap then pcall(dap.terminate) end
          local ok_ui, dapui = pcall(require, "dapui")
          if ok_ui then pcall(dapui.close) end
          -- Wipe terminal buffers: sessions can't restore `buftype=terminal`
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf)
              and vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal" then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
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
