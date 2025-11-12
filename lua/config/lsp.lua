-- LSP Configuration using Neovim 11.0+ native LSP API
-- Configures language servers, completion, and diagnostics
--
-- NOTE: This file is loaded on-demand via BufReadPre/BufNewFile autocmd in plugins.lua
-- to avoid blocking startup time with heavy LSP initialization

local lsp = vim.lsp

-- Build LSP capabilities from blink.cmp
-- blink.cmp is loaded before this file in native-packages.lua
local capabilities = _G.blink_cmp_capabilities or lsp.protocol.make_client_capabilities()

-- LSP attach callback - called when LSP client attaches to buffer
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Core LSP navigation keymaps - use native vim.lsp.buf for direct jumps
  -- These jump directly to single results, or show native list for multiple
  vim.keymap.set('n', 'gd', lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
  vim.keymap.set('n', 'gD', lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
  vim.keymap.set('n', 'gi', lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
  vim.keymap.set('n', 'gr', lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Show references' }))
  vim.keymap.set('n', 'gy', lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Go to type definition' }))

  -- LSP information and action keymaps (leader + l prefix)
  vim.keymap.set('n', '<leader>lh', lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover' }))
  vim.keymap.set('n', '<leader>lr', lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
  vim.keymap.set('n', '<leader>la', lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
  vim.keymap.set('n', '<leader>lf', function() lsp.buf.format({ async = true }) end, vim.tbl_extend('force', opts, { desc = 'Format buffer' }))

  -- Enable inline completion (Copilot and other inline completion providers)
  if client.server_capabilities.inlineCompletionProvider then
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
  end

  -- Refresh mini.clue to pick up LSP keymaps
  -- LSP keymaps are buffer-local, so mini.clue needs to re-discover them
  vim.schedule(function()
    local ok, miniclue = pcall(require, 'mini.clue')
    if ok then
      miniclue.ensure_buf_triggers(bufnr)
    end
  end)
end

-- Global LspAttach autocommand - ensures keybindings are set even if on_attach doesn't fire
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    on_attach(client, args.buf)
  end,
})

-- Note: Go formatting is handled by go.nvim in config/plugins/go.lua

-- Setup Mason - package manager for language servers
local ok_mason, mason = pcall(require, 'mason')
if ok_mason then
  mason.setup()
  -- Setup mason-lspconfig bridge between Mason and lspconfig
  local ok_mlc, mlc = pcall(require, 'mason-lspconfig')
  if ok_mlc then
    mlc.setup({
      -- Language servers to automatically install
      ensure_installed = {
        -- Core languages
        'lua_ls',               -- Lua
        'pyright',              -- Python
        'ts_ls',                -- TypeScript/JavaScript
        'clangd',               -- C/C++
        'gopls',                -- Go

        -- Web Development (SvelteKit + Tailwind)
        'svelte', -- Svelte/SvelteKit
        'tailwindcss',          -- Tailwind CSS intellisense & completion
        'html',                 -- HTML
        'cssls',                -- CSS/SCSS
        'jsonls',               -- JSON (config files)
        'eslint',               -- ESLint linting
      },
      handlers = {
        -- Default handler for all servers
        function(server_name)
          -- Skip gopls since go.nvim handles it
          if server_name == 'gopls' then
            return
          end
          require('lspconfig')[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
        -- Custom Lua server configuration
        lua_ls = function()
          require('lspconfig').lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },  -- Neovim uses LuaJIT
                diagnostics = { globals = { 'vim', 'MiniDeps' } },  -- Global APIs
              },
            },
          })
        end,
        -- gopls is handled by go.nvim, skip it here
        gopls = function()
          -- No-op: go.nvim handles gopls configuration
        end,
      },
    })
  end
end

-- Configure LSP diagnostics display
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',  -- Bullet for inline diagnostic text
  },
  signs = true,           -- Show diagnostic signs in sign column
  underline = true,       -- Underline diagnostics
  update_in_insert = false, -- Don't update while typing
  severity_sort = true,   -- Sort by severity (errors first)
})

-- Configure diagnostic sign appearance with Nerd Font icons
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,  -- Use DiagnosticSign* highlight
    text = opts.text,    -- Icon to display
    numhl = '',          -- Don't highlight line number
  })
end
sign({ name = 'DiagnosticSignError', text = '\u{e726}' })  -- Nerd font error icon
sign({ name = 'DiagnosticSignWarn', text = '\u{e7b0}' })   -- Nerd font warning icon
sign({ name = 'DiagnosticSignHint', text = '\u{e60a}' })   -- Nerd font hint icon
sign({ name = 'DiagnosticSignInfo', text = '\u{e773}' })   -- Nerd font info icon
