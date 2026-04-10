-- Global keymaps - Base editor functionality
-- LSP, plugin-specific, and filetype keymaps are defined in their respective config files

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Disable macro recording (q key) - too easy to hit by accident
map('n', 'q', '<Nop>', opts)
map('n', 'Q', '<Nop>', opts)

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

-- Package management - lazy.nvim
map('n', '<leader>pl', ':Lazy<CR>', { noremap = true, silent = true, desc = 'Open Lazy plugin manager' })

-- ============================================================================
-- PLUGIN & LSP KEYMAPS
-- ============================================================================
-- The following keymaps are configured in their respective plugin/config files.
-- Use mini.clue to discover them: press <leader>, g, [, or ] to see hints.

-- File Explorer & Fuzzy Finding:
--   <leader>e          - Open yazi file manager
--   <leader>ff         - Find files (fzf-lua)
--   <leader>fg         - Live grep search (fzf-lua)
--   <leader>fb         - Find in open buffers (fzf-lua)
--   <leader>fh         - Help tags search (fzf-lua)
--   <leader>ft         - Find Treesitter symbols in file (fzf-lua)
--   <leader>fl         - Search buffer lines (fzf-lua)
--   <leader>fo         - Open recent files (fzf-lua)
--   <leader>fH         - Command history search (fzf-lua)
--   <leader>fr         - Resume last picker (fzf-lua)

-- Search (configured in lua/plugins/fzf.lua):
--   <leader>ss         - Search in files (grep live, interactive)
--   <leader>sf         - Search pattern in files (grep, upfront pattern)
--   <leader>sw         - Search word under cursor
--   <leader>sW         - Search WORD under cursor

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

-- NOTE: LSP pickers (<leader>ls, <leader>lS) are now handled by fzf-lua
-- See lua/plugins/fzf.lua for keybindings

-- ============================================================================
-- DIAGNOSTIC MENU (<leader>d)
-- ============================================================================
-- Comprehensive diagnostic features using Neovim's builtin diagnostic API

-- Diagnostic Navigation
map('n', '<leader>dn', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = 'Next diagnostic' })
map('n', '<leader>dp', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = 'Previous diagnostic' })

-- Jump to next/prev by severity
map('n', '<leader>de', function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { noremap = true, silent = true, desc = 'Next error' })

map('n', '<leader>dE', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { noremap = true, silent = true, desc = 'Previous error' })

map('n', '<leader>dw', function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end, { noremap = true, silent = true, desc = 'Next warning' })

map('n', '<leader>dW', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end, { noremap = true, silent = true, desc = 'Previous warning' })

-- NOTE: Diagnostic pickers (<leader>db, <leader>dB) are now handled by fzf-lua
-- See lua/plugins/fzf.lua for keybindings

-- Display diagnostics
map('n', '<leader>dd', function()
  vim.diagnostic.open_float(nil, { scope = 'line' })
end, { noremap = true, silent = true, desc = 'Show line diagnostics' })

map('n', '<leader>dD', function()
  vim.diagnostic.open_float(nil, { scope = 'cursor' })
end, { noremap = true, silent = true, desc = 'Show cursor diagnostics' })

map('n', '<leader>dl', vim.diagnostic.setloclist, { noremap = true, silent = true, desc = 'Diagnostics to location list' })
map('n', '<leader>dq', vim.diagnostic.setqflist, { noremap = true, silent = true, desc = 'Diagnostics to quickfix' })

-- Show diagnostic counts
map('n', '<leader>dc', function()
  local counts = vim.diagnostic.count(0)
  local error_count = counts[vim.diagnostic.severity.ERROR] or 0
  local warn_count = counts[vim.diagnostic.severity.WARN] or 0
  local info_count = counts[vim.diagnostic.severity.INFO] or 0
  local hint_count = counts[vim.diagnostic.severity.HINT] or 0

  local msg = string.format(
    'Diagnostics: E:%d W:%d I:%d H:%d',
    error_count, warn_count, info_count, hint_count
  )
  vim.notify(msg, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Show diagnostic count' })

-- Toggle diagnostic displays
map('n', '<leader>dt', function()
  local config = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_text = not config.virtual_text })
  local status = not config.virtual_text and 'enabled' or 'disabled'
  vim.notify('Virtual text ' .. status, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Toggle virtual text' })

map('n', '<leader>ds', function()
  local config = vim.diagnostic.config()
  local new_value = not config.signs
  vim.diagnostic.config({ signs = new_value })
  local status = new_value and 'enabled' or 'disabled'
  vim.notify('Diagnostic signs ' .. status, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Toggle signs' })

map('n', '<leader>du', function()
  local config = vim.diagnostic.config()
  local new_value = not config.underline
  vim.diagnostic.config({ underline = new_value })
  local status = new_value and 'enabled' or 'disabled'
  vim.notify('Diagnostic underline ' .. status, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Toggle underline' })

-- Toggle all diagnostics on/off
map('n', '<leader>dT', function()
  if vim.g.diagnostics_enabled == nil then
    vim.g.diagnostics_enabled = true
  end

  if vim.g.diagnostics_enabled then
    vim.diagnostic.enable(false)
    vim.g.diagnostics_enabled = false
    vim.notify('Diagnostics disabled', vim.log.levels.INFO)
  else
    vim.diagnostic.enable(true)
    vim.g.diagnostics_enabled = true
    vim.notify('Diagnostics enabled', vim.log.levels.INFO)
  end
end, { noremap = true, silent = true, desc = 'Toggle diagnostics on/off' })

-- Filter diagnostics by severity
map('n', '<leader>df', function()
  vim.ui.select(
    { 'All', 'Errors only', 'Warnings+', 'Info+', 'Hints+' },
    { prompt = 'Filter diagnostics by severity:' },
    function(choice)
      if not choice then return end

      local severity_filter = nil
      if choice == 'Errors only' then
        severity_filter = { min = vim.diagnostic.severity.ERROR }
      elseif choice == 'Warnings+' then
        severity_filter = { min = vim.diagnostic.severity.WARN }
      elseif choice == 'Info+' then
        severity_filter = { min = vim.diagnostic.severity.INFO }
      elseif choice == 'Hints+' then
        severity_filter = { min = vim.diagnostic.severity.HINT }
      end

      vim.diagnostic.config({
        virtual_text = severity_filter and { severity = severity_filter } or true,
        signs = severity_filter and { severity = severity_filter } or true,
      })

      vim.notify('Diagnostics filtered: ' .. choice, vim.log.levels.INFO)
    end
  )
end, { noremap = true, silent = true, desc = 'Filter by severity' })

-- Reset diagnostic configuration to defaults
map('n', '<leader>dr', function()
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
  vim.diagnostic.enable(true)
  vim.g.diagnostics_enabled = true
  vim.notify('Diagnostic config reset to defaults', vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Reset diagnostic config' })

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
--   <Tab> (insert)     - Accept inline suggestion

-- Text Editing & Manipulation (mini.surround, mini.comment):
--   sa                 - Add surround (sa + motion + char)
--   sd                 - Delete surround
--   sr                 - Replace surround
--   gc                 - Toggle comment on line/selection

-- Keybinding Discovery:
--   Press <leader> to see available <leader> bindings with mini.clue
--   Press g to see go-to bindings
--   Press [ or ] for jump navigation options
