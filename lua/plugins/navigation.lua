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
        "<leader>e",
        function()
          require("yazi").yazi()
        end,
        desc = "Explorer (yazi)",
      },
    },
    init = function()
      -- Mark netrw as loaded so it's not loaded at all
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
      local yazi_config = require("config.plugins.yazi")
      require("yazi").setup(yazi_config)
    end,
  },
}
