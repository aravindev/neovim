local plugins = {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "mfussenegger/nvim-dap",
  },

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function(_, _)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup {
        commented = true,
        virt_text_pos = "eol",
        clear_on_continue = true,
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      require "nvim-dap-virtual-text"

      require("dapui").setup {
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.45 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.15 },
            },
            size = 0.25, -- 50% of total lines
            position = "left",
          },

          {
            elements = {
              { id = "repl", size = 0.3 },
              { id = "console", size = 0.7 },
            },
            size = 0.25, -- 50% of total cols
            position = "bottom",
          },
        },
      }

      dap.listeners.after.event_initialized.dapui_config = function()
        dapui.open()
      end
    end,
  },

  {
    "daic0r/dap-helper.nvim",
    lazy = false,
    dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap" },
    config = function()
      require("dap-helper").setup()
    end,
  },

  {
    "0x00-ketsu/maximizer.nvim",
    config = function()
      require("maximizer").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local opts = require "nvchad.configs.telescope"
      opts.defaults.path_display = { "truncate" }
      opts.defaults.layout_strategy = "vertical"
      return opts
    end,
  },
  {
    "nvim-telescope/telescope-dap.nvim",
    config = function()
      require("telescope").load_extension "dap"
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    lazy = false,
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    config = function()
      require("telescope").load_extension "fzf"
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
    "github/copilot.vim",
    lazy = false,
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "claude-3.7-sonnet", -- GPT model to use, 'gpt-3.5-turbo', 'gpt-4', or 'gpt-4o'
      mappings = {
        submit_prompt = {
          insert = "<C-CR>",
        },
      },
    },
    build = "make tiktoken",
    -- function()
    --   vim.notify "Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim."
    -- end,
    event = "VeryLazy",
    keys = {
      { "<leader>cct", ":CopilotChatToggle<cr>", desc = "CopilotChat - Toggle Chat" },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>ccd", "<cmd>CopilotChatDocs<cr>", desc = "CopilotChat - Generate doc" },
      { "<leader>cco", "<cmd>CopilotChatOptimize<cr>", desc = "CopilotChat - Optimize code" },
      { "<leader>cchf", "<cmd>CopilotChatFix<cr>", desc = "CopilotChat - Fix my code" },
      { "<leader>cchd", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Help with diagnostics" },
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

  -- treesitter with python configured
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
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        width = {
          min = 20,
          max = 40,
        },
      },
      modified = { enable = true, show_on_open_dirs = false },
    },
  },

  {
    "stevearc/aerial.nvim",
    lazy = false,
    opts = {},
    config = function()
      require("aerial").setup {
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
          "Object",
          -- "Variable",
        },
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      }
      -- You probably also want to set a keymap to toggle aerial
      vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
    end,
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { "<leader>sr", "<cmd>SessionSearch<CR>", desc = "Session search" },
      { "<leader>ss", "<cmd>SessionSave<CR>", desc = "Save session" },
      { "<leader>st", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
      { "<leader>sd", "<cmd>SessionDelete<CR>", desc = "Delete session" },
    },

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      -- ⚠️ This will only work if Telescope.nvim is installed
      -- The following are already the default values, no need to provide them if these are already the settings you want.
      session_lens = {
        -- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
        load_on_setup = true,
        previewer = false,
        mappings = {
          -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
          delete_session = { "i", "<C-D>" },
          alternate_session = { "i", "<C-S>" },
          copy_session = { "i", "<C-Y>" },
        },
        -- Can also set some Telescope picker options
        -- For all options, see: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
        theme_conf = {
          border = true,
          -- layout_config = {
          --   width = 0.8, -- Can set width and height as percent of window
          --   height = 0.5,
          -- },
        },
      },
    },
  },
  {
    "lewis6991/hover.nvim",
    lazy = false,
    config = function()
      require("hover").setup {
        init = function()
          -- Require providers
          require "hover.providers.lsp"
          -- require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          require "hover.providers.dap"
          require "hover.providers.diagnostic"
          -- require('hover.providers.man')
          -- require('hover.providers.dictionary')
        end,
        preview_opts = {
          border = "single",
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
        mouse_providers = {
          "LSP",
        },
        mouse_delay = 1000,
      }
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
    dependencies = { "rcarriga/cmp-dap" },
    config = function()
      require("blink.cmp").setup {
        enabled = function()
          return vim.api.nvim_get_option_value("buftype", {}) ~= "prompt" or require("cmp_dap").is_dap_buffer()
        end,
        sources = {
          per_filetype = {
            ["dap-repl"] = { "dap", score_offset = 200 },
            ["dapui_watches"] = { "dap", score_offset = 200 },
            ["dapui_hover"] = { "dap", score_offset = 200 },
          },
          providers = {
            dap = { name = "dap", module = "blink.compat.source" },
          },
        },
        completion = {
          ghost_text = {
            enabled = false,
          },
          list = {
            selection = {
              preselect = false,
            },
          },
        },
      }
    end,
  },
  {
    "rcarriga/cmp-dap",
    lazy = false,
    config = function() end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    event = "BufRead",
    config = function()
      -- Fold options
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- UFO folding
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      -- global handler
      -- `handler` is the 2nd parameter of `setFoldVirtTextHandler`,
      -- check out `./lua/ufo.lua` and search `setFoldVirtTextHandler` for detail.
      require("ufo").setup {
        fold_virt_text_handler = handler,
      }
    end,
  },
  -- test new blink
  { import = "nvchad.blink.lazyspec" },
}

return plugins
