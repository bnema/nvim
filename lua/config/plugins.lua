-- Plugin management via mini.deps
-- Uses a minimalist plugin manager that ships with the mini.nvim ecosystem

-- Bootstrap mini.deps if not already installed
local deps_path = vim.fn.stdpath('data') .. '/site/pack/deps/opt/mini.deps'
if not vim.loop.fs_stat(deps_path) then
  vim.fn.system({
    'git', 'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.deps.git',
    deps_path,
  })
end

-- Add mini.deps to Neovim's runtime path
vim.opt.rtp:append(deps_path)

-- Configure mini.deps with custom package paths
require('mini.deps').setup({
  path = {
    package = vim.fn.stdpath('data') .. '/site/pack/deps',
    git = vim.fn.stdpath('data') .. '/site/pack/deps/opt',
  },
})

-- Helper functions for plugin loading (now = sync, later = async)
local add = MiniDeps.add
local now = MiniDeps.now
local later = MiniDeps.later

-- Core mini.nvim - loaded immediately and synchronously
now(function()
  add('echasnovski/mini.nvim')
end)

-- Dependencies (needed by other plugins)
add('nvim-lua/plenary.nvim')                  -- Lua utility library
add('nvim-tree/nvim-web-devicons')            -- File icons

-- ============================================
-- DEFER LOAD: LSP infrastructure (after startup, before files open)
-- Must load before FileType events to allow mason-lspconfig to attach servers
-- ============================================
later(function()
  -- LSP configuration and completion framework
  add('neovim/nvim-lspconfig')
  add('williamboman/mason.nvim')
  add('williamboman/mason-lspconfig.nvim')

  -- Treesitter for advanced syntax highlighting and textobjects
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = {
      post_checkout = function()
        vim.cmd('TSUpdate')                     -- Auto-update parsers after cloning
      end,
    },
  })
  add('nvim-treesitter/nvim-treesitter-textobjects')  -- Text object support via Tree-sitter

  -- Load LSP config after plugins are available
  vim.schedule(function()
    require('config.lsp')
    -- Load Copilot native inline completion (requires Neovim 0.12+)
    require('config.plugins.copilot')
  end)
end)

-- ============================================
-- DEFER LOAD: Everything else after startup
-- ============================================
later(function()
  -- Git integration and diffing
  add('tpope/vim-fugitive')                     -- Git command wrapper (Gstatus, Gcommit, etc.)
  add('lewis6991/gitsigns.nvim')                -- Git signs in sign column

  -- Fuzzy finder (works alongside mini.pick)
  add('nvim-telescope/telescope.nvim')          -- Telescope fuzzy finder
  add('nvim-telescope/telescope-fzf-native.nvim')  -- FZF backend for Telescope

  -- Editor utilities
  add('tpope/vim-sleuth')                       -- Auto-detect indentation style
  add('tpope/vim-repeat')                       -- Repeat plugin commands with .
  add('stevearc/conform.nvim')                  -- Code formatter integration
end)

-- Helper to get current Neovim version
local function get_neovim_version()
  local v = vim.version()
  return string.format('%d.%d.%d', v.major, v.minor, v.patch)
end

-- Mini.starter setup - OPTIMIZED to avoid blocking git commands
-- Uses mini.extra.pickers.oldfiles() instead of custom git logic
local function setup_mini_starter()
  local ok, starter = pcall(require, 'mini.starter')
  if not ok then
    return
  end

  -- NOTE: Using mini.extra.pickers.oldfiles() is much faster than custom git commands
  -- because it's optimized and doesn't block UI startup
  starter.setup({
    autoopen = true,
    evaluate_single = false,
    items = {
      -- Custom builtin actions
      {
        { name = "New buffer", action = "enew", section = "Builtin actions" },
        { name = "File picker", action = "lua MiniPick.builtin.files()", section = "Builtin actions" },
        { name = "Search in files", action = "lua MiniPick.builtin.grep_live()", section = "Builtin actions" },
        { name = "Explorer", action = "lua MiniFiles.open()", section = "Builtin actions" },
        { name = "Quit", action = "qall", section = "Builtin actions" },
      },
      -- Use mini.extra's oldfiles picker (fast, non-blocking)
      starter.sections.recent_files(10, false, function(path)
        local dirname = vim.fn.fnamemodify(path, ':h')
        if dirname == '.' or dirname == '' then
          return ''
        end
        -- Replace home directory with ~ for cleaner display
        dirname = dirname:gsub(vim.env.HOME, '~')

        if #dirname > 30 then
          -- Show only the last 3 directory components with ellipsis prefix
          local parts = vim.split(dirname, '/')
          if #parts > 3 then
            return ' from ".../' .. table.concat({parts[#parts-2], parts[#parts-1], parts[#parts]}, '/') .. '"'
          end
        end
        return ' from "' .. dirname .. '"'
      end),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.indexing('all', { 'Builtin actions' }),
      starter.gen_hook.padding(3, 2),
      -- Highlight directory path in gray
      function(content, buf_id)
        vim.schedule(function()
          local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
          for i, line in ipairs(lines) do
            -- Find pattern: filename from "dirname"
            local from_start, from_end = line:find(' from ".-"')
            if from_start then
              -- Highlight the ' from "dirname"' part with MiniStarterInactive (gray)
              vim.api.nvim_buf_add_highlight(
                buf_id,
                -1,
                'MiniStarterInactive',
                i - 1,
                from_start - 1,
                from_end
              )
            end
          end
        end)
        return content
      end,
    },
    header = 'Welcome to Neovim ' .. get_neovim_version(),
    footer = '',
  })
end


-- Initialize the starter screen
setup_mini_starter()

-- Schedule remaining plugin configuration after mini.nvim loads
vim.schedule(function()
  require('config.plugins.mini')  -- Load all mini.nvim module configurations
end)
