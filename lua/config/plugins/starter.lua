-- Configure mini.starter with async git and recent files loading
-- This file handles the startup screen with optimized data loading

-- ============================================
-- Constants
-- ============================================

local ICON_UPDATE_AVAILABLE = '\u{f062}'  -- nerd font arrow up
local ICON_UP_TO_DATE = '\u{f00c}'        -- nerd font check mark

-- ============================================
-- State for async data (must be defined before helper functions)
-- ============================================

local async_data = {
  git_root = nil,
  git_status_items = nil,  -- nil = not loaded, {} = loaded but empty, or array of items
  git_recent_items = nil,
  vim_recent_items = nil,  -- Recent files from vim history
  update_available = false,   -- Whether a newer version is available
  update_check_complete = false, -- Whether the update check has finished
}

-- ============================================
-- Helper Functions
-- ============================================

-- Helper to get exact Neovim version string
local function get_neovim_version()
  -- Get the exact version string from :version output
  local version_info = vim.fn.execute('version')
  -- Extract the first line which contains "NVIM v0.12.0-dev-1683+gdbd7f45873"
  local version_line = version_info:match('(NVIM v[^\n\r]+)')

  local version_str
  if version_line then
    -- Remove "NVIM " prefix
    version_str = version_line:gsub('^NVIM ', '')
  else
    -- Fallback to basic version if pattern doesn't match
    local v = vim.version()
    version_str = string.format('v%d.%d.%d', v.major, v.minor, v.patch)
  end

  -- Add icon based on update check status
  if async_data.update_check_complete then
    if async_data.update_available then
      return version_str .. ' ' .. ICON_UPDATE_AVAILABLE
    else
      return version_str .. ' ' .. ICON_UP_TO_DATE
    end
  end

  return version_str
end

-- Helper function to open snacks explorer
local function open_explorer()
  Snacks.explorer()
end

-- Helper function to open CodeDiff against the repository base branch
local function open_codediff_pr_view()
  local handle = io.popen('git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null')
  local ref = handle and handle:read('*a') or ''
  if handle then handle:close() end

  local base = vim.trim(ref):gsub('^refs/remotes/origin/', '')
  if base == '' then base = 'main' end

  vim.cmd('CodeDiff ' .. base .. '...')
end

-- Convert a second-difference into a human string
local function format_relative_diff(diff)
  if diff < 0 then diff = 0 end
  -- Minutes (less than 1 hour)
  if diff < 3600 then
    local minutes = math.floor(diff / 60)
    return string.format('(%dm ago)', minutes)
  end

  -- Hours (less than 1 day)
  if diff < 86400 then
    local hours = math.floor(diff / 3600)
    return string.format('(%dh ago)', hours)
  end

  -- Days (less than 30 days)
  if diff < 2592000 then
    local days = math.floor(diff / 86400)
    return string.format('(%dd ago)', days)
  end

  -- Months (capital M)
  local months = math.floor(diff / 2592000)
  return string.format('(%dM ago)', months)
end

-- Helper to format relative time in a minimal way
-- Returns strings like: "16m ago", "3h ago", "2d ago", "2M ago"
-- If file stat is missing, it can fall back to a provided epoch timestamp
local function format_relative_time(filepath, fallback_epoch)
  -- Ensure absolute path
  local abs_path = filepath
  if not filepath:match('^/') then
    abs_path = vim.fn.fnamemodify(filepath, ':p')
  end

  local stat = vim.loop.fs_stat(abs_path)
  local now = os.time()

  if not stat then
    if fallback_epoch then
      return format_relative_diff(now - fallback_epoch)
    end
    return ''
  end

  local diff = now - stat.mtime.sec

  return format_relative_diff(diff)
end

