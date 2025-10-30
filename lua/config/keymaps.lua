-- Global keymaps - Base editor functionality
-- LSP, plugin-specific, and filetype keymaps are defined in their respective config files

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Window navigation - Ctrl + hjkl to move between splits
map('n', '<C-h>', '<C-w>h', opts)  -- Focus left split
map('n', '<C-j>', '<C-w>j', opts)  -- Focus bottom split
map('n', '<C-k>', '<C-w>k', opts)  -- Focus top split
map('n', '<C-l>', '<C-w>l', opts)  -- Focus right split

-- Window resizing - Ctrl + arrows
map('n', '<C-Up>', ':resize +2<CR>', opts)           -- Increase height
map('n', '<C-Down>', ':resize -2<CR>', opts)         -- Decrease height
map('n', '<C-Left>', ':vertical resize -2<CR>', opts) -- Decrease width
map('n', '<C-Right>', ':vertical resize +2<CR>', opts) -- Increase width

-- Buffer navigation - Shift + hl for quick buffer switching
map('n', '<S-h>', ':bprevious<CR>', opts)  -- Previous buffer
map('n', '<S-l>', ':bnext<CR>', opts)      -- Next buffer

-- Buffer management (via mini.bufremove)
map('n', '<leader>bd', function() require('mini.bufremove').delete(0, false) end, { noremap = true, silent = true, desc = 'Delete buffer' })
map('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { noremap = true, silent = true, desc = 'Delete buffer (force)' })
map('n', '<leader>bw', function() require('mini.bufremove').wipeout(0, false) end, { noremap = true, silent = true, desc = 'Wipeout buffer' })
map('n', '<leader>bW', function() require('mini.bufremove').wipeout(0, true) end, { noremap = true, silent = true, desc = 'Wipeout buffer (force)' })

-- Clear search highlight on Escape
map('n', '<Esc>', ':nohlsearch<CR>', opts)

-- Smart indenting - maintain indent level when adjusting in visual mode
map('v', '<', '<gv', opts)  -- Indent less
map('v', '>', '>gv', opts)  -- Indent more

-- Move lines - Alt + jk to move lines up/down
map('n', '<A-j>', ':m .+1<CR>==', opts)            -- Move line down (normal)
map('n', '<A-k>', ':m .-2<CR>==', opts)            -- Move line up (normal)
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi', opts)    -- Move line down (insert)
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi', opts)    -- Move line up (insert)
map('v', '<A-j>', ':m .+1<CR>gv=gv', opts)        -- Move lines down (visual)
map('v', '<A-k>', ':m .-2<CR>gv=gv', opts)        -- Move lines up (visual)

-- File operations - Save, quit, and combined
map('n', '<leader>w', ':write<CR>', { noremap = true, silent = true, desc = 'Save file' })
map('n', '<leader>q', ':quit<CR>', { noremap = true, silent = true, desc = 'Quit' })
map('n', '<leader>qq', ':quit!<CR>', { noremap = true, silent = true, desc = 'Quit! (force)' })
map('n', '<leader>qw', ':wq<CR>', { noremap = true, silent = true, desc = 'Write & quit' })

-- Split window management - Create and close splits
map('n', '<leader>|', ':vsplit<CR>', { noremap = true, silent = true, desc = 'Split vertically' })
map('n', '<leader>-', ':split<CR>', { noremap = true, silent = true, desc = 'Split horizontally' })
map('n', '<leader>c', ':close<CR>', { noremap = true, silent = true, desc = 'Close window' })

-- Tab page management - Create, navigate, and close tabs
map('n', '<leader>tn', ':tabnew<CR>', { noremap = true, silent = true, desc = 'New tab' })
map('n', '<leader>tc', ':tabclose<CR>', { noremap = true, silent = true, desc = 'Close tab' })
map('n', '<leader>th', ':tabprevious<CR>', { noremap = true, silent = true, desc = 'Previous tab' })
map('n', '<leader>tl', ':tabnext<CR>', { noremap = true, silent = true, desc = 'Next tab' })
map('n', '<leader>to', ':tabonly<CR>', { noremap = true, silent = true, desc = 'Only this tab' })

-- Quick tab navigation - Auto-create new tab when at the last tab
map('n', '<Tab>', function()
  local tab_count = vim.fn.tabpagenr('$')
  local current_tab = vim.fn.tabpagenr()
  if current_tab == tab_count then
    vim.cmd('tabnew')  -- Create new tab if at the end
  else
    vim.cmd('tabnext')  -- Go to next tab
  end
end, { noremap = true, silent = true, desc = 'Next tab or create' })

map('n', '<S-Tab>', ':tabprevious<CR>', { noremap = true, silent = true, desc = 'Previous tab' })

-- ============================================================================
-- PLUGIN & LSP KEYMAPS
-- ============================================================================
-- The following keymaps are configured in their respective plugin/config files.
-- Use mini.clue to discover them: press <leader>, g, [, or ] to see hints.

-- File Explorer & Fuzzy Finding (configured in config/plugins/mini.lua):
--   <leader>e          - Toggle mini.files sidebar explorer
--   <leader>ff         - Find files (mini.pick)
--   <leader>fg         - Live grep search (mini.pick)
--   <leader>fb         - Find in open buffers (mini.pick)
--   <leader>fh         - Help tags search (mini.pick)
--   <leader>ft         - Find Treesitter symbols in file (mini.extra)
--   <leader>fe         - File explorer picker (mini.extra)
--   <leader>fl         - Search buffer lines (mini.extra)
--   <leader>fo         - Open recent files (mini.extra)
--   <leader>fH         - Command history search (mini.extra)
--   <leader>fd         - Show diagnostics (mini.extra)

-- LSP Navigation & Actions (configured in config/lsp.lua):
--   gd                 - Go to symbol definition
--   gD                 - Go to symbol declaration
--   gi                 - Go to symbol implementation
--   gr                 - Find symbol references
--   gy                 - Go to symbol type definition
--   <leader>lh         - Show hover documentation
--   <leader>ls         - List document symbols (methods/functions in file)
--   <leader>lS         - List workspace symbols (project-wide search)
--   <leader>lr         - Rename symbol across codebase
--   <leader>li         - Find symbol implementations
--   <leader>la         - Show code actions (refactoring, fixes)
--   <leader>lf         - Format current buffer

-- Copilot AI Completion (configured in config/lsp.lua):
--   <M-]>              - Accept next inline suggestion
--   <M-[>              - Accept previous inline suggestion

-- Text Editing & Manipulation (mini.surround, mini.comment):
--   sa                 - Add surround (sa + motion + char)
--   sd                 - Delete surround
--   sr                 - Replace surround
--   gc                 - Toggle comment on line/selection

-- Keybinding Discovery:
--   Press <leader> to see available <leader> bindings with mini.clue
--   Press g to see go-to bindings
--   Press [ or ] for jump navigation options
