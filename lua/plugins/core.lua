-- Core plugins: dependencies, icons, mini.nvim, colorschemes
return {
  -- Colorschemes (lazy-loaded on demand by :colorscheme / :Theme)
  {
    "Mofiqul/dracula.nvim",
    lazy = true,
    opts = {
      transparent_bg = false,
      show_end_of_buffer = false,
    },
    config = function(_, opts)
      require("dracula").setup(opts)
    end,
  },
  {
    "bnema/despair-theme",
    lazy = true,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
  },
  {
    "datsfilipe/vesper.nvim",
    lazy = true,
    opts = {
      transparent = false,
    },
    config = function(_, opts)
      require("vesper").setup(opts)
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
