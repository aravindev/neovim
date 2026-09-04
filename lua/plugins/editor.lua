return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require "nvim-treesitter"
      ts.setup()

      local ensure_installed = {
        "diff",
        "python",
        "cpp",
        "lua",
        "markdown",
        "markdown_inline",
        "comment",
        "luadoc",
        "printf",
      }
      local installed = ts.get_installed "parsers"
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang and vim.treesitter.language.add(lang) then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })
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
