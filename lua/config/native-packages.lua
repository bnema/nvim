-- Native Neovim 0.12+ Package Management
-- Uses vim.pack.add() for all plugins
-- Documentation: :help vim.pack.add()

-- ============================================
-- STAGE 1: Core Dependencies (Immediate)
-- ============================================

-- Add core dependencies
vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/echasnovski/mini.nvim' },
  { src = 'https://github.com/bnema/despair-theme' },
}, { load = false, confirm = false })

-- Load colorscheme immediately (needed before UI rendering)
vim.cmd.packadd('despair-theme')

-- Load mini.nvim immediately (needed for UI essentials)
vim.cmd.packadd('mini.nvim')

-- ============================================
-- STAGE 2: Flash.nvim - Navigate with search labels
-- ============================================

vim.pack.add({
  { src = 'https://github.com/folke/flash.nvim', name = 'flash.nvim' }
}, { load = false, confirm = false })

-- Load Flash configuration
vim.schedule(function()
  vim.cmd.packadd('flash.nvim')
  require('config.plugins.flash')
end)

-- ============================================
-- STAGE 3: Yazi.nvim - Terminal file manager
-- ============================================

-- Mark netrw as loaded so it's not loaded at all
-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
  { src = 'https://github.com/mikavilpas/yazi.nvim', name = 'yazi.nvim' }
}, { load = false, confirm = false })

-- Setup yazi on UIEnter for directory handling
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.cmd.packadd('yazi.nvim')
    local yazi_config = require("config.plugins.yazi")
    require("yazi").setup(yazi_config)
  end,
})

-- ============================================
-- STAGE 4: LSP Infrastructure (on UIEnter, early)
-- ============================================

vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/williamboman/mason.nvim' },
  { src = 'https://github.com/williamboman/mason-lspconfig.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
  { src = 'https://github.com/ray-x/guihua.lua' },
  { src = 'https://github.com/ray-x/go.nvim' },
  { src = 'https://github.com/saghen/blink.cmp' }, -- Uses main branch (latest)
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}, { load = false, confirm = false })

-- Load LSP infrastructure on UIEnter
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      -- Load LSP plugins
      vim.cmd.packadd('nvim-lspconfig')
      vim.cmd.packadd('mason.nvim')
      vim.cmd.packadd('mason-lspconfig.nvim')
      vim.cmd.packadd('nvim-treesitter')
      vim.cmd.packadd('nvim-treesitter-textobjects')
      vim.cmd.packadd('guihua.lua')
      vim.cmd.packadd('go.nvim')
      vim.cmd.packadd('blink.cmp')
      vim.cmd.packadd('friendly-snippets')

      -- Load blink.cmp first (before LSP) so LSP can get capabilities
      require('config.plugins.blink')

      -- Load Treesitter configuration
      require('config.plugins.treesitter')

      -- Load LSP configuration
      require('config.lsp')

      -- Load go.nvim for Go language support
      require('config.plugins.go')

      -- Load Copilot native inline completion (requires Neovim 0.12+)
      require('config.plugins.copilot')
    end)
  end,
})

-- ============================================
-- STAGE 5: Editor utilities (deferred)
-- ============================================

vim.pack.add({
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/tpope/vim-sleuth' },
  { src = 'https://github.com/tpope/vim-repeat' },
  { src = 'https://github.com/sindrets/diffview.nvim' },
  { src = 'https://github.com/NeogitOrg/neogit' },
}, { load = false, confirm = false })

-- Load editor utilities after a short delay
vim.defer_fn(function()
  vim.cmd.packadd('vim-fugitive')
  vim.cmd.packadd('vim-sleuth')
  vim.cmd.packadd('vim-repeat')
  vim.cmd.packadd('diffview.nvim')
  require('config.plugins.diffview')
  vim.cmd.packadd('neogit')
  require('config.plugins.neogit')
end, 100)

-- ============================================
-- STAGE 6: Load mini.nvim plugin configurations
-- ============================================

