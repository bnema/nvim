-- blink.cmp - Performant, batteries-included completion for Neovim
-- https://github.com/saghen/blink.cmp

require('blink.cmp').setup({
  -- Keymap preset: 'default' uses C-y to accept (similar to built-in completion)
  -- Other options: 'super-tab' (Tab to accept), 'enter' (Enter to accept), 'none'
  keymap = { preset = 'default' },

  appearance = {
    -- Use 'mono' for Nerd Font Mono (default) or 'normal' for Nerd Font
    nerd_font_variant = 'mono'
  },

  -- Sources for completion
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },

    -- Per-filetype configuration
    per_filetype = {},

    providers = {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        -- Enable buffer fallback when LSP doesn't return items
        fallbacks = { 'buffer' },
        enabled = true,
        timeout_ms = 2000,
        score_offset = 0,
      },

      path = {
        module = 'blink.cmp.sources.path',
        score_offset = 3,
        opts = {
          trailing_slash = true,
          label_trailing_slash = true,
          get_cwd = function(context)
            return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
          end,
          show_hidden_files_by_default = false,
        }
      },

      snippets = {
        module = 'blink.cmp.sources.snippets',
        score_offset = -1,
        opts = {
          friendly_snippets = true,
          search_paths = { vim.fn.stdpath('config') .. '/snippets' },
          global_snippets = { 'all' },
        }
      },

      buffer = {
        module = 'blink.cmp.sources.buffer',
        score_offset = -3,
        opts = {
          -- Get all visible buffers
          get_bufnrs = function()
            return vim
              .iter(vim.api.nvim_list_wins())
              :map(function(win) return vim.api.nvim_win_get_buf(win) end)
              :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
              :totable()
          end,
        }
      },
    },
  },

  -- Completion behavior
  completion = {
    -- Documentation window
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = {
        border = 'rounded',
      }
    },

    -- Ghost text preview
    ghost_text = {
      enabled = true,
    },

    -- Completion menu
    menu = {
      -- Auto-show menu when typing
      auto_show = true,

      draw = {
        -- Align completion items
        align_to = 'label',
        padding = 1,
        gap = 1,

        -- Columns to display: icon + label with description
        columns = {
          { 'kind_icon' },
          { 'label', 'label_description', gap = 1 },
          { 'source_name' }
        },

        -- Use treesitter for LSP syntax highlighting
        treesitter = { 'lsp' },
      },
    },

    -- List behavior
    list = {
      selection = {
        -- Preselect first item but don't auto-insert
        preselect = true,
        auto_insert = false,
      },
    },

    -- Trigger configuration
    trigger = {
      prefetch_on_insert = true,
      show_in_snippet = true,
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert = false,
      -- Don't block on these characters
      show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
    },

    -- Accept configuration
    accept = {
      -- Create undo point when accepting
      create_undo_point = true,
      -- Auto-brackets for functions
      auto_brackets = {
        enabled = true,
        default_brackets = { '(', ')' },
      },
    },
  },

  -- Signature help
  signature = {
    enabled = true,
    window = {
      border = 'rounded',
    }
  },

  -- Snippets configuration using Neovim's native snippet support
  snippets = {
    expand = function(snippet) vim.snippet.expand(snippet) end,
    active = function(filter) return vim.snippet.active(filter) end,
    jump = function(direction) vim.snippet.jump(direction) end,
  },

  -- Fuzzy matching - using Lua implementation
  -- Native package management doesn't support automatic binary downloads
  -- Lua implementation is still fast and requires no external dependencies
  fuzzy = {
    implementation = "lua",
  },
})

-- Store capabilities globally so LSP configs can access them
_G.blink_cmp_capabilities = require('blink.cmp').get_lsp_capabilities()
