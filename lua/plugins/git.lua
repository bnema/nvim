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
      explorer = {
        -- Keep explorer opt-in via keymaps; do not auto-open on directory start.
        replace_netrw = false,
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

  -- codediff.nvim - VSCode-style side-by-side diff (renamed from vscode-diff.nvim)
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>gv", "<cmd>CodeDiff<CR>", desc = "Open diff view" },
      { "<leader>gV", "<cmd>CodeDiff file HEAD<CR>", desc = "Diff current file vs HEAD" },
      { "<leader>gD", function()
        local base = require("config.git").get_origin_base_branch()
        vim.cmd("CodeDiff " .. base .. "...")
      end, desc = "Diff branch vs base (PR view)" },
    },
    opts = {
      highlights = require("config.theme").codediff_highlights,
      diff = {
        layout = "inline",
      },
      explorer = {
        width = 25,
      },
      keymaps = {
        view = {
          quit = "q",
          toggle_explorer = "<leader>e",
          focus_explorer = "<leader>E",
          next_hunk = "]c",
          prev_hunk = "[c",
          next_file = "]f",
          prev_file = "[f",
        },
        explorer = {
          select = "<CR>",
          hover = "K",
          refresh = "R",
        },
      },
    },
    config = function(_, opts)
      require("codediff").setup(opts)
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
