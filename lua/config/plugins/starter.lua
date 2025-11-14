-- Configure mini.starter with async git and recent files loading
-- This file handles the startup screen with optimized data loading

-- ============================================
-- Helper Functions
-- ============================================

-- Helper to get current Neovim version
local function get_neovim_version()
  local v = vim.version()
  return string.format('%d.%d.%d', v.major, v.minor, v.patch)
end

-- Helper function to open yazi (replaces MiniFiles)
local function open_yazi()
  require('yazi').yazi()
end

-- ============================================
-- Async Git Data Loading
-- ============================================

-- State for async data
local async_data = {
  git_root = nil,
  git_status_items = nil,  -- nil = not loaded, {} = loaded but empty, or array of items
  git_recent_items = nil,
  vim_recent_items = nil,  -- Recent files from vim history
}

-- Get git root synchronously (fast operation)
local function get_git_root()
  if async_data.git_root ~= nil then
    return async_data.git_root
  end

  local result = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
  if vim.v.shell_error == 0 and result then
    async_data.git_root = result
  else
    async_data.git_root = false  -- Mark as not a git repo
  end
  return async_data.git_root
end

-- Load git status files asynchronously
local function load_git_status_async()
  local git_root = get_git_root()
  if not git_root then
    async_data.git_status_items = {}
    return
  end

  vim.system({'git', 'status', '--short'}, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 or not obj.stdout then
        async_data.git_status_items = {}
      elseif obj.stdout == '' then
        -- Empty stdout means no modified files
        async_data.git_status_items = {}
      else
        local items = {}
        local staged_count = 0
        local modified_count = 0
        local untracked_count = 0

        for line in obj.stdout:gmatch('[^\r\n]+') do
          if line and line ~= '' then
            local status_code = line:sub(1, 2)
            local file = line:sub(4)

            local status_indicator = ''
            if status_code:match('^[MARC]') then
              status_indicator = '[staged] '
              staged_count = staged_count + 1
            elseif status_code:match('^.[MD]') then
              status_indicator = '[modified] '
              modified_count = modified_count + 1
            elseif status_code:match('%?%?') then
              status_indicator = '[untracked] '
              untracked_count = untracked_count + 1
            end

            local full_path = git_root .. '/' .. file
            table.insert(items, {
              name = status_indicator .. vim.fn.fnamemodify(file, ':t'),
              action = 'edit ' .. vim.fn.fnameescape(full_path),
              section = 'Git status',
            })
          end
        end

        -- Add summary line at the beginning if more than 5 files
        if #items > 5 then
          local summary_parts = {}
          if staged_count > 0 then
            table.insert(summary_parts, staged_count .. ' staged')
          end
          if modified_count > 0 then
            table.insert(summary_parts, modified_count .. ' modified')
          end
          if untracked_count > 0 then
            table.insert(summary_parts, untracked_count .. ' untracked')
          end

          local summary = 'Git status (' .. table.concat(summary_parts, ', ') .. ')'
          table.insert(items, 1, {
            name = summary,
            action = 'lua MiniPick.builtin.files({ tool = "git" })',
            section = 'Git status',
          })
        end

        async_data.git_status_items = items
      end

      -- Always refresh starter after loading data (even if empty)
      if vim.bo.filetype == 'ministarter' then
        require('mini.starter').refresh()
      end
    end)
  end)
end

-- Load git recent files asynchronously
local function load_git_recent_async(n)
  n = n or 10
  local git_root = get_git_root()
  if not git_root then
    async_data.git_recent_items = {}
    return
  end

  vim.system(
    {'git', 'log', '--pretty=format:', '--name-only', '--diff-filter=ACMRT', '-n', '10'},
    { text = true },
    function(obj)
      vim.schedule(function()
        if obj.code ~= 0 or not obj.stdout or obj.stdout == '' then
          async_data.git_recent_items = {}
          return
        end

        local seen = {}
        local items = {}

        for line in obj.stdout:gmatch('[^\r\n]+') do
          if #items >= n then break end

          if line and line ~= '' and not seen[line] then
            seen[line] = true
            local full_path = git_root .. '/' .. line
            table.insert(items, {
              name = vim.fn.fnamemodify(line, ':t'),
              action = 'edit ' .. vim.fn.fnameescape(full_path),
              section = 'Git recent (modified)',
            })
          end
        end

        async_data.git_recent_items = items

        -- Refresh starter if it's still open
        if vim.bo.filetype == 'ministarter' then
          require('mini.starter').refresh()
        end
      end)
    end
  )
end

-- Load vim recent files asynchronously
local function load_vim_recent_async(n, cwd_only, current_dir)
  vim.schedule(function()
    local starter = require('mini.starter')
    local items = starter.sections.recent_files(n or 10, cwd_only or false, current_dir or true)()
    async_data.vim_recent_items = items

    -- Refresh starter if it's still open
    if vim.bo.filetype == 'ministarter' then
      starter.refresh()
    end
  end)
end

-- ============================================
-- Custom Sections
-- ============================================

-- Custom section: Git status files (returns cached or loading placeholder)
local function git_status_files()
  return function()
    if async_data.git_status_items == nil then
      -- Still loading
      return {
        { name = 'Loading git status...', action = '', section = 'Git status' }
      }
    end
    -- Hide section if no modified files (empty array)
    if #async_data.git_status_items == 0 then
      return {}
    end
    return async_data.git_status_items
  end
end

-- Custom section: Git recent files (returns cached or loading placeholder)
local function git_recent_files(n)
  return function()
    if async_data.git_recent_items == nil then
      -- Still loading
      return {
        { name = 'Loading git recent...', action = '', section = 'Git recent (modified)' }
      }
    end
    return async_data.git_recent_items
  end
end

-- Custom section: Vim recent files (returns cached or loading placeholder)
local function vim_recent_files(n, cwd_only, current_dir)
  return function()
    if async_data.vim_recent_items == nil then
      -- Still loading
      return {
        { name = 'Loading recent files...', action = '', section = 'Recent files' }
      }
    end
    return async_data.vim_recent_items
  end
end

-- ============================================
-- Setup mini.starter
-- ============================================

-- Setup mini.starter - MUST happen before any buffer is created
local function setup_mini_starter()
  local ok, starter = pcall(require, 'mini.starter')
  if not ok then
    return
  end

  starter.setup({
    autoopen = true,
    evaluate_single = false,
    items = {
      -- Custom builtin actions
      {
        { name = "New buffer", action = "enew", section = "Builtin actions" },
        { name = "File picker", action = "lua MiniPick.builtin.files()", section = "Builtin actions" },
        { name = "Search in files", action = "lua MiniPick.builtin.grep_live()", section = "Builtin actions" },
        { name = "Explorer", action = open_yazi, section = "Builtin actions" },
        { name = "Quit", action = "qall", section = "Builtin actions" },
      },
      -- Git status files (staged/unstaged) - shown first if any
      git_status_files(),
      -- Git recently modified files
      git_recent_files(5),
      -- Recent files from vim history
      vim_recent_files(5, false, true),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.indexing('all', { 'Builtin actions' }),
      starter.gen_hook.padding(3, 2),
    },
    header = 'Welcome to Neovim ' .. get_neovim_version(),
    footer = '',
  })
end

-- Initialize the starter screen immediately
setup_mini_starter()

-- Start loading all data asynchronously (won't block UI)
vim.schedule(function()
  load_git_status_async()
  load_git_recent_async(5)
  load_vim_recent_async(5, false, true)
end)
