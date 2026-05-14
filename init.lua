-- Neovim Configuration
-- Modern setup using lazy.nvim and mini.nvim ecosystem

-- First, setup core settings (includes mapleader)
require('config.settings')

-- Auto-reload files changed externally (for AI tools, formatters, etc.)
require('config.autoread')

-- Auto-formatting on save
require('config.format')

-- Load lazy.nvim plugin manager
require('config.lazy')

-- Apply the selected colorscheme (defaults to Vesper, falls back if unavailable)
require('config.theme').setup()

-- Global keymaps
require('config.keymaps')

-- Load mini.clue last to ensure all keymaps are discovered
require('config.clue')
