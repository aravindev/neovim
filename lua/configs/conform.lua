local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    cpp = { "clang_format" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 1000,
    async = false,
    lsp_format = "fallback",
  },
  formatters = {
    black = {
      prepend_args = { "--line-length", "120", "--preview" },
    },
    isort = {
      prepend_args = { "--profile", "black", "--filter-files" },
    },
  },
}

return options
