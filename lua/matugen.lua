 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#111315',
    base02 = '#1b1d1f',
    base03 = '#8c9197',
    base04 = '#c1c7cd',
    base05 = '#e2e2e4',
    base06 = '#e2e2e4',
    base07 = '#e2e2e4',
    base08 = '#ffb4ab',
    base09 = '#dcbbe7',
    base0A = '#b9c8d5',
    base0B = '#a4cce8',
    base0C = '#dcbbe7',
    base0D = '#a4cce8',
    base0E = '#b9c8d5',
    base0F = '#d5e4f1',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e2e2e4',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#8c9197',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#e2e2e4',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#8c9197',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#a4cce8',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#c1c7cd',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#a4cce8' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#b9c8d5' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#dcbbe7' })
  hi('TelescopeSelection',      { fg = '#e2e2e4',          bg = '#1b1d1f' })
  hi('TelescopeSelectionCaret', { fg = '#a4cce8',             bg = '#1b1d1f' })
  hi('TelescopeMatching',       { fg = '#a4cce8',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e2e2e4',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#8c9197',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#e2e2e4',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#a4cce8',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#a4cce8' })
  hi('MiniPickMatchCurrent',      { fg = '#e2e2e4',          bg = '#1b1d1f' })
  hi('MiniPickPromptCaret', { fg = '#a4cce8',             bg = '#1b1d1f' })
  hi('MiniPickMatchRanges',       { fg = '#a4cce8',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
