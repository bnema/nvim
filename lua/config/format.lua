-- Auto-formatting configuration
-- Automatically format files on save using LSP

-- ============================================
-- AUTO-FORMAT ON SAVE (LSP-based)
-- ============================================
-- Format on save for specified filetypes using LSP
-- Supported formatters:
--   - Go: gopls (gofmt + goimports)
--   - Svelte/SvelteKit: svelte-language-server (prettier + prettier-plugin-svelte)
--   - TypeScript/JavaScript: ts_ls (prettier via LSP)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {
    '*.go',           -- Go files
    '*.svelte',       -- Svelte components
    '*.ts',           -- TypeScript
    '*.tsx',          -- TypeScript + JSX
    '*.js',           -- JavaScript
    '*.jsx',          -- JavaScript + JSX
  },
  callback = function(args)
    -- Only format if an LSP client with formatting capability is attached
    local clients = vim.lsp.get_clients({ bufnr = args.buf })
    local has_formatter = false

    for _, client in ipairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        has_formatter = true
        break
      end
    end

    if has_formatter then
      -- Format synchronously before save (async = false ensures it completes)
      vim.lsp.buf.format({
        bufnr = args.buf,
        timeout_ms = 3000,
        async = false,
      })
    end
  end,
  desc = 'Format buffer with LSP on save',
})

-- ============================================
-- OPTIONAL: Format other file types
-- ============================================
-- To enable auto-format on save for other languages, add their patterns below:
-- Example patterns: '*.rs', '*.py', '*.lua', '*.ts', '*.js', '*.jsx', '*.tsx', etc.

-- Uncomment and add patterns to enable auto-format for additional file types:
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = { '*.rs', '*.py', '*.lua', '*.ts', '*.js' },
--   callback = function(args)
--     local clients = vim.lsp.get_clients({ bufnr = args.buf })
--     for _, client in ipairs(clients) do
--       if client.server_capabilities.documentFormattingProvider then
--         vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 3000, async = false })
--         break
--       end
--     end
--   end,
--   desc = 'Format buffer with LSP on save',
-- })

-- ============================================
-- MANUAL FORMATTING COMMANDS
-- ============================================

-- :Format - Manually format current buffer with LSP
vim.api.nvim_create_user_command('Format', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local has_formatter = false

  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      has_formatter = true
      break
    end
  end

  if has_formatter then
    vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
    vim.notify('Buffer formatted', vim.log.levels.INFO)
  else
    vim.notify('No LSP formatter available for this buffer', vim.log.levels.WARN)
  end
end, { desc = 'Format current buffer with LSP' })
