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
      -- Recent files with directory path display
      starter.sections.recent_files(10, false, function(path)
        local dirname = vim.fn.fnamemodify(path, ':h')
        if dirname == '.' or dirname == '' then
          return ''
        end
        -- Replace home directory with ~ for cleaner display
        dirname = dirname:gsub(vim.env.HOME, '~')

        if #dirname > 30 then
          -- Show only the last 3 directory components with ellipsis prefix
          local parts = vim.split(dirname, '/')
          if #parts > 3 then
            return ' from ".../' .. table.concat({parts[#parts-2], parts[#parts-1], parts[#parts]}, '/') .. '"'
          end
        end
        return ' from "' .. dirname .. '"'
      end),
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

-- ============================================
-- STAGE 2: Insert-mode plugins (on InsertEnter)
-- ============================================
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      -- mini.completion - Completion UI
      require('mini.completion').setup({
        window = {
          info = { height = 25, width = 80, border = 'rounded' },
          signature = { height = 20, width = 80, border = 'rounded' },
        },
        lsp_completion = {
          source_func = 'omnifunc',
          auto_setup = true,
        },
      })

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
