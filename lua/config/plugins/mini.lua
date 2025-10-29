-- Configure mini.nvim modules with optimized loading

local now, later = MiniDeps.now, MiniDeps.later

-- ============================================
-- STAGE 1: UI Essentials (load immediately)
-- ============================================
now(function()
  -- mini.icons - File icons (required by statusline)
  require('mini.icons').setup()

  -- mini.statusline - Statusline
  require('mini.statusline').setup()

  -- mini.tabline - Buffer tabs at the top
  require('mini.tabline').setup()

  -- mini.notify - Notifications
  require('mini.notify').setup()
end)

-- ============================================
-- STAGE 2: Insert-mode plugins (on InsertEnter)
-- ============================================
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = function()
    later(function()
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
-- STAGE 3: File explorer (on keymap or VimEnter)
-- ============================================
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    later(function()
      -- mini.files - File explorer
      require('mini.files').setup({
        mappings = {
          close = '<ESC>',
        },
        options = {
          use_as_default_explorer = true,
        },
        windows = {
          preview = true,
          width_focus = 50,
          width_nofocus = 15,
        },
      })
    end)
  end
})

-- ============================================
-- STAGE 4: Deferred modules (after startup)
-- ============================================
later(function()
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

  -- mini.jump - Enhanced character search (f/F/t/T)
  require('mini.jump').setup({
    mappings = {
      forward = 'f',
      backward = 'F',
      forward_till = 't',
      backward_till = 'T',
      repeat_jump = ';',
    },
  })

  -- mini.align - Text alignment
  require('mini.align').setup()
end)

-- ============================================
-- STAGE 5: Git modules (after startup)
-- ============================================
later(function()
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
-- STAGE 6: Fuzzy finder and helper modules (after startup)
-- ============================================
later(function()
  -- mini.pick - Fuzzy finder (alternative to Telescope)
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

  -- mini.bufremove - Buffer management (delete/wipeout buffers)
  require('mini.bufremove').setup()
end)

-- Setup keymaps for mini.files (works with deferred loading)
local minifiles_toggle = function()
  if not MiniFiles.close() then
    MiniFiles.open(vim.api.nvim_buf_get_name(0))
  end
end

vim.keymap.set('n', '<leader>e', minifiles_toggle, { noremap = true, silent = true, desc = 'Explorer' })

-- Setup keymaps for mini.pick
vim.keymap.set('n', '<leader>ff', function() MiniPick.builtin.files() end, { noremap = true, silent = true, desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function() MiniPick.builtin.grep_live() end, { noremap = true, silent = true, desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', function() MiniPick.builtin.buffers() end, { noremap = true, silent = true, desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', function() MiniPick.builtin.help_tags() end, { noremap = true, silent = true, desc = 'Help tags' })

-- Search keymaps (leader + s)
vim.keymap.set('n', '<leader>ss', function() MiniPick.builtin.grep_live() end, { noremap = true, silent = true, desc = 'Search in files (grep live)' })
vim.keymap.set('n', '<leader>sf', function() MiniPick.builtin.grep() end, { noremap = true, silent = true, desc = 'Search pattern in files' })

-- ============================================
-- STAGE 7: Extra pickers (deferred, loaded on demand)
-- ============================================
later(function()
  local ok, extra = pcall(require, 'mini.extra')
  if not ok then
    return
  end

  -- Diagnostic picker
  vim.keymap.set('n', '<leader>ld', function()
    extra.pickers.diagnostic()
  end, { noremap = true, silent = true, desc = 'Diagnostics' })

  -- LSP: Document symbols (methods, definitions in current file)
  vim.keymap.set('n', '<leader>ls', function()
    extra.pickers.lsp({ scope = 'document_symbol' })
  end, { noremap = true, silent = true, desc = 'LSP Symbols' })

  -- LSP: Workspace symbols (global search by definition name)
  vim.keymap.set('n', '<leader>lS', function()
    extra.pickers.lsp({ scope = 'workspace_symbol' })
  end, { noremap = true, silent = true, desc = 'LSP Workspace Symbols' })

  -- LSP: References (find all references of symbol under cursor)
  vim.keymap.set('n', '<leader>lr', function()
    extra.pickers.lsp({ scope = 'references' })
  end, { noremap = true, silent = true, desc = 'LSP References' })

  -- LSP: Implementation (find implementations)
  vim.keymap.set('n', '<leader>li', function()
    extra.pickers.lsp({ scope = 'implementation' })
  end, { noremap = true, silent = true, desc = 'LSP Implementation' })

  -- Treesitter: Search symbols in current file by type
  vim.keymap.set('n', '<leader>ft', function()
    extra.pickers.treesitter()
  end, { noremap = true, silent = true, desc = 'Treesitter Symbols' })

  -- Explorer: File/directory browser
  vim.keymap.set('n', '<leader>fe', function()
    extra.pickers.explorer()
  end, { noremap = true, silent = true, desc = 'Explorer' })

  -- Buffer lines: Search lines in all buffers
  vim.keymap.set('n', '<leader>fl', function()
    extra.pickers.buf_lines()
  end, { noremap = true, silent = true, desc = 'Buffer Lines' })

  -- Old files: Recently accessed files
  vim.keymap.set('n', '<leader>fo', function()
    extra.pickers.oldfiles()
  end, { noremap = true, silent = true, desc = 'Old Files' })

  -- History: Command history
  vim.keymap.set('n', '<leader>fH', function()
    extra.pickers.history({ scope = ':' })
  end, { noremap = true, silent = true, desc = 'Command History' })
end)

-- ============================================
-- STAGE 8: mini.clue (after all keymaps loaded)
-- ============================================
later(function()
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
end)
