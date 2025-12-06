-- Core plugins: dependencies, icons, mini.nvim, colorscheme
return {
  -- Colorscheme (load first, highest priority)
  {
    "bnema/despair-theme",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("despair")
    end,
  },

  -- Plenary - Lua utilities (loaded as dependency)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- File icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- mini.nvim - Modular UI/utility components
  {
    "echasnovski/mini.nvim",
    lazy = false,
    priority = 100,
    config = function()
      require("config.plugins.mini")
    end,
  },
}
