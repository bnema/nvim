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
-- The starter configuration has been moved to config/plugins/starter.lua
-- to keep this file focused on other mini.nvim modules
require('config.plugins.starter')

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

  -- Git keybindings (for mini.git, mini.diff, and diffview)
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

  -- Diffview keybindings
  vim.keymap.set('n', '<leader>gv', ':DiffviewOpen<CR>', { noremap = true, silent = true, desc = 'Open diffview' })
  vim.keymap.set('n', '<leader>gV', ':DiffviewClose<CR>', { noremap = true, silent = true, desc = 'Close diffview' })
  vim.keymap.set('n', '<leader>gf', ':DiffviewFileHistory %<CR>', { noremap = true, silent = true, desc = 'File history (current)' })
  vim.keymap.set('n', '<leader>gF', ':DiffviewFileHistory<CR>', { noremap = true, silent = true, desc = 'File history (all)' })

  -- Neogit keybindings (Magit-like Git interface)
  vim.keymap.set('n', '<leader>gn', function() require('neogit').open() end, { noremap = true, silent = true, desc = 'Open Neogit (status)' })
  vim.keymap.set('n', '<leader>gN', function() require('neogit').open({ kind = 'split' }) end, { noremap = true, silent = true, desc = 'Open Neogit (split)' })
  vim.keymap.set('n', '<leader>gC', function() require('neogit').open({ 'commit' }) end, { noremap = true, silent = true, desc = 'Neogit commit popup' })
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
-- mini.clue has been moved to config/clue.lua
-- and is loaded at the end of init.lua to ensure
-- all keymaps are registered before discovery
-- ============================================
