-- nvim-scrollbar configuration
-- Extensible scrollbar with diagnostics, git signs, and cursor position

-- Setup gitsigns first (required for git integration in scrollbar)
require('gitsigns').setup({
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
})

-- Setup scrollbar with gitsigns integration
require("scrollbar").setup({
  show = true,
  show_in_active_only = false,
  set_highlights = true,
  folds = 1000,
  max_lines = false,
  hide_if_all_visible = false,
  throttle_ms = 100,
  handle = {
    text = " ",
    blend = 30,
    color = nil,
    color_nr = nil,
    highlight = "CursorColumn",
    hide_if_all_visible = true,
  },
  marks = {
    Cursor = {
      text = "•",
      priority = 0,
      highlight = "Normal",
    },
    Search = {
      text = { "-", "=" },
      priority = 1,
      highlight = "Search",
    },
    Error = {
      text = { "-", "=" },
      priority = 2,
      highlight = "DiagnosticVirtualTextError",
    },
    Warn = {
      text = { "-", "=" },
      priority = 3,
      highlight = "DiagnosticVirtualTextWarn",
    },
    Info = {
      text = { "-", "=" },
      priority = 4,
      highlight = "DiagnosticVirtualTextInfo",
    },
    Hint = {
      text = { "-", "=" },
      priority = 5,
      highlight = "DiagnosticVirtualTextHint",
    },
    Misc = {
      text = { "-", "=" },
      priority = 6,
      highlight = "Normal",
    },
    GitAdd = {
      text = "┆",
      priority = 7,
      highlight = "GitSignsAdd",
    },
    GitChange = {
      text = "┆",
      priority = 7,
      highlight = "GitSignsChange",
    },
    GitDelete = {
      text = "▁",
      priority = 7,
      highlight = "GitSignsDelete",
    },
  },
  excluded_buftypes = {
    "terminal",
  },
  excluded_filetypes = {
    "blink-cmp-menu",
    "cmp_docs",
    "cmp_menu",
    "DressingInput",
    "dropbar_menu",
    "dropbar_menu_fzf",
    "noice",
    "prompt",
    "TelescopePrompt",
  },
  autocmd = {
    render = {
      "BufWinEnter",
      "TabEnter",
      "TermEnter",
      "WinEnter",
      "CmdwinLeave",
      "TextChanged",
      "VimResized",
      "WinScrolled",
    },
    clear = {
      "BufWinLeave",
      "TabLeave",
      "TermLeave",
      "WinLeave",
    },
  },
  handlers = {
    cursor = true,
    diagnostic = true,
    gitsigns = true,  -- Enable gitsigns integration
    handle = true,
    search = true,    -- Enable search integration with nvim-hlslens
    ale = false,      -- Requires ALE (not installed)
  },
})

-- Enable gitsigns handler for scrollbar
require("scrollbar.handlers.gitsigns").setup()

-- Enable search handler for scrollbar (integrates with nvim-hlslens)
require("scrollbar.handlers.search").setup({
  -- hlslens config overrides (can be empty to use defaults)
})

return {}