-- Helper to check if a file has a valid extension (filters out files without extensions or non-code files)
local function has_valid_extension(filepath)
  local filename = vim.fn.fnamemodify(filepath, ':t')
  local ext = vim.fn.fnamemodify(filepath, ':e')

  -- Special case: allow Makefile and similar files without extensions
  local valid_filenames = {
    'Makefile', 'makefile', 'Dockerfile', 'dockerfile',
    'Rakefile', 'Gemfile', 'Vagrantfile', 'Procfile',
  }

  for _, valid_name in ipairs(valid_filenames) do
    if filename == valid_name then
      return true
    end
  end

  -- Require extension for other files
  if ext == '' then
    return false
  end

  -- List of common code/config file extensions
  local valid_extensions = {
    -- Programming languages
    'lua', 'py', 'js', 'ts', 'jsx', 'tsx', 'go', 'rs', 'c', 'cpp', 'h', 'hpp',
    'java', 'rb', 'php', 'cs', 'swift', 'kt', 'scala', 'sh', 'bash', 'zsh',
    'vim', 'sql', 'r', 'dart', 'ex', 'exs', 'elm', 'hs', 'clj', 'cljs',
    -- Web & markup
    'html', 'css', 'scss', 'sass', 'less', 'vue', 'svelte', 'astro',
    'xml', 'json', 'yaml', 'yml', 'toml', 'md', 'mdx', 'rst', 'tex',
    -- Config files
    'conf', 'config', 'ini', 'env', 'editorconfig', 'gitignore', 'dockerignore',
  }

  for _, valid_ext in ipairs(valid_extensions) do
    if ext == valid_ext then
      return true
    end
  end

  return false
end

-- Apply timestamp highlighting using extmarks (called after buffer is rendered)
local function apply_timestamp_highlights(bufnr)
  -- Define a muted highlight group for timestamps (subtle grey)
  vim.api.nvim_set_hl(0, 'MiniStarterTimestamp', { link = 'Comment' })

  -- Create namespace for our highlights
  local ns_id = vim.api.nvim_create_namespace('ministarter_timestamps')

  -- Clear any existing highlights
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- Get all lines in the buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for line_num, line_text in ipairs(lines) do
    -- Find "from" keyword only (not the directory name)
    local from_start, from_end = line_text:find(' from ')
    if from_start then
      vim.api.nvim_buf_add_highlight(
        bufnr,
        ns_id,
        'MiniStarterTimestamp',
        line_num - 1,
        from_start - 1,
        from_end
      )
    end

    -- Find "in" keyword only (not the directory name)
    local in_start, in_end = line_text:find(' in ')
    if in_start then
      vim.api.nvim_buf_add_highlight(
        bufnr,
        ns_id,
        'MiniStarterTimestamp',
        line_num - 1,
        in_start - 1,
        in_end
      )
    end

    -- Find timestamp pattern: (Xm ago), (Xh ago), (Xd ago), (XM ago)
    local ts_start, ts_end = line_text:find('%(%d+[mhdM]%s+ago%)')
    if ts_start then
      vim.api.nvim_buf_add_highlight(
        bufnr,
        ns_id,
        'MiniStarterTimestamp',
        line_num - 1,
        ts_start - 1,
        ts_end
      )
    end
  end
end

