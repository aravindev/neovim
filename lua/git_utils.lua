local M = {}

-- Open the current file as it existed at a chosen commit in a scratch buffer.
function M.open_file_at_commit()
  local filepath = vim.fn.expand "%:p"
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.expand "%:p:h") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local relpath = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " ls-files --full-name " .. vim.fn.shellescape(filepath))[1]
  if vim.v.shell_error ~= 0 or not relpath or relpath == "" then
    vim.notify("File not tracked by git", vim.log.levels.WARN)
    return
  end

  local log_lines = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(git_root) .. " log --oneline --follow -- " .. vim.fn.shellescape(relpath)
  )
  if vim.v.shell_error ~= 0 or #log_lines == 0 then
    vim.notify("No git history for this file", vim.log.levels.WARN)
    return
  end

  require("telescope.pickers").new({}, {
    prompt_title = "Open file at commit",
    finder = require("telescope.finders").new_table {
      results = log_lines,
    },
    sorter = require("telescope.config").values.generic_sorter {},
    attach_mappings = function(prompt_bufnr, map)
      require("telescope.actions").select_default:replace(function()
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)

        local hash = selection.value:match("^(%S+)")
        local content = vim.fn.systemlist(
          "git -C " .. vim.fn.shellescape(git_root) .. " show " .. hash .. ":" .. vim.fn.shellescape(relpath)
        )

        local ft = vim.bo.filetype
        vim.cmd "enew"
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
        vim.bo.modifiable = true
        vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
        vim.bo.modifiable = false
        vim.bo.filetype = ft
        vim.api.nvim_buf_set_name(0, relpath .. "@" .. hash)
      end)
      return true
    end,
  }):find()
end

-- Telescope picker over local+remote branches, then open diffview.
function M.diff_with_ref()
  local git_root = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(vim.fn.expand "%:p:h") .. " rev-parse --show-toplevel"
  )[1]
  if vim.v.shell_error ~= 0 or not git_root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local raw = vim.fn.systemlist(
    "git -C " .. vim.fn.shellescape(git_root)
    .. " for-each-ref --format='%(refname:short) %(objectname:short)' refs/heads refs/remotes"
  )
  if vim.v.shell_error ~= 0 or #raw == 0 then
    vim.notify("No branches found", vim.log.levels.WARN)
    return
  end

  local entries = {}
  local seen_hashes = {}
  for _, line in ipairs(raw) do
    local name, hash = line:match("^(.+) (%x+)$")
    if name and hash and not name:match("/HEAD$") and not seen_hashes[hash] then
      seen_hashes[hash] = true
      table.insert(entries, { name = name, hash = hash })
    end
  end

  require("telescope.pickers").new({}, {
    prompt_title = "Diff with branch",
    finder = require("telescope.finders").new_table {
      results = entries,
      entry_maker = function(e)
        return { value = e.hash, display = e.name, ordinal = e.name }
      end,
    },
    sorter = require("telescope.config").values.generic_sorter {},
    attach_mappings = function(prompt_bufnr)
      require("telescope.actions").select_default:replace(function()
        local hash = require("telescope.actions.state").get_selected_entry().value
        require("telescope.actions").close(prompt_bufnr)
        vim.cmd("cd " .. vim.fn.fnameescape(git_root))
        vim.cmd("DiffviewOpen " .. hash)
      end)
      return true
    end,
  }):find()
end

return M
