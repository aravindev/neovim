local M = {}

local MAX_BUFS = 8
local api = vim.api

M._skip_reorder = false

local function reorder_bufs()
  if M._skip_reorder then
    return
  end

  local bufnr = api.nvim_get_current_buf()
  local bufs = vim.t.bufs
  if not bufs then
    return
  end

  if not api.nvim_get_option_value("buflisted", { buf = bufnr }) then
    return
  end

  -- Move current buf to front
  for i, nr in ipairs(bufs) do
    if nr == bufnr and i > 1 then
      table.remove(bufs, i)
      table.insert(bufs, 1, bufnr)
      break
    end
  end

  -- Evict oldest (last) buffers beyond cap
  local to_close = {}
  while #bufs > MAX_BUFS do
    table.insert(to_close, table.remove(bufs, #bufs))
  end

  -- Update list first so NvChad's BufDelete handler is a no-op for evicted bufs
  vim.t.bufs = bufs

  for _, nr in ipairs(to_close) do
    if not api.nvim_get_option_value("modified", { buf = nr }) then
      api.nvim_buf_delete(nr, {})
    end
  end
end

api.nvim_create_autocmd("BufEnter", {
  callback = reorder_bufs,
})

-- Wrappers for <tab>/<S-tab> that suppress MRU reordering during cycling
M.nav_next = function()
  M._skip_reorder = true
  require("nvchad.tabufline").next()
  M._skip_reorder = false
end

M.nav_prev = function()
  M._skip_reorder = true
  require("nvchad.tabufline").prev()
  M._skip_reorder = false
end

return M
