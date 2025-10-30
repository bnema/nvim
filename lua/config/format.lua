-- Auto-formatting configuration
-- Automatically format files on save based on filetype

-- ============================================
-- GO FORMATTING
-- ============================================
-- Run 'go fmt' on Go files before saving
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    -- Get the current buffer
    local bufnr = vim.api.nvim_get_current_buf()

    -- Save cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Try LSP formatting first (if gopls is attached)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'gopls' })
    if #clients > 0 then
      -- Use LSP formatting (synchronous to ensure it completes before save)
      vim.lsp.buf.format({
        bufnr = bufnr,
        timeout_ms = 1000,
        async = false,
      })
      vim.notify('Formatted with gopls', vim.log.levels.INFO)
    else
      -- Fallback: run 'go fmt' command directly
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename ~= '' then
        local result = vim.fn.system('go fmt ' .. vim.fn.shellescape(filename))
        if vim.v.shell_error ~= 0 then
          vim.notify('go fmt failed: ' .. result, vim.log.levels.ERROR)
        else
          -- Reload the buffer to show formatted content
          vim.cmd('edit')
          vim.notify('Formatted with go fmt', vim.log.levels.INFO)
        end
      end
    end

    -- Restore cursor position
    pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
  end,
  desc = 'Format Go files with go fmt on save',
})

-- ============================================
-- OPTIONAL: Format other file types
-- ============================================
-- Uncomment and customize as needed for other languages

-- Rust formatting with rustfmt
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.rs',
--   callback = function()
--     vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
--   end,
--   desc = 'Format Rust files on save',
-- })

-- JavaScript/TypeScript formatting
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' },
--   callback = function()
--     vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
--   end,
--   desc = 'Format JS/TS files on save',
-- })

-- Python formatting
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.py',
--   callback = function()
--     vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
--   end,
--   desc = 'Format Python files on save',
-- })

-- Lua formatting
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.lua',
--   callback = function()
--     vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
--   end,
--   desc = 'Format Lua files on save',
-- })

-- ============================================
-- COMMANDS
-- ============================================

-- Manually format current buffer
vim.api.nvim_create_user_command('Format', function()
  vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
end, { desc = 'Format current buffer with LSP' })

-- Format Go file manually
vim.api.nvim_create_user_command('GoFmt', function()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == '' then
    vim.notify('No file to format', vim.log.levels.WARN)
    return
  end

  local result = vim.fn.system('go fmt ' .. vim.fn.shellescape(filename))
  if vim.v.shell_error ~= 0 then
    vim.notify('go fmt failed: ' .. result, vim.log.levels.ERROR)
  else
    vim.cmd('edit')
    vim.notify('File formatted with go fmt', vim.log.levels.INFO)
  end
end, { desc = 'Format current Go file with go fmt' })
