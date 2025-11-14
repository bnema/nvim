-- go.nvim - Enhanced Go development for Neovim
-- Provides gopls LSP integration, testing, debugging, and code generation

-- Use blink.cmp capabilities
local capabilities = _G.blink_cmp_capabilities or vim.lsp.protocol.make_client_capabilities()

-- State for gopls parameter name hints (toggleable) - these show inline like "w:", "node:"
_G.gopls_hints_enabled = false

require('go').setup({
  -- DISABLE go.nvim's default keymaps to avoid conflicts with our leader keymaps
  lsp_keymaps = false,

  -- Disable go.nvim's gopls setup, we'll handle it in lsp.lua with custom settings
  lsp_cfg = {
    capabilities = capabilities,
    settings = {
      gopls = {
        -- Snippet placeholders for function parameters (tab stops in completions) - enabled by default
        usePlaceholders = true,
        -- Enable function call completions with parentheses
        completeFunctionCalls = true,
        -- Enable completion from unimported packages
        completeUnimported = true,
        -- Enable postfix completions like .sort!
        experimentalPostfixCompletions = true,
        -- Enable deep completion analysis
        deepCompletion = true,
        -- Use fuzzy matching for better results
        matcher = "Fuzzy",
        -- Enable all analyses
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        -- Enable staticcheck for additional diagnostics
        staticcheck = true,
        -- Inlay hints configuration - parameter names shown inline (disabled by default, toggleable)
        hints = {
          assignVariableTypes = false,
          compositeLiteralFields = false,
          compositeLiteralTypes = false,
          constantValues = false,
          functionTypeParameters = false,
          parameterNames = _G.gopls_hints_enabled,
          rangeVariableTypes = false,
        },
      },
    },
  },
  -- Automatically import missing packages and remove unused imports on save
  lsp_gofumpt = true,
  -- Enable inlay hints (requires Neovim 0.10+)
  lsp_inlay_hints = {
    enable = true,
  },
  -- Diagnostic configuration
  diagnostic = {
    underline = true,
    virtual_text = { spacing = 4, prefix = '●' },
    signs = true,
    update_in_insert = false,
  },
})

-- Auto-format and organize imports on save
local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require('go.format').goimports()
  end,
  group = format_sync_grp,
})
