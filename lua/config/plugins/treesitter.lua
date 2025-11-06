-- Treesitter Configuration
-- Enable syntax highlighting and other treesitter features

require('nvim-treesitter.configs').setup({
  -- Ensure these parsers are installed
  ensure_installed = {
    'lua',
    'vim',
    'vimdoc',
    'query',
    'go',
    'python',
    'javascript',
    'typescript',
    'html',
    'css',
    'json',
    'bash',
    'markdown',
    'markdown_inline',
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- Enable treesitter-based syntax highlighting
  highlight = {
    enable = true,
    -- Disable vim syntax highlighting to avoid conflicts
    additional_vim_regex_highlighting = false,
  },

  -- Enable treesitter-based indentation
  indent = {
    enable = true,
  },

  -- Enable incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      node_incremental = '<CR>',
      scope_incremental = '<TAB>',
      node_decremental = '<S-TAB>',
    },
  },

  -- Enable treesitter textobjects (requires nvim-treesitter-textobjects)
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']f'] = '@function.outer',
        [']c'] = '@class.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[c'] = '@class.outer',
      },
    },
  },
})
