-- Configure mini.nvim modules with optimized loading
-- This file is called from native-packages.lua after mini.nvim is loaded

-- ============================================
-- STAGE 1: UI Essentials (load immediately)
-- ============================================

-- mini.icons - File icons (required by statusline)
require('mini.icons').setup()

-- mini.statusline - Statusline
require('mini.statusline').setup()

-- mini.tabline - Buffer tabs at the top
require('mini.tabline').setup()

-- mini.notify - Notifications
require('mini.notify').setup()

-- ============================================
-- STAGE 1b: mini.starter (must load immediately for autoopen)
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
      if obj.code ~= 0 or not obj.stdout or obj.stdout == '' then
        async_data.git_status_items = {}
        return
      end

      local items = {}
      for line in obj.stdout:gmatch('[^\r\n]+') do
        if line and line ~= '' then
          local status_code = line:sub(1, 2)
          local file = line:sub(4)

          local status_indicator = ''
          if status_code:match('^[MARC]') then
            status_indicator = '[staged] '
          elseif status_code:match('^.[MD]') then
            status_indicator = '[modified] '
          elseif status_code:match('%?%?') then
            status_indicator = '[untracked] '
          end

          local full_path = git_root .. '/' .. file
          table.insert(items, {
            name = status_indicator .. vim.fn.fnamemodify(file, ':t'),
            action = 'edit ' .. vim.fn.fnameescape(full_path),
            section = 'Git status',
          })
        end
      end

      async_data.git_status_items = items

      -- Refresh starter if it's still open
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

-- Custom section: Git status files (returns cached or loading placeholder)
local function git_status_files()
  return function()
    if async_data.git_status_items == nil then
      -- Still loading
      return {
        { name = 'Loading git status...', action = '', section = 'Git status' }
      }
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

-- ============================================
-- STAGE 2: Insert-mode plugins (on InsertEnter)
-- ============================================
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      -- mini.completion is DISABLED in favor of blink.cmp
      -- See config/plugins/blink.lua for completion configuration

      -- mini.pairs - Auto pairs
      require('mini.pairs').setup()
    end)
  end
})

-- ============================================
-- STAGE 3: Deferred modules (after startup)
-- ============================================

vim.schedule(function()
  -- mini.surround - Surround mappings
  require('mini.surround').setup({
    mappings = {
      add = 'sa',
      delete = 'sd',
      find = 'sf',
      find_left = 'sF',
      highlight = 'sh',
      replace = 'sr',
      update_n_lines = 'sn',
    },
  })

  -- mini.comment - Commenting
  require('mini.comment').setup()

  -- mini.align - Text alignment
  require('mini.align').setup()
end)

-- ============================================
-- STAGE 4: Git modules (deferred)
-- ============================================

vim.schedule(function()
  -- mini.git - Git integration
  require('mini.git').setup()

  -- mini.diff - Git diff visualization
  require('mini.diff').setup()

  -- Git keybindings (for mini.git and mini.diff)
  vim.keymap.set('n', '<leader>gg', ':Git<Space>', { noremap = true, silent = false, desc = 'Git status' })
  vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { noremap = true, silent = true, desc = 'Git commit' })
  vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { noremap = true, silent = true, desc = 'Git push' })
  vim.keymap.set('n', '<leader>gl', ':Git log<CR>', { noremap = true, silent = true, desc = 'Git log' })
  vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true, desc = 'Git blame' })
  vim.keymap.set('n', '<leader>gd', function() MiniDiff.toggle_overlay() end, { noremap = true, silent = true, desc = 'Toggle diff overlay' })
  vim.keymap.set('n', '<leader>gh', 'gh', { noremap = false, silent = true, desc = 'Apply hunk (stage)' })
  vim.keymap.set('n', '<leader>gH', 'gH', { noremap = false, silent = true, desc = 'Reset hunk (discard)' })
  vim.keymap.set('n', '<leader>gj', ']h', { noremap = false, silent = true, desc = 'Next hunk' })
  vim.keymap.set('n', '<leader>gk', '[h', { noremap = false, silent = true, desc = 'Previous hunk' })
  vim.keymap.set('n', '<leader>gJ', ']H', { noremap = false, silent = true, desc = 'Last hunk' })
  vim.keymap.set('n', '<leader>gK', '[H', { noremap = false, silent = true, desc = 'First hunk' })
end)

-- ============================================
-- STAGE 5: Fuzzy finder and helper modules
-- ============================================

