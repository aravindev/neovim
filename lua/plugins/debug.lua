return {
  { "mfussenegger/nvim-dap" },

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
              { id = "scopes",      size = 0.45 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.15 },
            },
            size = 0.25,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.3 },
              { id = "console", size = 0.7 },
            },
            size = 0.25,
            position = "bottom",
          },
        },
      }

      dap.listeners.after.event_initialized.dapui_config = function()
        dapui.open { reset = true }
        -- Auto-focus the console window on session start
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "dapui_console" then
              vim.api.nvim_set_current_win(win)
              vim.cmd "normal! G"
              break
            end
          end
        end)
      end

      -- Keep console scrolled to bottom on new output, regardless of active buffer
      dap.listeners.after.event_output["scroll_console"] = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "dapui_console" then
            vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
          end
        end
      end

      -- Multiline input float for dap-repl
      -- <S-CR> is indistinguishable from <CR> in prompt buffers (terminal limitation),
      -- so <C-e> is used instead (unambiguous in all terminals).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dap-repl",
        callback = function(ev)
          local opts = { buffer = ev.buf }
          local open = function() require("configs.dap_multiline").open() end
          vim.keymap.set({ "n", "i" }, "<C-e>", open, opts)
        end,
      })
    end,
  },

  {
    "daic0r/dap-helper.nvim",
    dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap" },
    config = function()
      require("dap-helper").setup()
    end,
  },
}
