-- Configure mini.nvim modules

-- mini.icons - File icons
require('mini.icons').setup()

-- mini.statusline - Statusline
require('mini.statusline').setup()

-- mini.tabline - Buffer tabs at the top
require('mini.tabline').setup()

-- mini.bufremove - Buffer management (delete/wipeout buffers)
require('mini.bufremove').setup()

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

-- mini.notify - Notifications
require('mini.notify').setup()

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
        border = 'single',
      }
    end,
  },
})

-- mini.align - Text alignment
require('mini.align').setup()

-- mini.starter is configured in plugins.lua (needs to load before VimEnter)

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
    { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
    { mode = 'n', keys = '<Leader>f', desc = '+Find' },
    { mode = 'n', keys = '<Leader>l', desc = '+LSP' },
    { mode = 'n', keys = '<Leader>q', desc = '+Quit' },
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
      border = 'rounded',
      width = 'auto',
    },
    scroll_down = '<C-d>',
    scroll_up = '<C-u>',
  },
})

-- Setup keymaps for mini.files
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

-- Enhanced search with mini.extra pickers
local function setup_extra_pickers()
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
end

setup_extra_pickers()
