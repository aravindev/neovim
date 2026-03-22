local map = vim.keymap.set

vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped",    { text = "🟢", texthl = "", linehl = "", numhl = "" })

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

-- DAP via Telescope
map("n", "<leader>dl", function()
  local launch_json =
    vim.fn.systemlist([[find . -name "launch.json" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2-]])[1]
  vim.diagnostic.reset()

  if launch_json ~= nil then
    print("Found launch.json at: " .. launch_json)
    require("dap.ext.vscode").load_launchjs(launch_json)
    require("telescope").extensions.dap.configurations()
  else
    print "No launch.json found, setting up default Python configuration"
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

map("n", "<leader>dff", function()
  require("telescope").extensions.dap.frames()
end, { desc = "Telescope DAP Frames" })

map("n", "<leader>dfb", function()
  require("telescope").extensions.dap.list_breakpoints()
end, { desc = "Telescope DAP Breakpoints" })
