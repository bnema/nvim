-- Core plugins: dependencies, icons, mini.nvim, colorscheme
return {
  -- Colorscheme (load first, highest priority)
  {
    "bnema/despair-theme",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("despair")

      -- Inline completion hint visibility (Copilot native LSP)
      local function set_compl_hl()
        vim.api.nvim_set_hl(0, 'ComplHint', { fg = '#6c7a89', bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'ComplHintMore', { fg = '#5d6d7e', bg = 'NONE' })
      end
      set_compl_hl()
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = 'despair',
        callback = set_compl_hl,
      })
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
