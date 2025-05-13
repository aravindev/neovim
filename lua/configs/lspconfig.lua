require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

local servers = { "pyright", "clangd" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

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

lspconfig.pyright.setup {
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path()
  end,
  settings = {
    pyright = {},
    python = {
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
lspconfig.clangd.setup {
  cmd = { "/usr/bin/clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp" },
  root_dir = lspconfig.util.root_pattern(
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git"
  ),
  single_file_support = true,
}
local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
