-- LSP Configuration using Neovim 11.0+ native LSP API
-- Configures language servers, completion, and diagnostics

local lsp = vim.lsp

-- Schedule LSP setup after plugin loading completes
vim.schedule(function()
  -- Build LSP capabilities from Neovim
  local capabilities = lsp.protocol.make_client_capabilities()

  -- Extend capabilities with mini.completion support if available
  local ok_mini, _ = pcall(require, 'mini.completion')
  if ok_mini then
    capabilities = vim.tbl_deep_extend('force', capabilities, MiniCompletion.get_lsp_capabilities())
  end

  -- LSP attach callback - called when LSP client attaches to buffer
  local function on_attach(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- Core LSP navigation keymaps
    vim.keymap.set('n', 'gd', lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
    vim.keymap.set('n', 'gD', lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
    vim.keymap.set('n', 'gi', lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
    vim.keymap.set('n', 'gr', lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Show references' }))
    vim.keymap.set('n', 'gy', lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Go to type definition' }))

    -- LSP information and action keymaps (leader + l prefix)
    vim.keymap.set('n', '<leader>lh', lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover' }))
    vim.keymap.set('n', '<leader>ls', lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
    vim.keymap.set('n', '<leader>lr', lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
    vim.keymap.set('n', '<leader>la', lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
    vim.keymap.set('n', '<leader>lf', function() lsp.buf.format({ async = true }) end, vim.tbl_extend('force', opts, { desc = 'Format buffer' }))

    -- Enable inline completion (Copilot and other inline completion providers)
    if client.server_capabilities.inlineCompletionProvider then
      lsp.inlinecompletion.enable(true, client.id, bufnr)
    end
  end

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
          'lua_ls',   -- Lua
          'pyright',  -- Python
          'ts_ls',    -- TypeScript/JavaScript
          'clangd',   -- C/C++
        },
        handlers = {
          -- Default handler for all servers
          function(server_name)
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
        },
      })
    end
  end

  -- Setup GitHub Copilot integration
  local ok_copilot, copilot = pcall(require, 'copilot')
  if ok_copilot then
    copilot.setup({
      suggestion = {
        enabled = false,  -- Use native inline completion instead
      },
      panel = {
        enabled = false,  -- Disable Copilot panel
      },
    })

    -- Copilot navigation keymaps for inline completion
    local opts = { noremap = true, silent = true }
    vim.keymap.set('i', '<M-]>', function() lsp.inlinecompletion.select() end, vim.tbl_extend('force', opts, { desc = 'Next suggestion' }))
    vim.keymap.set('i', '<M-[>', function() lsp.inlinecompletion.prev() end, vim.tbl_extend('force', opts, { desc = 'Previous suggestion' }))
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
end)
