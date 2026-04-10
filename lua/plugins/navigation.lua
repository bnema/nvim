-- Navigation plugins: flash.nvim, yazi.nvim
return {
  -- Flash.nvim - Search-based navigation with labels
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("config.plugins.flash")
    end,
  },

  -- Yazi.nvim - Terminal file manager integration
  {
    "mikavilpas/yazi.nvim",
    cmd = "Yazi",
    keys = {
      {
        "<leader>fy",
        function()
          require("yazi").yazi()
        end,
        desc = "Yazi file manager",
      },
    },
    init = function()
      -- Keep netrw disabled so directory startup does not leave a netrw buffer behind.
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
      local yazi_config = require("config.plugins.yazi")
      require("yazi").setup(yazi_config)
    end,
  },
}
