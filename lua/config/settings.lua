-- Core Neovim settings and options
-- Configures UI, indentation, search behavior, and editor preferences

-- Leader keys for custom keybindings
vim.g.mapleader = ' '           -- Space as primary leader
vim.g.maplocalleader = '\\'     -- Backslash as buffer-local leader

-- Disable space's default behavior (move right) in normal/visual mode
-- This prevents conflicts with the leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Options
local opt = vim.opt

-- UI - Visual presentation and layout
opt.number = true           -- Show absolute line numbers
opt.relativenumber = true   -- Show relative line numbers for quick navigation
opt.cursorline = true       -- Highlight the current line for visibility
opt.cmdheight = 0           -- Hide command line until needed (less clutter)
opt.signcolumn = 'yes'      -- Always reserve space for error/warning signs
opt.shortmess:append("I")   -- Hide the Neovim intro message on startup
opt.list = true             -- Visualize whitespace characters for clarity
opt.listchars = {
  tab = '▸ ',
  trail = '·',
  nbsp = '·',
}

-- Indentation - Consistent spacing (2 spaces)
opt.expandtab = true        -- Convert tabs to spaces
opt.shiftwidth = 2          -- Indentation level for << and >>
opt.tabstop = 2             -- Visual width of a tab character
opt.softtabstop = 2         -- Spaces inserted when pressing Tab key

-- Search - Smart searching with highlighting
opt.ignorecase = true       -- Case-insensitive search by default
opt.smartcase = true        -- Case-sensitive only if uppercase in search
opt.hlsearch = true         -- Highlight all matches in the buffer
opt.incsearch = true        -- Show matches as you type

-- Behavior - Editor interaction preferences
opt.mouse = 'a'             -- Enable mouse for selection and scrolling
opt.clipboard = 'unnamedplus' -- Sync with system clipboard
opt.splitright = true       -- New vertical splits appear on the right
opt.splitbelow = true       -- New horizontal splits appear below
opt.scrolloff = 8           -- Keep 8 lines visible when scrolling vertically
opt.sidescrolloff = 8       -- Keep 8 columns visible when scrolling horizontally
opt.wrap = true             -- Wrap long lines in the display
opt.breakindent = true      -- Wrapped lines maintain original indentation level

-- Performance - Speed and responsiveness
opt.undofile = true         -- Persist undo history across sessions
opt.updatetime = 250        -- Milliseconds before triggering CursorHold event
opt.timeoutlen = 300        -- Milliseconds to wait for mapped sequence completion
opt.termguicolors = true    -- Use 24-bit RGB colors in terminal

-- Appearance - Theme and visual elements
opt.background = 'dark'     -- Configure for dark background
opt.fillchars = {
  foldopen = '\u{e234}',   -- Nerd font fold open icon (chevron-down)
  foldclose = '\u{e236}',  -- Nerd font fold close icon (chevron-right)
  fold = '\u{e237}',       -- Nerd font folded line indicator
  foldsep = '\u{e238}',    -- Nerd font fold separator
  diff = '─',              -- Character for diff sections
  eob = ' ',               -- End-of-buffer (empty space)
}
