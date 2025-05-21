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
  -- Set root directory according to the following rules:
  -- 1. If the file path contains "AutoALMA" but not "AutoALMA/dependencies", set the root to "AutoALMA".
  -- 2. Otherwise, use the default root detection mechanism.
  root_dir = function(bufnr, on_dir)
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    -- Check if file path contains AutoALMA but not AutoALMA/dependencies
    local autoalma_pos = string.find(filepath, "AutoALMA")
    if autoalma_pos and not string.find(filepath, "AutoALMA/dependencies") then
      -- Extract the path up to and including "AutoALMA"
      local autoalma_root = string.sub(filepath, 1, autoalma_pos + #"AutoALMA" - 1)
      on_dir(autoalma_root)
    else
      -- For other cases, use the default root detection mechanism
      -- Use util.root_pattern to find the root based on markers
      local util = require "lspconfig.util"
      local root = util.root_pattern(".git", "setup.py", "pyproject.toml", "requirements.txt")(filepath)
      on_dir(root)
    end
  end,
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

-- We do this for UFO which takes care of folding
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- Add capabilities to server configurations
for _, server in ipairs(servers) do
  if vim.lsp.config[server] then
    vim.lsp.config[server].capabilities = capabilities
  end
end

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