vim.schedule(function()
  -- mini.pick - Fuzzy finder
  require('mini.pick').setup({
    window = {
      config = function()
        local height = math.floor(0.3 * vim.o.lines)  -- 30% of screen height
        local width = vim.o.columns  -- Full width
        return {
          anchor = 'SW',  -- Anchor to bottom-left (South-West)
          height = height,
          width = width,
          row = vim.o.lines - vim.o.cmdheight - 1,  -- Position above statusline
          col = 0,  -- Start at leftmost column
          border = 'solid',
        }
      end,
    },
  })

  -- mini.extra - Additional pickers (load with mini.pick since they're related)
  -- This must be loaded here (not deferred further) because LSP keymaps depend on it
  require('mini.extra').setup()

  -- mini.bufremove - Buffer management (delete/wipeout buffers)
  require('mini.bufremove').setup()
end)

-- Setup keymaps for mini.pick
vim.keymap.set('n', '<leader>ff', function() MiniPick.builtin.files() end, { noremap = true, silent = true, desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function() MiniPick.builtin.grep_live() end, { noremap = true, silent = true, desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', function() MiniPick.builtin.buffers() end, { noremap = true, silent = true, desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', function() MiniPick.builtin.help_tags() end, { noremap = true, silent = true, desc = 'Help tags' })

-- Search keymaps (leader + s)
vim.keymap.set('n', '<leader>ss', function() MiniPick.builtin.grep_live() end, { noremap = true, silent = true, desc = 'Search in files (grep live)' })
vim.keymap.set('n', '<leader>sf', function() MiniPick.builtin.grep() end, { noremap = true, silent = true, desc = 'Search pattern in files' })

-- ============================================
-- STAGE 6: Extra picker keymaps (after mini.extra is loaded)
-- ============================================

vim.schedule(function()
  -- Diagnostic picker
  vim.keymap.set('n', '<leader>ld', function()
    require('mini.extra').pickers.diagnostic()
  end, { noremap = true, silent = true, desc = 'Diagnostics' })

  -- Note: LSP picker keymaps are defined in config/keymaps.lua

  -- Treesitter: Search symbols in current file by type
  vim.keymap.set('n', '<leader>ft', function()
    require('mini.extra').pickers.treesitter()
  end, { noremap = true, silent = true, desc = 'Treesitter Symbols' })

  -- Explorer: File/directory browser
  vim.keymap.set('n', '<leader>fe', function()
    require('mini.extra').pickers.explorer()
  end, { noremap = true, silent = true, desc = 'Explorer' })

  -- Buffer lines: Search lines in all buffers
  vim.keymap.set('n', '<leader>fl', function()
    require('mini.extra').pickers.buf_lines()
  end, { noremap = true, silent = true, desc = 'Buffer Lines' })

  -- Old files: Recently accessed files
  vim.keymap.set('n', '<leader>fo', function()
    require('mini.extra').pickers.oldfiles()
  end, { noremap = true, silent = true, desc = 'Old Files' })

  -- History: Command history
  vim.keymap.set('n', '<leader>fH', function()
    require('mini.extra').pickers.history({ scope = ':' })
  end, { noremap = true, silent = true, desc = 'Command History' })
end)

-- ============================================
-- STAGE 7: mini.clue (after all keymaps loaded)
-- ============================================

vim.defer_fn(function()
  -- mini.clue - Keybinding hints
  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader key
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key (goto/generic)
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },

      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },

      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key (fold/zoom)
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },

      -- Bracket motions
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },
    },
    clues = {
      -- Leader key groups
      { mode = 'n', keys = '<Leader>b', desc = 'Buffer' },
      { mode = 'n', keys = '<Leader>f', desc = 'Find' },
      { mode = 'n', keys = '<Leader>g', desc = 'Git' },
      { mode = 'n', keys = '<Leader>l', desc = 'LSP' },
      { mode = 'n', keys = '<Leader>q', desc = 'Quit' },
      { mode = 'n', keys = '<Leader>s', desc = 'Search' },
      { mode = 'n', keys = '<Leader>t', desc = 'Tabs' },
      { mode = 'n', keys = '<Leader>w', desc = 'Save' },
      { mode = 'n', keys = '<Leader>y', desc = 'Yank' },

      -- Built-in clues
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
    window = {
      delay = 200,
      config = {
        border = 'none',
        width = 'auto',
      },
      scroll_down = '<C-d>',
      scroll_up = '<C-u>',
    },
  })
end, 200)
