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
    local autoalma_start, autoalma_end = string.find(filepath:lower(), "autoalma[^/]*")
    if autoalma_start and not string.find(filepath, "AutoALMA/dependencies") then
      -- Extract the path up to and including "AutoALMA"
      local autoalma_root = string.sub(filepath, 1, autoalma_end)
      on_dir(autoalma_root)
    else
      -- For other cases, use the default root detection mechanism
      -- Use util.root_pattern to find the root based on markers
      local lsp_util = require "lspconfig.util"
      local root = lsp_util.root_pattern(".git", "setup.py", "pyproject.toml", "requirements.txt")(filepath)
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
  cmd = { "clangd", "--clang-tidy", "--background-index", "--offset-encoding=utf-8", "--cross-file-rename", "-j=4" },
  root_markers = { ".clangd", "compile_commands.json" },
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

-- :MergeCompileCommands [container_path]
-- Merges per-package compile_commands.json from build/*/ into one at workspace root.
-- If container_path is given, remaps those paths to the current cwd.
local merge_script = vim.fn.stdpath "config" .. "/scripts/merge_compile_commands.py"
vim.api.nvim_create_user_command("MergeCompileCommands", function(opts)
  local workspace = vim.fn.getcwd()
  local cmd = { "python3", merge_script, "--workspace", workspace }
  if opts.args ~= "" then
    table.insert(cmd, "--container-path")
    table.insert(cmd, opts.args)
  end
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data and data[1] ~= "" then
        vim.schedule(function() vim.notify(table.concat(data, "\n"), vim.log.levels.INFO) end)
      end
    end,
    on_stderr = function(_, data)
      if data and data[1] ~= "" then
        vim.schedule(function() vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR) end)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          vim.notify("Restarting clangd...", vim.log.levels.INFO)
          for _, client in ipairs(vim.lsp.get_clients { name = "clangd" }) do
            client:stop()
          end
          vim.defer_fn(function()
            if vim.api.nvim_buf_get_name(0) ~= "" then
              vim.cmd "e"
            end
          end, 500)
        end)
      end
    end,
  })
end, { nargs = "?", desc = "Merge compile_commands.json and optionally remap container paths" })

-- :GenerateClangd
-- Writes a .clangd config file at cwd for clangd to find the compilation database
-- and suppress missing system header errors.
vim.api.nvim_create_user_command("GenerateClangd", function()
  local clangd_config = table.concat({
    "CompileFlags:",
    "  CompilationDatabase: .",
    "Diagnostics:",
    "  Suppress:",
    '    - "pp_file_not_found"',
    "Index:",
    "  Background: Build",
    "",
  }, "\n")
  local filepath = vim.fn.getcwd() .. "/.clangd"
  local f = io.open(filepath, "w")
  if f then
    f:write(clangd_config)
    f:close()
    vim.notify("Created " .. filepath, vim.log.levels.INFO)
  else
    vim.notify("Failed to write " .. filepath, vim.log.levels.ERROR)
  end
end, { desc = "Generate .clangd config at workspace root" })
