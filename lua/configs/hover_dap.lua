-- Custom DAP hover provider: uses session:evaluate() for a clean repr-like view
-- instead of the built-in provider which expands all children/attributes.
return {
  name = "DAP",
  priority = 1002,
  enabled = function()
    local ok, dap = pcall(require, "dap")
    return ok and dap.session() ~= nil
  end,
  execute = function(_params, done)
    local dap = require "dap"
    local session = dap.session()
    if not session then
      return done()
    end
    local expression = vim.fn.expand "<cexpr>"
    session:evaluate({ expression = expression, context = "hover" }, function(err, result)
      if err or not result or not result.result then
        done()
        return
      end
      done { lines = vim.split(result.result, "\n", { plain = true }) }
    end)
  end,
}
