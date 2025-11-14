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

-- File Explorer - Yazi terminal file manager
map('n', '<leader>e', function()
  require("yazi").yazi()
end, { noremap = true, silent = true, desc = 'Explorer (yazi)' })

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
-- All yank logic has been moved to config/yank.lua for better organization
local yank = require('config.yank')

map('n', '<leader>yl', yank.yank_line, { noremap = true, silent = true, desc = 'Yank line' })
map('n', '<leader>yd', yank.yank_diagnostic, { noremap = true, silent = true, desc = 'Yank diagnostic' })
map('n', '<leader>yD', yank.yank_diagnostic_with_context, { noremap = true, silent = true, desc = 'Yank diagnostic with context' })
map('n', '<leader>yb', yank.yank_buffer_diagnostics, { noremap = true, silent = true, desc = 'Yank all buffer diagnostics with context' })
map('n', '<leader>yW', yank.yank_workspace_diagnostics, { noremap = true, silent = true, desc = 'Yank all workspace diagnostics with context' })
map('n', '<leader>y', yank.yank_line_with_context, { noremap = true, silent = true, desc = 'Yank line with context' })
map('v', '<leader>y', yank.yank_selection_with_context, { noremap = true, silent = true, desc = 'Yank selection with context' })

-- Package management - Update plugins
map('n', '<leader>pu', ':PackUpdate<CR>', { noremap = true, silent = true, desc = 'Update all packages' })
map('n', '<leader>pU', ':PackUpdateForce<CR>', { noremap = true, silent = true, desc = 'Force update packages' })
map('n', '<leader>pl', ':PackList<CR>', { noremap = true, silent = true, desc = 'List packages' })
map('n', '<leader>ps', ':PackStatus<CR>', { noremap = true, silent = true, desc = 'Check package status' })

-- ============================================================================
-- PLUGIN & LSP KEYMAPS
-- ============================================================================
-- The following keymaps are configured in their respective plugin/config files.
-- Use mini.clue to discover them: press <leader>, g, [, or ] to see hints.

-- File Explorer & Fuzzy Finding (configured in config/plugins/mini.lua):
--   <leader>e          - Toggle mini.files sidebar explorer
--     g. / <C-h>       - Toggle dotfiles visibility (while in mini.files)
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

-- LSP Navigation & Actions:
--   Core navigation (configured in config/lsp.lua):
--     gd               - Go to definition (direct jump or quickfix)
--     gD               - Go to declaration (direct jump or quickfix)
--     gi               - Go to implementation (direct jump or quickfix)
--     gr               - Find references (direct jump or quickfix)
--     gy               - Go to type definition (direct jump or quickfix)
--   LSP actions (configured in config/lsp.lua):
--     <leader>lh       - Show hover documentation
--     <leader>lr       - Rename symbol across codebase
--     <leader>la       - Show code actions (refactoring, fixes)
--     <leader>lf       - Format current buffer
--   LSP pickers (configured below):
--     <leader>ls       - List document symbols (methods/functions in file)
--     <leader>lS       - List workspace symbols (project-wide search)
--     <leader>ld       - List diagnostics (in mini.lua)

-- LSP Pickers (via mini.extra)
map('n', '<leader>ls', function()
  require('mini.extra').pickers.lsp({ scope = 'document_symbol' })
end, { noremap = true, silent = true, desc = 'List document symbols' })

map('n', '<leader>lS', function()
  require('mini.extra').pickers.lsp({ scope = 'workspace_symbol' })
end, { noremap = true, silent = true, desc = 'List workspace symbols' })

-- Toggle gopls parameter name hints (Go-specific) - shows inline like "w:", "node:", "visible:"
map('n', '<leader>lh', function()
  -- Only works for Go files
  if vim.bo.filetype ~= 'go' then
    vim.notify('Parameter hints toggle only works for Go files', vim.log.levels.WARN)
    return
  end

  -- Toggle the global state
  _G.gopls_hints_enabled = not _G.gopls_hints_enabled

  -- Find gopls client
  local clients = vim.lsp.get_clients({ name = 'gopls' })
  if #clients == 0 then
    vim.notify('gopls is not running', vim.log.levels.WARN)
    return
  end

  local client = clients[1]

  -- Update gopls settings
  local new_settings = {
    gopls = {
      hints = {
        parameterNames = _G.gopls_hints_enabled,
      }
    }
  }

  client.config.settings = vim.tbl_deep_extend('force', client.config.settings or {}, new_settings)
  client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })

  local status = _G.gopls_hints_enabled and 'enabled' or 'disabled'
  vim.notify('Gopls parameter hints ' .. status, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Toggle parameter hints (Go)' })

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
