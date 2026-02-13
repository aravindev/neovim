require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>x", function()
  local bufnr = vim.fn.bufnr()
  local windows = vim.fn.win_findbuf(bufnr)
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0) -- Get all windows in the current tabpage
  local buffers = vim.tbl_filter(function(buf)
    return buf.name ~= ""
  end, vim.fn.getbufinfo { buflisted = 1 })

  local leftmost_win = wins[1]
  for _, win in ipairs(wins) do
    if win < leftmost_win then
      leftmost_win = win
    end
  end
  if #windows == 1 and current_win == leftmost_win then
    if #buffers > 1 then
      vim.cmd "bp|bd #"
    else
      vim.cmd "bd"
    end
  elseif #windows > 1 then
    vim.cmd "close"
  else
    vim.cmd "bd"
  end
end, { noremap = true, silent = true, desc = "Close buffer or split" })

-- DAP
map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "DAP Conditional Breakpoint" })
map("n", "<leader>dp", function()
  require("dap").continue()
end, { desc = "DAP Continue" })
map("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "DAP Step into" })
map("n", "<leader>dn", function()
  require("dap").step_over()
end, { desc = "DAP Step over" })
map("n", "<leader>do", function()
  require("dap").step_out()
end, { desc = "DAP Step out" })
map("n", "<leader>dt", function()
  require("dap").terminate()
end, { desc = "DAP Terminate" })
map("n", "<leader>dc", function()
  require("dapui").close()
end, { desc = "DAP Close window" })
map("n", "<leader>drf", function()
  require("dap-python").test_method()
end, { desc = "DAP Test method" })
map("n", "<leader>drc", function()
  require("dap-python").test_class()
end, { desc = "DAP Test class" })
map("n", "<leader>drs", function()
  require("dap-python").debug_selection()
end, { desc = "DAP Debug selection" })
map({ "n", "i" }, "<F9>", function()
  vim.diagnostic.reset()
  require("dap").continue()
end, { desc = "DAP Continue" })
map({ "n", "i" }, "<F10>", function()
  require("dap").step_over()
end, { desc = "DAP Step over" })
map({ "n", "i" }, "<leader><F10>", function()
  require("dap").step_into()
end, { desc = "DAP Step into" })
map({ "n", "i" }, "<F8>", function()
  require("dap").step_out()
end, { desc = "DAP Step out" })
map({ "n", "i" }, "<leader><F9>", function()
  require("dap").terminate()
end, { desc = "DAP Terminate" })
map({ "n", "i" }, "<leader><F8>", function()
  vim.diagnostic.reset()
  require("dap").run_last()
end, { desc = "DAP Restart" })

map("n", "<leader>def", function()
  require("dapui").float_element(nil, { enter = true })
end, { desc = "DAP Floating inspect" })
map("n", "m", function()
  require("dapui").eval()
end, { desc = "DAP Evaluate expression" })
map("n", "<leader>du", function()
  require("dapui").toggle { reset = true }
end, { desc = "DAP Toggle Debugger UI" })
map("n", "<leader>dx", function()
  require("dap.ui.widgets").hover()
end, { desc = "DAP Hover Inspect" })

vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "", linehl = "", numhl = "" })

map({ "n", "i" }, "<F12>", function()
  require("maximizer").toggle()
end, { desc = "Maximizer Toggle" })

--
-- GIT

map("n", "]c", function()
  require("gitsigns").next_hunk()
  require("gitsigns").preview_hunk()
end, { desc = "GIT Preview next hunk" })

map("n", "[c", function()
  require("gitsigns").prev_hunk()
  require("gitsigns").preview_hunk()
end, { desc = "GIT Preview prev hunk" })

-- COPILOT
map("i", "<C-Right>", "<Plug>(copilot-accept-word)", { desc = "Copilot Accept Word" })
map(
  "i",
  "<S-Right>",
  'copilot#Accept("\\<CR>")',
  { expr = true, replace_keycodes = false, desc = "Copilot Accept Line" }
)
vim.g.copilot_no_tab_map = true
--vim.keymap.del("i", "<Tab>")

-- Telescope
-- resume last picker using Telescope resume
map("n", "<leader>fq", function()
  require("telescope.builtin").resume()
end, { desc = "Telescope Resume" })
map("v", "<leader>fg", function()
  require("telescope.builtin").grep_string()
end, { desc = "Telescope Grep String" })
-- live grep in a specific directory
map("n", "<leader>fa", function()
  local builtin = require "telescope.builtin"
  builtin.grep_string {
    shorten_path = true,
    word_match = "-w",
    only_sort_text = false,
    search = "",
    prompt_title = "Fuzzy Live Grep",
  }
end, { desc = "Telescope Fuzzy Search" })
-- get dap configurations
map("n", "<leader>dl", function()
  -- recursively look for launch.json files in root directory and pass the first one to load_launchjs
  local project_root_dir = vim.fn.getcwd()
  local launch_json =
    vim.fn.systemlist([[find . -name "launch.json" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2-]])[1]
  vim.diagnostic.reset()

  if launch_json ~= nil then
    print("Found launch.json at: " .. launch_json)
    require("dap.ext.vscode").load_launchjs(launch_json)
    require("telescope").extensions.dap.configurations()
  else
    print "No launch.json found, setting up default Python configuration"

    -- Setup default Python configuration
    local dap = require "dap"
    if not dap.adapters.python then
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch current file",
          program = "${file}",
          pythonPath = function()
            return vim.fn.exepath "python"
          end,
        },
      }
    end

    require("telescope").extensions.dap.configurations()
  end
