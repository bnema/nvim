-- Git integration plugins
return {
  -- snacks.nvim - Lazygit integration (handles all git operations)
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    keys = {
      { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gL", function() Snacks.lazygit.log() end, desc = "Lazygit log" },
    },
    opts = {
      lazygit = {
        -- lazygit configuration
        -- theme will be auto-configured based on colorscheme
      },
    },
  },

  -- gitsigns.nvim - Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- diffview.nvim - Git diff viewer (for specialized diff viewing)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", ":DiffviewOpen<CR>", desc = "Open diffview" },
      { "<leader>gV", ":DiffviewClose<CR>", desc = "Close diffview" },
      { "<leader>gf", ":DiffviewFileHistory %<CR>", desc = "File history (current)" },
      { "<leader>gF", ":DiffviewFileHistory<CR>", desc = "File history (all)" },
    },
    config = function()
      require("config.plugins.diffview")
    end,
  },
}
