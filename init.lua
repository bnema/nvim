-- Neovim 11.0 Configuration from Scratch
-- Minimal, fast, modern setup using mini.nvim and native LSP

-- Disable netrw (use mini.files instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- First, setup core settings
require('config.settings')

-- Bootstrap mini.deps and plugins
require('config.plugins')

-- Load native Neovim 0.12+ packages (vim.pack.add)
require('config.native-packages')

-- Global keymaps
require('config.keymaps')

-- Load colorscheme
vim.cmd('colorscheme despair')
