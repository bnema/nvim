-- Native Neovim 0.12+ Package Management
-- Uses vim.pack.add{} for packages managed outside of mini.deps
-- Documentation: :help vim.pack.add()

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
