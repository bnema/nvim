-- LSP, Treesitter, and Completion plugins
return {
  -- nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("config.lsp")
    end,
  },

  -- lspeek.nvim - Lightweight LSP definition/type previews in floating windows
  {
    "r4ppz/lspeek.nvim",
    cmd = { "LSPeekDef", "LSPeekTypeDef" },
    opts = {
      window = {
        width = 70,
        height = 15,
        border = "single",
      },
      stack_limit = 5,
      select_first = false,
      keymaps = {
        close = "q",
        split = "s",
        vsplit = "v",
        enter = "<CR>",
        tab = "t",
      },
    },
    keys = {
      {
        "gD",
        function()
          require("lspeek").peek_definition()
        end,
        desc = "Peek definition",
      },
      {
        "gY",
        function()
          require("lspeek").peek_type_definition()
        end,
        desc = "Peek type definition",
      },
    },
  },

  -- Mason - Package manager for LSP servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },

  -- Zig filetype, syntax, indentation, and compiler support
  {
    "ziglang/zig.vim",
    ft = { "zig", "zon" },
  },

  -- Treesitter - Syntax highlighting and parsing (main branch rewrite)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("config.plugins.treesitter")
    end,
  },

  -- Treesitter textobjects (main branch)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("config.plugins.treesitter-textobjects")
    end,
  },

  -- blink.cmp - Modern completion engine
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      "saghen/blink.lib",
      "rafamadriz/friendly-snippets",
    },
    build = function()
      require("blink.cmp").build():wait(60000)
    end,
    config = function()
      require("config.plugins.blink")
    end,
  },

  -- Friendly snippets
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },

  -- Go language support
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gowork", "gotmpl" },
    dependencies = {
      "ray-x/guihua.lua",
    },
    config = function()
      require("config.plugins.go")
    end,
  },

  -- Guihua - UI utilities for Go support
  {
    "ray-x/guihua.lua",
    lazy = true,
    build = "cd lua/fzy && make",
  },
}
