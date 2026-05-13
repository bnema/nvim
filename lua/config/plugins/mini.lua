-- Configure mini.nvim modules with optimized loading
-- This file is called from native-packages.lua after mini.nvim is loaded

-- ============================================
-- STAGE 1: UI Essentials (load immediately)
-- ============================================

-- mini.icons - File icons (required by statusline)
require('mini.icons').setup()

local COPILOT_ICON = '\u{f113}'

-- mini.statusline - Statusline
require('mini.statusline').setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local location = MiniStatusline.section_location({ trunc_width = 75 })
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

      local copilot_map = {
        ok = COPILOT_ICON,
        pending = COPILOT_ICON .. '...',
        error = COPILOT_ICON .. '!',
      }
      local copilot_status = type(_G.get_copilot_status) == 'function' and _G.get_copilot_status() or nil
      local copilot = copilot_map[copilot_status]

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp, copilot } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      })
    end,
  },
})

-- mini.tabline - Top buffer bar (hide Vim tab-page section)
require('mini.tabline').setup({
  tabpage_section = 'none',
})

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

  -- Git keybindings for mini.diff (inline diff visualization)
  -- NOTE: Git commands (status, commit, push, log, blame) are handled by lazygit (<leader>gl)
  vim.keymap.set('n', '<leader>gd', function() MiniDiff.toggle_overlay() end, { noremap = true, silent = true, desc = 'Toggle diff overlay' })
  vim.keymap.set('n', '<leader>gh', 'gh', { noremap = false, silent = true, desc = 'Apply hunk (stage)' })
  vim.keymap.set('n', '<leader>gH', 'gH', { noremap = false, silent = true, desc = 'Reset hunk (discard)' })
  vim.keymap.set('n', '<leader>gj', ']h', { noremap = false, silent = true, desc = 'Next hunk' })
  vim.keymap.set('n', '<leader>gk', '[h', { noremap = false, silent = true, desc = 'Previous hunk' })
  vim.keymap.set('n', '<leader>gJ', ']H', { noremap = false, silent = true, desc = 'Last hunk' })
  vim.keymap.set('n', '<leader>gK', '[H', { noremap = false, silent = true, desc = 'First hunk' })
end)

-- ============================================
-- STAGE 5: Buffer management
-- ============================================

vim.schedule(function()
  -- mini.bufremove - Buffer management (delete/wipeout buffers)
  require('mini.bufremove').setup()
end)

-- NOTE: Fuzzy finding is now handled by fzf-lua (see lua/plugins/fzf.lua)

-- ============================================
-- mini.clue has been moved to config/clue.lua
-- and is loaded at the end of init.lua to ensure
-- all keymaps are registered before discovery
-- ============================================
