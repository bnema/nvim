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

-- Tab page navigation - Shift + hl for quick tab switching
map('n', '<S-h>', ':tabprevious<CR>', opts)  -- Previous tab page
map('n', '<S-l>', ':tabnext<CR>', opts)      -- Next tab page

-- Buffer management (via mini.bufremove)
map('n', '<leader>bN', ':enew<CR>', { noremap = true, silent = true, desc = 'New buffer' })
map('n', '<leader>bd', function() require('mini.bufremove').delete(0, false) end, { noremap = true, silent = true, desc = 'Delete buffer' })
map('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { noremap = true, silent = true, desc = 'Delete buffer (force)' })
map('n', '<leader>bw', function() require('mini.bufremove').wipeout(0, false) end, { noremap = true, silent = true, desc = 'Wipeout buffer' })
map('n', '<leader>bW', function() require('mini.bufremove').wipeout(0, true) end, { noremap = true, silent = true, desc = 'Wipeout buffer (force)' })

-- Buffer navigation via leader+b menu
map('n', '<leader>bn', ':bnext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
map('n', '<leader>bb', ':bprevious<CR>', { noremap = true, silent = true, desc = 'Back/previous buffer' })

-- Quick buffer switching by number (1-9, 0 for buffer 10)
for i = 1, 9 do
  map('n', '<leader>b' .. i, ':buffer ' .. i .. '<CR>', { noremap = true, silent = true, desc = 'Buffer ' .. i })
end
map('n', '<leader>b0', ':buffer 10<CR>', { noremap = true, silent = true, desc = 'Buffer 10' })

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
map('n', '<leader>qa', ':quitall!<CR>', { noremap = true, silent = true, desc = 'Quit all!' })
map('n', '<leader>qq', ':quit!<CR>', { noremap = true, silent = true, desc = 'Quit!' })
map('n', '<leader>qb', ':bdelete!<CR>', { noremap = true, silent = true, desc = 'Close buffer!' })
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

-- Buffer navigation - Tab/Shift-Tab for ergonomic buffer switching
map('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
map('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })

-- Yank operations - Copy special content to clipboard
map('n', '<leader>yl', function()
  local line = vim.fn.getline('.')
  vim.fn.setreg('+', line)
  vim.notify('Yanked line to clipboard', vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Yank line' })

map('n', '<leader>yd', function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
  if #diagnostics == 0 then
    vim.notify('No diagnostics on current line', vim.log.levels.WARN)
    return
  end
  -- Concatenate all diagnostic messages for the line
  local messages = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(messages, diag.message)
  end
  local text = table.concat(messages, '\n')
  vim.fn.setreg('+', text)
  vim.notify('Yanked diagnostic(s) to clipboard', vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Yank diagnostic line' })

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

-- Search (configured in config/plugins/mini.lua):
--   <leader>ss         - Search in files (grep live, interactive)
--   <leader>sf         - Search pattern in files (grep, upfront pattern)

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
