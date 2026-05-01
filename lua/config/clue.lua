-- mini.clue - Keybinding hints
-- Loaded last to ensure all keymaps are registered before discovery

-- Wait for all keymaps (including LSP) to be registered
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
    { mode = 'n', keys = '<Leader>c', desc = 'Close window' },
    { mode = 'n', keys = '<Leader>d', desc = 'Diagnostic' },
    { mode = 'n', keys = '<Leader>e', desc = 'Explorer (root)' },
    { mode = 'n', keys = '<Leader>f', desc = 'Find' },
    { mode = 'n', keys = '<Leader>g', desc = 'Git' },
    { mode = 'n', keys = '<Leader>l', desc = 'LSP' },
    { mode = 'n', keys = '<Leader>p', desc = 'Pi' },
    { mode = 'x', keys = '<Leader>p', desc = 'Pi' },
    { mode = 'n', keys = '<Leader>q', desc = 'Quit' },
    { mode = 'n', keys = '<Leader>s', desc = 'Search' },
    { mode = 'n', keys = '<Leader>t', desc = 'Tabs' },
    { mode = 'n', keys = '<Leader>w', desc = 'Save' },
    { mode = 'n', keys = '<Leader>y', desc = 'Yank' },
    { mode = 'n', keys = '<Leader>|', desc = 'Split vertically' },
    { mode = 'n', keys = '<Leader>-', desc = 'Split horizontally' },

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
