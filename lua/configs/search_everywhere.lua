-- Search Everywhere: CLion-style unified fuzzy search over file names and content.
-- Feeds both file paths and grep results into a single picker so fzf-native
-- scores everything by longest continuous match regardless of source.

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local entry_display = require "telescope.pickers.entry_display"

local MIN_QUERY_LEN = 5
local MAX_RESULTS_PER_SOURCE = 200

-- Turn a fuzzy query into a loose regex: "modtra" -> "m.*o.*d.*t.*r.*a"
local function to_loose_regex(query)
  local chars = {}
  for i = 1, #query do
    local c = query:sub(i, i)
    -- Escape regex special chars
    if c:match "[%.%^%$%(%)%[%]%{%}%+%*%?%|\\]" then
      c = "\\" .. c
    end
    chars[#chars + 1] = c
  end
  return table.concat(chars, ".*")
end

local function search_everywhere(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  opts.path_display = opts.path_display or { "truncate" }

  local displayer = entry_display.create {
    separator = "  ",
    items = {
      { width = 4 },
      { width = 40 },
      { width = 6 },
      { remaining = true },
    },
  }

  local function make_file_entry(filepath)
    return {
      value = filepath,
      ordinal = filepath,
      display = function()
        return displayer {
          { "FILE", "TelescopeResultsIdentifier" },
          { filepath, "TelescopeResultsNormal" },
          { "", "" },
          { "", "" },
        }
      end,
      filename = filepath,
      lnum = 1,
      col = 1,
    }
  end

  local function make_content_entry(raw)
    local filepath, lnum, col, text = raw:match "^([^:]+):(%d+):(%d+):(.*)"
    if not filepath then return nil end
    text = vim.trim(text)
    return {
      value = raw,
      ordinal = filepath .. " " .. text,
      display = function()
        return displayer {
          { "GREP", "TelescopeResultsComment" },
          { filepath, "TelescopeResultsNormal" },
          { ":" .. lnum, "TelescopeResultsLineNr" },
          text,
        }
      end,
      filename = filepath,
      lnum = tonumber(lnum),
      col = tonumber(col),
    }
  end

  pickers
    .new(opts, {
      prompt_title = "Search Everywhere",
      finder = finders.new_dynamic {
        fn = function(prompt)
          if not prompt or #prompt < MIN_QUERY_LEN then
            return {}
          end

          local results = {}
          local pattern = to_loose_regex(prompt)

          -- 1. File name matches via fd
          local fd_cmd = string.format(
            "fd --type f --color never --max-results %d '%s' 2>/dev/null",
            MAX_RESULTS_PER_SOURCE,
            pattern
          )
          local fd_handle = io.popen(fd_cmd)
          if fd_handle then
            local seen = {}
            for line in fd_handle:lines() do
              seen[line] = true
              results[#results + 1] = { kind = "file", path = line }
            end
            fd_handle:close()
          end

          -- 2. Content matches via rg
          local rg_cmd = string.format(
            "rg --no-heading --with-filename --line-number --column --smart-case --max-count 5 --max-columns 200 --color never -e '%s' 2>/dev/null | head -n %d",
            pattern,
            MAX_RESULTS_PER_SOURCE
          )
          local rg_handle = io.popen(rg_cmd)
          if rg_handle then
            for line in rg_handle:lines() do
              results[#results + 1] = { kind = "content", raw = line }
            end
            rg_handle:close()
          end

          -- 3. Build entries
          local entries = {}
          for _, r in ipairs(results) do
            if r.kind == "file" then
              entries[#entries + 1] = make_file_entry(r.path)
            else
              local entry = make_content_entry(r.raw)
              if entry then
                entries[#entries + 1] = entry
              end
            end
          end

          return entries
        end,
        entry_maker = function(entry)
          return entry
        end,
      },
      sorter = conf.generic_sorter(opts),
      previewer = conf.grep_previewer(opts),
    })
    :find()
end

return search_everywhere