end, { desc = "Telescope DAP Configurations" })
-- dap show frames
map("n", "<leader>dff", function()
  require("telescope").extensions.dap.frames()
end, { desc = "Telescope DAP Frames" })
-- dap list breakpoints
map("n", "<leader>dfb", function()
  require("telescope").extensions.dap.list_breakpoints()
end, { desc = "Telescope DAP Breakpoints" })

--- LSP
-- find all diagnostics
map("n", "<leader>f?", function()
  require("telescope.builtin").diagnostics {
    layout_strategy = "vertical",
  }
end, { desc = "Telescope LSP Definitions" }) --- find all references
map("n", "<leader>fr", function()
  require("telescope.builtin").lsp_references {
    layout_strategy = "vertical",
  }
end, { desc = "Telescope LSP References" })
-- find all definitions
map("n", "<leader>fd", function()
  require("telescope.builtin").lsp_definitions {
    layout_strategy = "vertical",
  }
end, { desc = "Telescope LSP Definitions" })

-- dynamic workspace symbols
map("n", "<leader>fs", function()
  require("telescope.builtin").lsp_dynamic_workspace_symbols {
    layout_strategy = "vertical",
  }
end, { desc = "Telescope LSP Workspace Symbols" })

-- open diagnostics float and go to next diagnostic
map("n", "]d", function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = "LSP Next Diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = "LSP Previous Diagnostic" })
map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "LSP Toggle Diagnostics" })

-- set current buffer folder as workspace using vim.lsp.buf.add_workspace_folder
map("n", "<leader>sw", function()
  -- get current buffer folder
  local bufname = vim.fn.expand "%:p:h"
  vim.lsp.buf.add_workspace_folder(bufname)
end, { desc = "LSP Add Workspace Folder" })

map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>fc", vim.lsp.buf.format, { desc = "Format Code" })

-- LAZYGIT
local function getRelativeFilepath(retries, delay)
  local relative_filepath
  for _ = 1, retries do
    relative_filepath = vim.fn.getreg "+"
    if relative_filepath ~= "" then
      return relative_filepath -- Return filepath if clipboard is not empty
    end
    vim.loop.sleep(delay) -- Wait before retrying
  end
  return nil -- Return nil if clipboard is still empty after retries
end

-- Function to handle editing from Lazygit
function LazygitEdit(original_buffer, git_root)
  local current_bufnr = vim.fn.bufnr "%"
  local channel_id = vim.fn.getbufvar(current_bufnr, "terminal_job_id")

  if not channel_id then
    vim.notify("No terminal job ID found.", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(channel_id, "\15") -- \15 is <c-o>
  vim.cmd "close" -- Close Lazygit

  local relative_filepath = getRelativeFilepath(5, 50)
  if not relative_filepath then
    vim.notify("Clipboard is empty or invalid.", vim.log.levels.ERROR)
    return
  end

  local winid = vim.fn.bufwinid(original_buffer)

  if winid == -1 then
    vim.notify("Could not find the original window.", vim.log.levels.ERROR)
    return
  end

  vim.fn.win_gotoid(winid)
  -- Resolve path relative to the git root where lazygit was started
  local full_path = git_root .. "/" .. relative_filepath
  vim.cmd("e " .. full_path)
end

-- Function to start Lazygit in a floating terminal
function StartLazygit()
  local function get_git_root()
    local git_dir = vim.fn.systemlist("git -C " .. vim.fn.expand "%:p:h" .. " rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
      return nil
    end
    return git_dir
  end
  local git_root = get_git_root()
  local current_buffer = vim.api.nvim_get_current_buf()
  require("nvchad.term").toggle {
    id = "lazygit",
    pos = "float",
    float = {
      relative = "editor",
      row = 0.1,
      col = 0.045,
      width = 0.9,
      height = 0.8,
      border = "single",
    },
    size = 0.8,
    cmd = "lazygit -w " .. git_root .. " && exit",
    clear_cmd = true,
  }

  -- Sets up a keymap for terminal mode that allows to open a file in nvim buffer instead of the terminal
  vim.schedule(function()
    local term_bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_keymap(
      term_bufnr,
      "t",
      "E",
      string.format([[<cmd>lua LazygitEdit(%d, %q)<CR>]], current_buffer, git_root),
      { noremap = true, silent = true }
    )
  end)
end

map("n", "<leader>gg", StartLazygit, { desc = "Git Open Lazygit" })
-- add a mapping of dd to DiffOrig
map("n", "<leader>dd", function()
  vim.cmd "DiffOrig"
end, { desc = "Git buffer diff to write" })

-- Setup keymaps
map("n", "K", require("hover").hover, { desc = "hover.nvim" })

-- Mouse support
map("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
vim.o.mousemoveevent = true

-- UFO for folding
vim.keymap.set("n", "zR", function()
  require("ufo").openAllFolds()
end, { desc = "UFO Open All Folds" })
vim.keymap.set("n", "zM", function()
  require("ufo").closeAllFolds()
end, { desc = "UFO Close All Folds" })
vim.keymap.set("n", "zr", function()
  require("ufo").openFoldsExceptKinds()
end, { desc = "UFO Open Folds" })
vim.keymap.set("n", "zm", function()
  require("ufo").closeFoldsWith()
end, { desc = "UFO Close Folds" })

-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", function()
  require("aerial").toggle()
end, { desc = "Aerial Toggle" })
