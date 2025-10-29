-- GitHub Copilot Native Inline Completion
-- Uses Neovim's built-in inline completion API (requires Neovim >= 0.12)
-- This replaces the copilot.lua plugin with native LSP integration

local lsp = vim.lsp

-- ============================================
-- Configuration Options
-- ============================================

local config = {
  -- Copilot LSP server settings
  server = {
    -- Custom filetypes to enable/disable copilot
    filetypes = {
      ["*"] = true,           -- Enable for all filetypes by default
      -- gitcommit = false,   -- Uncomment to disable for git commits
      -- markdown = false,    -- Uncomment to disable for markdown
      -- [".env"] = false,    -- Uncomment to disable for .env files
    },
  },

  -- Keymaps for inline completion (insert mode only)
  keymaps = {
    accept = "<Tab>",         -- Accept current suggestion
    next = "<M-]>",           -- Cycle to next suggestion
    prev = "<M-[>",           -- Cycle to previous suggestion
  },

  -- Status tracking for lualine or other statusline plugins
  track_status = true,        -- Track copilot status (ok/pending/error)
}

-- ============================================
-- Status Tracking
-- ============================================

local status = {} ---@type table<number, "ok" | "error" | "pending">

-- Get current copilot status for statusline integration
function _G.get_copilot_status()
  local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
  return #clients > 0 and status[clients[1].id] or nil
end

-- ============================================
-- LSP Configuration
-- ============================================

-- Copilot is built-in to Neovim 0.12+ (lsp/copilot.lua in runtime)
-- We just need to add our custom handlers and enable it

-- Add custom status tracking handler
if config.track_status then
  vim.lsp.config('copilot', {
    handlers = {
      -- Track copilot status changes (authentication, busy state, errors)
      didChangeStatus = function(err, res, ctx)
        if err then
          return
        end
        status[ctx.client_id] = res.kind ~= "Normal" and "error" or res.busy and "pending" or "ok"

        -- Show error message if copilot needs authentication
        if res.status == "Error" then
          vim.notify(
            'Copilot authentication required. Run: :LspCopilotSignIn',
            vim.log.levels.ERROR
          )
        end
      end,
    },
  })
end

-- Enable copilot LSP client (will use built-in config from Neovim 0.12)
vim.lsp.enable('copilot')

-- Enable native inline completion globally and setup LspAttach
vim.schedule(function()
  -- Enable inline completion when copilot attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local bufnr = args.buf
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

      if client.name == 'copilot' and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
        lsp.inline_completion.enable(true, { bufnr = bufnr })
      end
    end,
  })
end)

-- ============================================
-- Keymaps
-- ============================================

local opts = { noremap = true, silent = true }

-- Accept inline completion with Tab (insert mode only)
-- Falls back to default Tab behavior when no suggestion is visible
vim.keymap.set('i', config.keymaps.accept, function()
  if not lsp.inline_completion.get() then
    -- No suggestion - use default Tab behavior
    return '<Tab>'
  end
  -- If get() returns truthy, it was accepted
end, vim.tbl_extend('force', opts, {
  desc = 'Accept Copilot suggestion',
  expr = true,  -- Allows return value to be inserted
}))

-- Cycle to next suggestion (insert mode)
vim.keymap.set('i', config.keymaps.next, function()
  lsp.inline_completion.select({ count = 1 })
end, vim.tbl_extend('force', opts, { desc = 'Next Copilot suggestion' }))

-- Cycle to previous suggestion (insert mode)
vim.keymap.set('i', config.keymaps.prev, function()
  lsp.inline_completion.select({ count = -1 })
end, vim.tbl_extend('force', opts, { desc = 'Prev Copilot suggestion' }))

-- ============================================
-- Additional Commands
-- ============================================

-- Command to toggle inline completion on/off
vim.api.nvim_create_user_command('CopilotToggle', function()
  local enabled = lsp.inline_completion.is_enabled()
  lsp.inline_completion.enable(not enabled)
  vim.notify(
    'Copilot inline completion ' .. (enabled and 'disabled' or 'enabled'),
    vim.log.levels.INFO
  )
end, { desc = 'Toggle GitHub Copilot inline completion' })

-- Command to check Copilot status
vim.api.nvim_create_user_command('CopilotStatus', function()
  local clients = vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })
  if #clients == 0 then
    vim.notify('Copilot LSP client not running', vim.log.levels.WARN)
    return
  end

  local client_status = status[clients[1].id] or 'unknown'
  local inline_enabled = lsp.inline_completion.is_enabled({ bufnr = 0 })

  vim.notify(
    string.format(
      'Copilot Status:\n- LSP: %s\n- Inline Completion: %s',
      client_status,
      inline_enabled and 'enabled' or 'disabled'
    ),
    vim.log.levels.INFO
  )
end, { desc = 'Show GitHub Copilot status' })
