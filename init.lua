-- Neovim 11.0 Configuration from Scratch
-- Minimal, fast, modern setup using mini.nvim and native LSP

-- netrw is enabled by default for directory browsing

-- First, setup core settings
require('config.settings')

-- Auto-reload files changed externally (for AI tools, formatters, etc.)
require('config.autoread')

-- Auto-formatting on save
require('config.format')

-- Bootstrap mini.deps and plugins
require('config.plugins')

-- Load native Neovim 0.12+ packages (vim.pack.add)
require('config.native-packages')

-- Global keymaps
require('config.keymaps')

-- Load colorscheme
vim.cmd('colorscheme despair')
