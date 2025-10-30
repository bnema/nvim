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

-- Icons support
add('nvim-tree/nvim-web-devicons')

-- LSP configuration and completion framework
add('neovim/nvim-lspconfig')
add('williamboman/mason.nvim')
add('williamboman/mason-lspconfig.nvim')
add('hrsh7th/nvim-cmp')
add('hrsh7th/cmp-nvim-lsp')
add('hrsh7th/cmp-buffer')
add('hrsh7th/cmp-path')
add('hrsh7th/cmp-cmdline')                    -- Cmdline completion
add('saadparwaiz1/cmp_luasnip')               -- LuaSnip completion source
add('L3MON4D3/LuaSnip')                       -- Snippet engine

-- AI-assisted coding
add('zbirenbaum/copilot.lua')                 -- GitHub Copilot integration

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

-- Git integration and diffing
add('tpope/vim-fugitive')                     -- Git command wrapper (Gstatus, Gcommit, etc.)
add('lewis6991/gitsigns.nvim')                -- Git signs in sign column

-- Fuzzy finder (works alongside mini.pick)
add('nvim-lua/plenary.nvim')                  -- Lua utility library
add('nvim-telescope/telescope.nvim')          -- Telescope fuzzy finder
add('nvim-telescope/telescope-fzf-native.nvim')  -- FZF backend for Telescope

-- Editor utilities
add('tpope/vim-sleuth')                       -- Auto-detect indentation style
add('tpope/vim-repeat')                       -- Repeat plugin commands with .
add('stevearc/conform.nvim')                  -- Code formatter integration

-- Mini.starter setup - customized with git-aware recent files
-- Loaded synchronously so it can display on VimEnter
local function setup_mini_starter()
  local ok, starter = pcall(require, 'mini.starter')
  if not ok then
    return
  end

  -- Helper: Format filepath as "filename from dirname" with optional shortening
  local function format_filepath(filepath)
    local basename = vim.fn.fnamemodify(filepath, ':t')
    local dirname = vim.fn.fnamemodify(filepath, ':h')

    if dirname == '.' or dirname == '' then
      return basename
    end

    -- Shorten long directory paths
    if #dirname > 30 then
      dirname = '...' .. dirname:sub(-27)
    end

    return basename .. ' from "' .. dirname .. '"'
  end

  -- Helper: Get files changed on current git branch (uncommitted + committed)
  local function get_git_branch_files(limit)
    local files_set = {}  -- Use set to avoid duplicates
    local result = {}

    -- Get uncommitted changes (modified, staged, untracked)
    local status_cmd = 'git status --porcelain --untracked-files=all 2>/dev/null'
    local changed = vim.fn.systemlist(status_cmd)
    for _, line in ipairs(changed) do
      if #line > 3 then
        local file = line:sub(4)  -- Remove git status prefix (e.g., "M ", "A ", "??")
        if file ~= '' and not files_set[file] then
          table.insert(result, file)
          files_set[file] = true
        end
      end
    end

    -- Get files committed on current branch since diverging from main
    local log_cmd = 'git log --name-only --pretty=format: main..HEAD 2>/dev/null | sort -u'
    local committed = vim.fn.systemlist(log_cmd)
    for _, file in ipairs(committed) do
      if file ~= '' and not files_set[file] then
        table.insert(result, file)
        files_set[file] = true
      end
    end

    -- Limit results
    if limit and #result > limit then
      return { unpack(result, 1, limit) }
    end

    return result
  end

  -- Custom section provider: Recently modified files from git repository
  local function recent_modified_files(n)
    return function()
      local items = {}

      -- Check if in a git repo
      local is_git_repo = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match('true')

      if is_git_repo then
        local files = get_git_branch_files(n or 10)

        for _, file in ipairs(files) do
          if file ~= '' then
            table.insert(items, {
              name = format_filepath(file),
              action = 'e ' .. vim.fn.fnameescape(file),
              section = 'Recently modified (git)',
            })
          end
        end
      else
        -- Fallback: use find for non-git directories
        local cwd = vim.fn.getcwd()
        local find_cmd = string.format(
          'find "%s" -type f -not -path "*/\\.*" -printf "%%T@ %%p\\n" 2>/dev/null | sort -rn | head -%d | cut -d" " -f2-',
          cwd, n or 10
        )
        local files = vim.fn.systemlist(find_cmd)

        for _, file in ipairs(files) do
          if file ~= '' then
            local relpath = vim.fn.fnamemodify(file, ':.')
            table.insert(items, {
              name = format_filepath(relpath),
              action = 'e ' .. vim.fn.fnameescape(file),
              section = 'Recently modified',
            })
          end
        end
      end

      return items
    end
  end

  starter.setup({
    autoopen = true,
    evaluate_single = false,
    items = {
      -- Custom builtin actions
      {
        { name = "New buffer", action = "enew", section = "Builtin actions" },
        { name = "File picker (.)", action = "lua MiniPick.builtin.files()", section = "Builtin actions" },
        { name = "Explorer (.)", action = "lua MiniFiles.open()", section = "Builtin actions" },
        { name = "Quit", action = "qall", section = "Builtin actions" },
      },
      recent_modified_files(10),  -- Recently modified files in current branch
      starter.sections.recent_files(5, false, function(path)
        local dirname = vim.fn.fnamemodify(path, ':h')
        if dirname == '.' or dirname == '' then
          return ''
        end
        if #dirname > 30 then
          dirname = '...' .. dirname:sub(-27)
        end
        return ' from "' .. dirname .. '"'
      end),  -- Recent files with directory path
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
    header = 'Welcome to Neovim 11.0',
    footer = '',
  })
end


-- Initialize the starter screen
setup_mini_starter()

-- Schedule remaining plugin configuration after mini.nvim loads
vim.schedule(function()
  require('config.plugins.mini')  -- Load all mini.nvim module configurations
end)
