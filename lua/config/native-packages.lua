-- Native Neovim 0.12+ Package Management
-- Uses vim.pack.add() for all plugins
-- Documentation: :help vim.pack.add()

-- ============================================
-- STAGE 1: Core Dependencies (Immediate)
-- ============================================

-- Add core dependencies
vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/echasnovski/mini.nvim' },
}, { load = false, confirm = false })

-- Load mini.nvim immediately (needed for UI essentials)
vim.cmd.packadd('mini.nvim')

-- ============================================
-- STAGE 2: Flash.nvim - Navigate with search labels
-- ============================================

vim.pack.add({
  { src = 'https://github.com/folke/flash.nvim', name = 'flash.nvim' }
}, { load = false, confirm = false })

-- Load Flash configuration
vim.schedule(function()
  vim.cmd.packadd('flash.nvim')
  require('config.plugins.flash')
end)

-- ============================================
-- STAGE 3: Yazi.nvim - Terminal file manager
-- ============================================

-- Mark netrw as loaded so it's not loaded at all
-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
  { src = 'https://github.com/mikavilpas/yazi.nvim', name = 'yazi.nvim' }
}, { load = false, confirm = false })

-- Setup yazi on UIEnter for directory handling
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.cmd.packadd('yazi.nvim')
    local yazi_config = require("config.plugins.yazi")
    require("yazi").setup(yazi_config)
  end,
})

-- ============================================
-- STAGE 4: LSP Infrastructure (on UIEnter, early)
-- ============================================

vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/williamboman/mason.nvim' },
  { src = 'https://github.com/williamboman/mason-lspconfig.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
}, { load = false, confirm = false })

-- Load LSP infrastructure on UIEnter
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      -- Load LSP plugins
      vim.cmd.packadd('nvim-lspconfig')
      vim.cmd.packadd('mason.nvim')
      vim.cmd.packadd('mason-lspconfig.nvim')
      vim.cmd.packadd('nvim-treesitter')
      vim.cmd.packadd('nvim-treesitter-textobjects')

      -- Load LSP configuration
      require('config.lsp')

      -- Load Copilot native inline completion (requires Neovim 0.12+)
      require('config.plugins.copilot')
    end)
  end,
})

-- ============================================
-- STAGE 5: Editor utilities (deferred)
-- ============================================

vim.pack.add({
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/tpope/vim-sleuth' },
  { src = 'https://github.com/tpope/vim-repeat' },
}, { load = false, confirm = false })

-- Load editor utilities after a short delay
vim.defer_fn(function()
  vim.cmd.packadd('vim-fugitive')
  vim.cmd.packadd('vim-sleuth')
  vim.cmd.packadd('vim-repeat')
end, 100)

-- ============================================
-- STAGE 6: Load mini.nvim plugin configurations
-- ============================================

-- Load mini.* plugin configurations immediately
-- mini.starter with autoopen=true must run before any buffer is created
require('config.plugins.mini')
