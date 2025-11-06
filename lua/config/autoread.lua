-- Auto-reload buffers when files are modified externally
-- Useful for AI tools like Claude Code, formatters, or any external file modifications

-- ============================================
-- OPTION 1: Enable autoread option
-- ============================================
-- Automatically reload files when they change externally (if not modified in Neovim)
vim.opt.autoread = true

-- ============================================
-- OPTION 2: Autocommand with checktime
-- ============================================
-- Force Neovim to check for external file changes more frequently
-- This triggers on focus gain, buffer enter, and cursor hold events
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  callback = function()
    -- Don't trigger in command-line window or command-line mode
    if vim.fn.getcmdwintype() == '' and vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
  desc = 'Check for external file changes',
})

-- ============================================
-- OPTION 3: File System Watcher
-- ============================================
-- Active file watching using libuv's fs_event
-- This provides real-time notifications when files change

local watchers = {}

-- Clean up watcher for a buffer
local function stop_watcher(bufnr)
  if watchers[bufnr] then
    watchers[bufnr]:stop()
    watchers[bufnr] = nil
  end
end

-- Start watching a file
local function watch_file(bufnr)
  -- Only watch normal files (not special buffers)
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= '' then
    return
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' or not vim.uv.fs_stat(filepath) then
    return
  end

  -- Stop existing watcher for this buffer
  stop_watcher(bufnr)

  -- Create new watcher
  local w = vim.uv.new_fs_event()
  watchers[bufnr] = w

  local function on_change(err, fname, status)
    if err then
      vim.schedule(function()
        vim.notify('File watcher error: ' .. err, vim.log.levels.ERROR)
      end)
      return
    end

    -- Reload the buffer
    vim.schedule(function()
      -- Check if buffer is still valid and loaded
      if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
        -- Check if file was modified externally
        vim.cmd('checktime ' .. bufnr)
      end
    end)

    -- Restart the watcher (needed for some editors that delete/recreate files)
    w:stop()
    w:start(
      filepath,
      {},
      vim.schedule_wrap(function(...)
        on_change(...)
      end)
    )
  end

  -- Start watching
  w:start(
    filepath,
    {},
    vim.schedule_wrap(function(...)
      on_change(...)
    end)
  )
end

-- Set up file watchers for all buffers
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  pattern = '*',
  callback = function(args)
    watch_file(args.buf)
  end,
  desc = 'Start file watcher for buffer',
})

-- Clean up watchers when buffers are deleted
vim.api.nvim_create_autocmd('BufDelete', {
  pattern = '*',
  callback = function(args)
    stop_watcher(args.buf)
  end,
  desc = 'Stop file watcher for deleted buffer',
})

-- ============================================
-- POST-RELOAD NOTIFICATION (Optional)
-- ============================================
-- Notify when a file is reloaded from disk
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  callback = function()
    vim.notify('File reloaded from disk: ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)

    -- Notify LSP servers about the file change
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if client.supports_method('textDocument/didChange') then
        vim.lsp.util.buf_notify(bufnr, 'textDocument/didChange', {
          textDocument = vim.lsp.util.make_text_document_params(bufnr),
          contentChanges = {
            {
              text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'),
            },
          },
        })
      end
    end
  end,
  desc = 'Notify on external file reload and update LSP',
})

-- ============================================
-- COMMANDS
-- ============================================
-- Manual commands for debugging or control

-- Manually check for file changes
vim.api.nvim_create_user_command('CheckExternalChanges', function()
  vim.cmd('checktime')
  vim.notify('Checked for external file changes', vim.log.levels.INFO)
end, { desc = 'Manually check for external file changes' })

-- Restart file watcher for current buffer
vim.api.nvim_create_user_command('RestartFileWatcher', function()
  local bufnr = vim.api.nvim_get_current_buf()
  stop_watcher(bufnr)
  watch_file(bufnr)
  vim.notify('File watcher restarted for current buffer', vim.log.levels.INFO)
end, { desc = 'Restart file watcher for current buffer' })

-- List all active file watchers
vim.api.nvim_create_user_command('ListFileWatchers', function()
  local count = 0
  for bufnr, _ in pairs(watchers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      print(string.format('Buffer %d: %s', bufnr, name))
      count = count + 1
    end
  end
  vim.notify(string.format('Active file watchers: %d', count), vim.log.levels.INFO)
end, { desc = 'List all active file watchers' })