-- Load mini.* plugin configurations immediately
-- mini.starter with autoopen=true must run before any buffer is created
require('config.plugins.mini')

-- ============================================
-- STAGE 7: Package Management Commands
-- ============================================

-- Create user command to update all packages
vim.api.nvim_create_user_command('PackUpdate', function()
  print('Updating all packages...')
  vim.pack.update()
end, { desc = 'Update all packages managed by vim.pack' })

-- Create user command to update specific packages
vim.api.nvim_create_user_command('PackUpdatePlugin', function(opts)
  local plugin_name = opts.args
  if plugin_name == '' then
    print('Please specify a plugin name')
    return
  end
  print('Updating ' .. plugin_name .. '...')
  vim.pack.update({ plugin_name })
end, {
  nargs = 1,
  desc = 'Update specific package by name',
  complete = function()
    -- Get all plugin names for completion
    local plugins = vim.pack.get()
    local names = {}
    for _, plugin in ipairs(plugins) do
      table.insert(names, plugin.spec.name)
    end
    return names
  end
})

-- Create user command to force update (no confirmation)
vim.api.nvim_create_user_command('PackUpdateForce', function()
  print('Force updating all packages...')
  vim.pack.update(nil, { force = true })
end, { desc = 'Force update all packages without confirmation' })

-- Create user command to list all managed packages (fast, no update check)
vim.api.nvim_create_user_command('PackList', function()
  local plugins = vim.pack.get()
  local lines = {}

  table.insert(lines, 'Installed packages:')
  table.insert(lines, string.rep('=', 80))

  for _, plugin in ipairs(plugins) do
    local status = plugin.active and '✓' or '○'
    local rev_str = plugin.rev and (' │ ' .. plugin.rev:sub(1, 7)) or ''
    table.insert(lines, string.format('%s %-35s%s', status, plugin.spec.name, rev_str))
  end

  table.insert(lines, string.rep('=', 80))
  table.insert(lines, 'Hint: Use :PackStatus to check for updates')

  print(table.concat(lines, '\n'))
end, { desc = 'List all managed packages' })

-- Create user command to check package update status (slower, checks remote)
vim.api.nvim_create_user_command('PackStatus', function()
  local plugins = vim.pack.get()

  print('Checking for updates...')
  print(string.rep('=', 80))

  local total = #plugins
  local checked = 0

  for _, plugin in ipairs(plugins) do
    local status = plugin.active and '✓' or '○'
    local update_status = ''
    local rev_str = plugin.rev and (' │ ' .. plugin.rev:sub(1, 7)) or ''

    -- Check if plugin needs update by fetching remote info
    if plugin.path and plugin.rev then
      -- Run git fetch to get latest remote info (in background, doesn't change local files)
      local fetch_result = vim.system(
        { 'git', 'fetch', '--quiet' },
        { cwd = plugin.path, text = true }
      ):wait()

      if fetch_result.code == 0 then
        -- Get the default branch or specified version
        local remote_ref = 'origin/HEAD'
        if plugin.spec.version and type(plugin.spec.version) == 'string' then
          remote_ref = 'origin/' .. plugin.spec.version
        end

        -- Compare local rev with remote
        local rev_list = vim.system(
          { 'git', 'rev-list', '--count', plugin.rev .. '..' .. remote_ref },
          { cwd = plugin.path, text = true }
        ):wait()

        if rev_list.code == 0 and rev_list.stdout then
          local count_str = rev_list.stdout:match('%d+')
          if count_str then
            local commits_behind = tonumber(count_str)
            if commits_behind and commits_behind > 0 then
              update_status = string.format(' │ ↑ %d behind', commits_behind)
            else
              update_status = ' │ up-to-date'
            end
          end
        end
      end
    end

    checked = checked + 1
    print(string.format('[%d/%d] %s %-30s%s%s', checked, total, status, plugin.spec.name, rev_str, update_status))
  end

  print(string.rep('=', 80))
  print('Done! Run :PackUpdate to update packages with available updates')
end, { desc = 'Check package update status (slow, fetches remote)' })
