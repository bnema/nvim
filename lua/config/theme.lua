-- Theme selection and color overrides
local M = {}

M.default = 'tokyonight-night'

M.themes = {
  'dracula',
  'despair',
  'tokyonight-night',
  'catppuccin-mocha',
  'rose-pine',
  'habamax',
}

-- Explicit CodeDiff colors keep insertions/deletions readable even when a
-- colorscheme defines DiffAdd/DiffDelete with low-contrast grey backgrounds.
M.codediff_highlights = {
  line_insert = '#1f3d2b',
  line_delete = '#3d2028',
  char_insert = '#2f6b45',
  char_delete = '#6b2f3a',
}

local function notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = 'Theme' })
  end)
end

function M.apply_overrides()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  if normal.bg then
    -- Some colorschemes leave inactive windows transparent. Keep the editor
    -- background consistent instead of falling through to the terminal color.
    vim.api.nvim_set_hl(0, 'NormalNC', { fg = normal.fg, bg = normal.bg })
  end

  -- Inline completion hint visibility (Copilot native LSP)
  vim.api.nvim_set_hl(0, 'ComplHint', { fg = '#6c7a89', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'ComplHintMore', { fg = '#5d6d7e', bg = 'NONE' })

  -- CodeDiff line and character highlights
  vim.api.nvim_set_hl(0, 'CodeDiffLineInsert', { bg = M.codediff_highlights.line_insert })
  vim.api.nvim_set_hl(0, 'CodeDiffLineDelete', { bg = M.codediff_highlights.line_delete })
  vim.api.nvim_set_hl(0, 'CodeDiffCharInsert', { bg = M.codediff_highlights.char_insert })
  vim.api.nvim_set_hl(0, 'CodeDiffCharDelete', { bg = M.codediff_highlights.char_delete })
end

function M.apply(theme)
  theme = theme or vim.g.nvim_theme or vim.env.NVIM_THEME or M.default

  local ok, err = pcall(vim.cmd.colorscheme, theme)
  if ok then
    vim.g.nvim_theme = theme
    return
  end

  local fallback = M.default
  if theme == fallback then fallback = 'habamax' end

  notify(('Failed to load colorscheme %q: %s. Falling back to %q.'):format(theme, err, fallback), vim.log.levels.WARN)

  local ok2, err2 = pcall(vim.cmd.colorscheme, fallback)
  if ok2 then
    vim.g.nvim_theme = fallback
    return
  end

  notify(('Failed to load fallback colorscheme %q: %s.'):format(fallback, err2), vim.log.levels.ERROR)
end

local function current_index()
  local current = vim.g.colors_name or vim.g.nvim_theme or M.default
  for index, theme in ipairs(M.themes) do
    if theme == current then return index end
  end
  return 1
end

function M.next()
  local index = current_index() % #M.themes + 1
  M.apply(M.themes[index])
end

function M.prev()
  local index = current_index() - 1
  if index < 1 then index = #M.themes end
  M.apply(M.themes[index])
end

function M.setup()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('ThemeOverrides', { clear = true }),
    callback = M.apply_overrides,
  })

  M.apply()

  vim.api.nvim_create_user_command('Theme', function(opts)
    if opts.args == '' then
      notify(('Current: %s. Available: %s'):format(vim.g.colors_name or 'unknown', table.concat(M.themes, ', ')))
      return
    end
    M.apply(opts.args)
  end, {
    nargs = '?',
    complete = function()
      return M.themes
    end,
  })

  vim.api.nvim_create_user_command('ThemeNext', M.next, {})
  vim.api.nvim_create_user_command('ThemePrev', M.prev, {})
end

return M
