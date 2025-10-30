-- Neovim 11.0 Configuration from Scratch
-- Minimal, fast, modern setup using mini.nvim and native LSP

-- Disable netrw (use mini.files instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- First, setup core settings
require('config.settings')

-- Bootstrap mini.deps and plugins
require('config.plugins')

-- Global keymaps
require('config.keymaps')

-- LSP configuration
require('config.lsp')

-- Load colorscheme
vim.cmd('colorscheme despair')
