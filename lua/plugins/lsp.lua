return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    init = function(_)
      local packages = {
        "lua-language-server",
        "stylua",
        -- "ruff-lsp",
        -- "flake8",
        "pyright",
        "black",
        "isort",
        "debugpy",
      }
      for _, package in ipairs(packages) do
        local registry = require "mason-registry"
        registry.refresh(function()
          local pkg = registry.get_package(package)
          if not pkg:is_installed() then
            pkg:install()
          end
        end)
      end
    end,
  },

  {
    "lewis6991/hover.nvim",
    lazy = false,
    config = function()
      require("hover").setup {
        providers = {
          "hover.providers.lsp",
          "hover.providers.diagnostic",
          "configs.hover_dap", -- custom: uses session:evaluate() for clean repr-like view
        },
        preview_opts = {
          border = "single",
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
      }

      -- Enforce minimum popup width so the provider title bar is always readable.
      -- WinResized is needed because the DAP provider resizes async after evaluation.
      local function enforce_hover_min_width()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) and vim.w[win].hover_preview then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative ~= "" and cfg.width and cfg.width < 40 then
              vim.api.nvim_win_set_config(win, { width = 40 })
            end
          end
        end
      end
      vim.api.nvim_create_autocmd({ "WinNew", "WinResized" }, {
        callback = vim.schedule_wrap(enforce_hover_min_width),
      })

      -- Suppress hover windows that show no useful content.
      -- Uses defer_fn (not schedule_wrap) so hover.nvim's own scheduled callbacks
      -- (e.g. foldenable) run first and avoid "Invalid window id" errors.
      local _empty_results = { ["No result"] = true, ["empty"] = true }
      vim.api.nvim_create_autocmd("WinNew", {
        callback = function()
          vim.defer_fn(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_win_is_valid(win) and vim.w[win].hover_preview then
                local buf = vim.api.nvim_win_get_buf(win)
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                if #lines == 1 and _empty_results[lines[1]] then
                  vim.api.nvim_win_close(win, true)
                end
              end
            end
          end, 10)
        end,
      })
    end,
  },

  {
    -- from https://www.reddit.com/r/neovim/comments/1hneftb/get_completions_in_daprepl_buffer_with_blinkcmp/
    -- required by rcarriga/cmp-dap for compatibility
    "saghen/blink.compat",
    version = "*",
    lazy = true,
    opts = {},
  },

  {
    "Saghen/blink.cmp",
    dependencies = { { "rcarriga/cmp-dap" }, { "micangl/cmp-vimtex" } },
    opts = {
      sources = {
        providers = {
          path = {
            enabled = function()
              return vim.bo.filetype ~= "copilot-chat"
            end,
          },
        },
      },
    },
    config = function()
      require("blink.cmp").setup {
        enabled = function()
          return vim.api.nvim_get_option_value("buftype", {}) ~= "prompt" or require("cmp_dap").is_dap_buffer()
        end,
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "vimtex" },
          per_filetype = {
            ["dap-repl"]      = { "dap", score_offset = 200 },
            ["dapui_watches"] = { "dap", score_offset = 200 },
            ["dapui_hover"]   = { "dap", score_offset = 200 },
          },
          providers = {
            lsp     = { min_keyword_length = 1, score_offset = 100 },
            dap     = { name = "dap",     module = "blink.compat.source" },
            vimtex  = { name = "vimtex",  module = "blink.compat.source", score_offset = 3 },
            path    = {
              enabled = function()
                return vim.bo.filetype ~= "copilot-chat"
              end,
            },
          },
        },
        completion = {
          ghost_text = { enabled = false },
          list = {
            selection = { preselect = false },
          },
        },
        keymap = {
          ["<Tab>"]   = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
          ["<CR>"]    = { "accept", "fallback" },
        },
      }
    end,
  },

  {
    "rcarriga/cmp-dap",
    config = function() end,
  },

  -- NvChad blink spec + disabled NvChad defaults (replaced by blink.cmp)
  { import = "nvchad.blink.lazyspec" },
  { "L3MON4D3/LuaSnip",                enabled = false },
  { "rafamadriz/friendly-snippets",     enabled = false },
  { "windwp/nvim-autopairs",            enabled = false },
}