-- ============================================
-- Async Git Data Loading
-- ============================================

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
        local candidates = {}
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
            -- Get mtime for sorting
            local stat = vim.loop.fs_stat(full_path)
            local mtime = stat and stat.mtime.sec or 0

            table.insert(candidates, {
              file = file,
              status_indicator = status_indicator,
              mtime = mtime,
              full_path = full_path,
            })
          end
        end

        -- Sort by modification time, newest first
        table.sort(candidates, function(a, b)
          return a.mtime > b.mtime
        end)

        -- Build display items from sorted candidates
        local items = {}
        for _, candidate in ipairs(candidates) do
          local filename = vim.fn.fnamemodify(candidate.file, ':t')
          local parent_dir = vim.fn.fnamemodify(candidate.file, ':h:t')
          local display_name = candidate.status_indicator .. filename

          if parent_dir and parent_dir ~= '' and parent_dir ~= '.' then
            display_name = string.format('%s in %s', display_name, parent_dir)
          end

          local time_ago = format_relative_time(candidate.full_path)
          if time_ago ~= '' then
            display_name = string.format('%s %s', display_name, time_ago)
          end

          table.insert(items, {
            name = display_name,
            action = 'edit ' .. vim.fn.fnameescape(candidate.full_path),
            section = 'Git status',
          })
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
            action = 'lua require("fzf-lua").git_status()',
            section = 'Git status',
          })
        end

        async_data.git_status_items = items
      end

      -- Always refresh starter after loading data (even if empty)
      if vim.bo.filetype == 'ministarter' then
        require('mini.starter').refresh()
        -- Reapply timestamp highlights after refresh
        vim.defer_fn(function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].filetype == 'ministarter' then
            apply_timestamp_highlights(bufnr)
          end
        end, 10)
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
    {'git', 'log', '--pretty=format:%ct', '--name-only', '--diff-filter=ACMRT', '-n', '30'},
    { text = true },
    function(obj)
      vim.schedule(function()
        if obj.code ~= 0 or not obj.stdout or obj.stdout == '' then
          async_data.git_recent_items = {}
          return
        end

        local seen = {}
        local candidates = {}
        local current_commit_time = nil

        for line in obj.stdout:gmatch('[^\r\n]+') do
          if line and line ~= '' then
            -- Capture commit timestamp rows emitted by --pretty=format:%ct
            local maybe_epoch = tonumber(line)
            if maybe_epoch then
              current_commit_time = maybe_epoch
            elseif not seen[line] then
              seen[line] = true
              local full_path = git_root .. '/' .. line

              -- Filter: only show files with valid extensions
              if has_valid_extension(line) then
                -- Get actual file mtime for accurate sorting
                local stat = vim.loop.fs_stat(full_path)
                local mtime = stat and stat.mtime.sec or current_commit_time or 0

                table.insert(candidates, {
                  file = line,
                  full_path = full_path,
                  mtime = mtime,
                })
              end
            end
          end
        end

        -- Sort by actual file modification time, newest first
        table.sort(candidates, function(a, b)
          return a.mtime > b.mtime
        end)

        -- Build items from sorted candidates, limited to n
        local items = {}
        for _, candidate in ipairs(candidates) do
          if #items >= n then break end

          local filename = vim.fn.fnamemodify(candidate.file, ':t')
          local parent_dir = vim.fn.fnamemodify(candidate.file, ':h:t')

          -- Get timestamp for the file (uses actual mtime now)
          local time_ago = format_relative_time(candidate.full_path)

          -- Build display name: "filename in dir (time ago)"
          local display_name = filename
          if parent_dir and parent_dir ~= '' and parent_dir ~= '.' then
            display_name = string.format('%s in %s', filename, parent_dir)
          end

          if time_ago ~= '' then
            display_name = string.format('%s %s', display_name, time_ago)
          end

          table.insert(items, {
            name = display_name,
            action = 'edit ' .. vim.fn.fnameescape(candidate.full_path),
            section = 'Git recent (modified)',
          })
        end

        async_data.git_recent_items = items

        -- Refresh starter if it's still open
        if vim.bo.filetype == 'ministarter' then
          require('mini.starter').refresh()
          -- Reapply timestamp highlights after refresh
          vim.defer_fn(function()
            local bufnr = vim.api.nvim_get_current_buf()
            if vim.bo[bufnr].filetype == 'ministarter' then
              apply_timestamp_highlights(bufnr)
            end
          end, 10)
        end
      end)
    end
  )
end

