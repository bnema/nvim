-- Editor utility plugins
return {
  -- vim-sleuth - Auto-indent detection
  {
    "tpope/vim-sleuth",
    event = "VeryLazy",
  },

  -- vim-repeat - Enhanced repeat command
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- nvim-hlslens - Search result highlighting
  {
    "kevinhwang91/nvim-hlslens",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("hlslens").setup()
    end,
  },

  -- nvim-scrollbar - Scrollbar with integration
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "kevinhwang91/nvim-hlslens",
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("config.plugins.scrollbar")
    end,
  },
}
