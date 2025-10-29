-- Flash.nvim - Navigate your code with search labels
-- A Neovim plugin for fast navigation using search labels
-- https://github.com/folke/flash.nvim

-- ============================================
-- Configuration Options (All Defaults)
-- ============================================

local config = {
  -- Labels to use for search jumps
  -- Characters that appear near the beginning of the list are prioritized
  labels = "asdfghjklqwertyuiopzxcvbnm",

  -- When true, search will continue after pressing enter
  search = {
    -- Search mode: "search" (default /), "fuzzy" (partial matches), "exact" (only exact matches)
    mode = "exact",
    -- Behavior when search pattern is incremented (default: move cursor to next match)
    incremental = false,
    -- Maximum number of lines to search in forward/backward direction
    -- Set to false to disable forward/backward direction
    forward = true,
    -- Wrap search around buffer edges
    wrap = true,
    ---@type Flash.Pattern.Mode
    -- Additional pattern options:
    -- - "exact": exact match only
    -- - "search": default vim search
    -- - "fuzzy": fuzzy match
    -- - "regex": regex pattern
    multi_window = true,  -- Search in all windows
    -- Exclude certain filetypes/buftypes from search
    exclude = {
      "notify",
      "cmp_menu",
      "noice",
      "flash_prompt",
      function(win)
        -- Exclude non-focusable windows
        return not vim.api.nvim_win_get_config(win).focusable
      end,
    },
    -- Trigger characters for automatic label mode
    trigger = "",
    -- Maximum number of matches to show (false for unlimited)
    max_length = false,
  },

  -- Jump mode configuration
  jump = {
    -- Jump on partial input match (automatically jump if only one match)
    jumplist = true,  -- Save position to jumplist
    pos = "start",    -- Cursor position: "start", "end", "range"
    -- When false, don't jump on the first match
    offset = nil,     -- Offset the position (0 for exact, 1 for after, etc)
    -- Automatically jump when there's only one match
    autojump = false,
    -- Include current position in jump list
    inclusive = nil,
    -- Clear highlight after jump
    nohlsearch = false,
    -- Register for storing jump position (set to false to disable)
    register = false,
  },

  -- Label appearance and behavior
  label = {
    -- Allow uppercase labels (when true, labels are case-sensitive)
    uppercase = true,
    -- Add a label for the first match in the window
    after = true,        -- Show label after match
    before = false,      -- Show label before match
    -- Show labels in the inline virtual text
    inline = false,
    -- Minimum pattern length to show labels (decrease for instant labels)
    min_pattern_length = 0,
    -- Enable rainbow coloring of labels
    rainbow = {
      enabled = false,   -- Disable rainbow labels by default
      -- Rainbow color shade level (1-9)
      shade = 5,
    },
    -- Label format function (can customize how labels appear)
    ---@type nil|Flash.Format
    format = nil,
    -- Reuse labels that are already present on screen
    reuse = "lowercase",  -- "all", "lowercase", "none"
    -- Distance priorities: lower numbers = higher priority
    -- Labels closer to cursor get prioritized
    distance = true,
    -- Minimum distance to show labels
    current = true,
    -- Show label after end of match (useful for operators)
    style = "overlay",    -- "eol", "overlay", "inline"
  },

  -- Highlight groups for matches
  highlight = {
    -- Show backdrop for highlighted matches
    backdrop = true,
    -- Highlight groups for different match types
    groups = {
      match = "FlashMatch",      -- Matched text
      current = "FlashCurrent",  -- Current match
      backdrop = "FlashBackdrop", -- Background dimming
      label = "FlashLabel",      -- Label text
    },
  },

  -- Action to perform when a label is selected
  action = nil,  -- nil = jump, function(match, state) for custom behavior

  -- Pattern to match (used by some modes)
  pattern = "",

  -- Continue search after selecting a label
  continue = false,

  -- Configuration for specific modes
  modes = {
    -- Configuration for `s` - standard search
    search = {
      enabled = true,  -- Enable flash when searching with `/` or `?`
      highlight = { backdrop = false },
      jump = { history = true, register = true, nohlsearch = true },
      search = {
        -- Include forward searching when pressing /
        forward = true,
        -- Allow multi-window searching
        multi_window = true,
        -- Wrap around buffer
        wrap = true,
        -- Incremental search
        incremental = false,
      },
    },

    -- Configuration for `f`, `F`, `t`, `T` motions
    char = {
      enabled = true,
      -- Configure keys for char search
      keys = { "f", "F", "t", "T" },
      search = { wrap = false },
      highlight = { backdrop = true },
      jump = { register = false },
      -- Display labels in char search
      label = { exclude = "hjkliardc" },
      -- Character-specific options
      char_actions = function(motion)
        return {
          [";"] = "next",     -- `;` for next match
          [","] = "prev",     -- `,` for previous match
          -- Show character count in label
          [motion:lower()] = "next",
          [motion:upper()] = "prev",
        }
      end,
      -- Multi-line behavior for f/t motions
      multi_line = true,
      -- Configuration for autohide
      autohide = false,
      -- Jump to first match immediately
      jump_labels = false,
    },

    -- Treesitter search mode (text objects)
    treesitter = {
      labels = "abcdefghijklmnopqrstuvwxyz",
      jump = { pos = "range" },
      search = { incremental = false },
      label = { before = true, after = true, style = "inline" },
      highlight = {
        backdrop = false,
        matches = false,
      },
    },

    -- Treesitter search with `/` style pattern
    treesitter_search = {
      jump = { pos = "range" },
      search = { multi_window = true, wrap = true, incremental = false },
      remote_op = { restore = true },
      label = { before = true, after = true, style = "inline" },
    },

    -- Remote flash mode (operates remotely on buffer)
    remote = {
      remote_op = { restore = true, motion = true },
    },
  },

  -- Prompt configuration when entering search mode
  prompt = {
    enabled = true,
    prefix = { { "⚡", "FlashPromptIcon" } },
    win_config = {
      relative = "editor",
      width = 1,        -- Will be overridden
      height = 1,
      row = -1,         -- One line above the bottom
      col = 0,
      zindex = 1000,
    },
  },

  -- Remote operations config (for `remote` mode)
  remote_op = {
    -- Restore original buffer/window/cursor after operation
    restore = false,
    -- Apply motion to all matches (like Vim's gn)
    motion = false,
  },
}

-- ============================================
-- Setup and Keymaps
-- ============================================

local function setup_flash()
  local ok, flash = pcall(require, 'flash')
  if not ok then
    -- Silently return if Flash isn't installed yet
    return
  end

  -- Setup Flash with our configuration
  flash.setup(config)

  -- Keymaps (matching default Flash.nvim recommendations)
  local opts = { noremap = true, silent = true }

  -- Normal, Visual, and Operator-pending modes
  vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
    flash.jump()
  end, vim.tbl_extend('force', opts, { desc = 'Flash' }))

  vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
    flash.treesitter()
  end, vim.tbl_extend('force', opts, { desc = 'Flash Treesitter' }))

  -- Operator-pending mode only
  vim.keymap.set('o', 'r', function()
    flash.remote()
  end, vim.tbl_extend('force', opts, { desc = 'Remote Flash' }))

  -- Operator-pending and Visual modes
  vim.keymap.set({ 'o', 'x' }, 'R', function()
    flash.treesitter_search()
  end, vim.tbl_extend('force', opts, { desc = 'Treesitter Search' }))

  -- Command-line mode (toggle Flash search)
  vim.keymap.set('c', '<c-s>', function()
    flash.toggle()
  end, vim.tbl_extend('force', opts, { desc = 'Toggle Flash Search' }))
end

-- Initialize Flash
setup_flash()

-- ============================================
-- Integration with Telescope (Optional)
-- ============================================

-- Uncomment to enable Flash in Telescope
--[[
local function setup_telescope_integration()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    return
  end

  telescope.setup({
    defaults = {
      mappings = {
        n = {
          s = function(...)
            require('flash').jump({
              pattern = "^",
              label = { after = { 0, 0 } },
              search = {
                mode = "search",
                exclude = {
                  function(win)
                    return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                  end,
                },
              },
              action = function(match)
                local picker = require("telescope.actions.state").get_current_picker(...)
                picker:set_selection(match.pos[1] - 1)
              end,
            })
          end,
        },
        i = {
          ["<c-s>"] = function(...)
            require('flash').jump({
              pattern = "^",
              label = { after = { 0, 0 } },
              search = {
                mode = "search",
                exclude = {
                  function(win)
                    return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                  end,
                },
              },
              action = function(match)
                local picker = require("telescope.actions.state").get_current_picker(...)
                picker:set_selection(match.pos[1] - 1)
              end,
            })
          end,
        },
      },
    },
  })
end

vim.schedule(function()
  setup_telescope_integration()
end)
--]]
