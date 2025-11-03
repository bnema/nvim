-- Native Neovim 0.12+ Package Management
-- Uses vim.pack.add{} for packages managed outside of mini.deps
-- Documentation: :help vim.pack.add()

-- ============================================
-- Yazi.nvim - Terminal file manager integration
-- ============================================

-- Mark netrw as loaded so it's not loaded at all
-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
vim.g.loaded_netrwPlugin = 1

-- Add yazi.nvim and its dependencies
vim.pack.add({
  {
    src = 'https://github.com/mikavilpas/yazi.nvim',
    name = 'yazi.nvim',
  }
})

-- Setup yazi on UIEnter for directory handling
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    local yazi_config = require("config.plugins.yazi")
    require("yazi").setup(yazi_config)
  end,
})

-- ============================================
-- Flash.nvim - Navigate your code with search labels
-- ============================================

-- Add Flash.nvim package
vim.pack.add({
  {
    src = 'https://github.com/folke/flash.nvim',
    name = 'flash.nvim',
  }
})

-- Load Flash configuration after plugin is available
vim.schedule(function()
  require('config.plugins.flash')
end)
