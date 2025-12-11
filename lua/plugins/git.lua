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
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          -- Toggle inline blame with <leader>gb
          map("n", "<leader>gb", gs.toggle_current_line_blame, "GitSigns: toggle blame")
        end,
      })
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

  -- octo.nvim - GitHub issues/PRs from inside Neovim
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    keys = {
      { "<leader>op", "<cmd>Octo pr list<CR>", desc = "Octo: list PRs" },
      { "<leader>oi", "<cmd>Octo issue list<CR>", desc = "Octo: list issues" },
      { "<leader>or", "<cmd>Octo review start<CR>", desc = "Octo: start review" },
      { "<leader>oR", "<cmd>Octo review resume<CR>", desc = "Octo: resume review" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      picker = "fzf-lua",
    },
  },
}
