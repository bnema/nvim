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
      { "<leader>gD", "<cmd>CodeDiff main...<CR>", desc = "Diff branch vs main (PR view)" },
    },
    opts = {
      keymaps = {
        view = {
          quit = "q",
          toggle_explorer = "<leader>b",
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

      -- Auto-switch to inline layout when window is too narrow for side-by-side
      -- Toggle back with 't' if you want to force side-by-side
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffOpen",
        group = vim.api.nvim_create_augroup("CodediffAutoLayout", { clear = true }),
        callback = function(ev)
          local min_width = 140
          if vim.o.columns < min_width then
            local tabpage = ev.data.tabpage
            if tabpage then
              local view = require("codediff.ui.view")
              if view.get_current_layout(tabpage) == "side-by-side" then
                view.toggle_layout(tabpage)
              end
            end
          end
        end,
      })
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
