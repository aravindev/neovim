require("nvchad.configs.lspconfig").defaults()

local servers = { "pyright", "clangd" }

local util = require "lspconfig/util"
local path = util.path

local function get_python_path()
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
  end

  if vim.env.CONDA_PREFIX then
    return path.join(vim.env.CONDA_PREFIX, "bin", "python")
  end

  -- Fallback to system Python.
  return "python"
end

vim.lsp.config.pyright = {
  -- before_init = function(_, config)
  --   config.settings.python.pythonPath = get_python_path()
  -- end,
  root_markers = { "pyproject.toml" }, -- disabed setup.py etc since it breaks AutoALMA detecting omni. packages
  settings = {
    pyright = {},
    python = {
      pythonPath = get_python_path(),
      analysis = {
        autoImportCompletion = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly", -- workspace
        useLibraryCodeForTypes = true,
        extraPaths = {},
      },
    },
  },
}

-- Clangd
vim.lsp.config.clangd = {
  cmd = { "clangd", "--clang-tidy", "--background-index", "--offset-encoding=utf-8", "--cross-file-rename" },
  root_markers = { ".clangd", ".compile_commands.json" },
  filetypes = { "c", "cpp" },
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