-- Load vim recent files asynchronously (custom implementation with timestamps)
local function load_vim_recent_async(n, cwd_only, current_dir)
  vim.schedule(function()
    local candidates = {}

    -- Get recent files from oldfiles
    local oldfiles = vim.v.oldfiles or {}
    local cwd = current_dir and vim.fn.getcwd() or nil

    for _, filepath in ipairs(oldfiles) do
      -- Check if file exists and is readable
      if vim.fn.filereadable(filepath) == 1 then
        -- Filter by cwd if needed
        local include_file = true
        if cwd_only and cwd then
          include_file = filepath:find(vim.pesc(cwd), 1, true) == 1
        end

        if include_file and has_valid_extension(filepath) then
          -- Get mtime for sorting
          local abs_path = filepath:match('^/') and filepath or vim.fn.fnamemodify(filepath, ':p')
          local stat = vim.loop.fs_stat(abs_path)
          local mtime = stat and stat.mtime.sec or 0
          table.insert(candidates, { path = filepath, mtime = mtime })
        end
      end
    end

    -- Sort by modification time, newest first
    table.sort(candidates, function(a, b)
      return a.mtime > b.mtime
    end)

    -- Build items from sorted candidates, limited to n
    local items = {}
    for i, candidate in ipairs(candidates) do
      if #items >= (n or 10) then break end

      local filepath = candidate.path
      local filename = vim.fn.fnamemodify(filepath, ':t')
      local time_ago = format_relative_time(filepath)

      -- Get top-level directory name (parent of the file)
      local parent_dir = vim.fn.fnamemodify(filepath, ':h:t')

      -- Build display name: "filename from dir (time ago)"
      local display_name = filename
      if parent_dir and parent_dir ~= '' and parent_dir ~= '.' then
        display_name = string.format('%s from %s', filename, parent_dir)
      end

      if time_ago ~= '' then
        display_name = string.format('%s %s', display_name, time_ago)
      end

      table.insert(items, {
        name = display_name,
        action = 'edit ' .. vim.fn.fnameescape(filepath),
        section = 'Recent files',
      })
    end

    async_data.vim_recent_items = items

    -- Refresh starter if it's still open
    if vim.bo.filetype == 'ministarter' then
      require('mini.starter').refresh()
      -- Reapply timestamp highlights after refresh
      vim.defer_fn(function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype == 'ministarter' then
          apply_timestamp_highlights(bufnr)
        end
      end, 10)
    end
  end)
end

-- Check for Neovim updates asynchronously (checks main branch)
local function check_neovim_update_async()
  -- Extract current commit hash from version string
  local version_info = vim.fn.execute('version')
  local version_line = version_info:match('(NVIM v[^\n\r]+)')

  if not version_line then
    return
  end

  -- Extract commit hash (e.g., "v0.12.0-dev-1683+gdbd7f45873" -> "dbd7f45873")
  local current_commit = version_line:match('%+g(%w+)')
  if not current_commit then
    return
  end

  -- Fetch latest commit hash from neovim/neovim main branch
  vim.system(
    {'curl', '-s', 'https://api.github.com/repos/neovim/neovim/commits/master'},
    { text = true },
    function(obj)
      vim.schedule(function()
        if obj.code ~= 0 or not obj.stdout or obj.stdout == '' then
          async_data.update_check_complete = true
          return
        end

        -- Parse JSON response to get latest commit SHA
        local latest_commit = obj.stdout:match('"sha"%s*:%s*"(%w+)"')
        if not latest_commit then
          async_data.update_check_complete = true
          return
        end

        -- Compare commit hashes (compare first 7-10 characters)
        local current_short = current_commit:sub(1, 10)
        local latest_short = latest_commit:sub(1, 10)

        async_data.update_available = (current_short ~= latest_short)
        async_data.update_check_complete = true

        -- Refresh starter if it's still open
        if vim.bo.filetype == 'ministarter' then
          require('mini.starter').refresh()
          -- Reapply timestamp highlights after refresh
          vim.defer_fn(function()
            local bufnr = vim.api.nvim_get_current_buf()
            if vim.bo[bufnr].filetype == 'ministarter' then
              apply_timestamp_highlights(bufnr)
            end
          end, 10)
        end
      end)
    end
  )
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

-- Autocommand to apply highlights after ministarter opens
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ministarter',
  callback = function(args)
    -- Apply highlights after a short delay to ensure content is rendered
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == 'ministarter' then
        apply_timestamp_highlights(args.buf)
      end
    end, 10)
  end,
  desc = 'Highlight timestamps in mini.starter',
})

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
        { name = "File picker", action = "lua require('fzf-lua').files()", section = "Builtin actions" },
        { name = "Search in files", action = "lua require('fzf-lua').live_grep()", section = "Builtin actions" },
        { name = "Explorer", action = open_explorer, section = "Builtin actions" },
        { name = "CodeDiff PR view", action = open_codediff_pr_view, section = "Builtin actions" },
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
    header = function()
      return 'Welcome to Neovim ' .. get_neovim_version()
    end,
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
  check_neovim_update_async()
end)
