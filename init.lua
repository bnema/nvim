-- Neovim 0.12 Configuration
-- Modern setup using native vim.pack.add() and mini.nvim ecosystem

-- First, setup core settings
require('config.settings')

-- Auto-reload files changed externally (for AI tools, formatters, etc.)
require('config.autoread')

-- Auto-formatting on save
require('config.format')

-- Load native Neovim 0.12+ packages (vim.pack.add)
require('config.native-packages')

-- Global keymaps
require('config.keymaps')

-- Load mini.clue last to ensure all keymaps are discovered
require('config.clue')

-- Load colorscheme
vim.cmd('colorscheme despair')
