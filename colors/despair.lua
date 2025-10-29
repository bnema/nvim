-- Despair Colorscheme for Neovim
-- Based on the Despair Design System v1.0
-- A cohesive dark theme built on muted grays with subtle teal accents
-- Provides comprehensive coverage for editor UI, syntax, and plugin highlighting

local hi = function(name, val)
    vim.api.nvim_set_hl(0, name, val)
end

-- Clear any existing highlighting to ensure clean theme state
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
end

-- Register colorscheme
vim.g.colors_name = 'despair'
vim.o.background = 'dark'  -- Indicate this is a dark theme

-- Color Palette (from Despair Design System)
local colors = {
    -- Background Colors
    void_black = '#08090a',     -- Primary background
    shadow_gray = '#0f1011',    -- Sidebar, borders
    deep_charcoal = '#181a1b',  -- Floating panels, inputs
    eerie_black = '#222823',    -- Active tab, highlighted sections
    slate_gray = '#2d3236',     -- Hover states, cards

    -- Foreground & Text Colors
    seasalt = '#f4f7f5',        -- Main body text
    pure_white = '#fefefe',     -- Emphasized text, selected items
    light_gray = '#b8bbbf',     -- Secondary information
    silver_gray = '#8b8f94',    -- Tertiary text
    dim_gray = '#6a6e73',       -- Comments, hints

    -- Accent Colors - Teal Spectrum
    bright_teal = '#7db5b5',    -- Keywords, links, focus
    slate_teal = '#5a8585',     -- Types, classes, buttons
    deep_teal = '#3d6666',      -- Numbers, constants
    dark_teal = '#2a4a4a',      -- Selections, borders, hover
    muted_teal = '#1f3636',     -- Subtle highlights

    -- Neutral Grays
    rose_quartz = '#a7a2a9',    -- Selected text, strings
    storm_gray = '#757982',     -- Borders, separators
    davys_gray = '#575a5e',     -- Inactive borders
    graphite = '#3f4245',       -- Very subtle dividers

    -- Semantic Colors
    soft_red = '#d96c75',       -- Errors, deletions
    muted_orange = '#d9a66c',   -- Warnings, modified
    info_blue = '#6c9bd9',      -- Information states
}

-- Editor UI
hi('Normal', { fg = colors.seasalt, bg = colors.void_black })
hi('NormalFloat', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('FloatBorder', { fg = colors.shadow_gray, bg = colors.shadow_gray })
hi('FloatTitle', { fg = colors.pure_white, bg = colors.deep_charcoal, bold = true })

hi('Cursor', { fg = colors.void_black, bg = colors.storm_gray })
hi('CursorLine', { bg = colors.deep_charcoal })
hi('CursorColumn', { bg = colors.deep_charcoal })
hi('ColorColumn', { bg = colors.shadow_gray })

hi('LineNr', { fg = colors.graphite })
hi('CursorLineNr', { fg = colors.bright_teal, bold = true })
hi('SignColumn', { fg = colors.silver_gray, bg = colors.void_black })

hi('Visual', { bg = colors.dark_teal })
hi('VisualNOS', { bg = colors.dark_teal })
hi('Search', { bg = colors.dark_teal, fg = colors.seasalt })
hi('IncSearch', { bg = colors.slate_teal, fg = colors.pure_white })
hi('CurSearch', { bg = colors.slate_teal, fg = colors.pure_white })

hi('Pmenu', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('PmenuSel', { fg = colors.pure_white, bg = colors.slate_teal })
hi('PmenuSbar', { bg = colors.shadow_gray })
hi('PmenuThumb', { bg = colors.slate_teal })

hi('StatusLine', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('StatusLineNC', { fg = colors.dim_gray, bg = colors.shadow_gray })
hi('WinBar', { fg = colors.seasalt, bg = colors.void_black })
hi('WinBarNC', { fg = colors.dim_gray, bg = colors.void_black })

hi('TabLine', { fg = colors.dim_gray, bg = colors.void_black })
hi('TabLineFill', { bg = colors.void_black })
hi('TabLineSel', { fg = colors.seasalt, bg = colors.eerie_black })

hi('VertSplit', { fg = colors.shadow_gray })
hi('WinSeparator', { fg = colors.shadow_gray })

hi('Folded', { fg = colors.silver_gray, bg = colors.shadow_gray })
hi('FoldColumn', { fg = colors.graphite, bg = colors.void_black })

hi('Directory', { fg = colors.slate_teal })
hi('Title', { fg = colors.pure_white, bold = true })
hi('Question', { fg = colors.bright_teal })
hi('MoreMsg', { fg = colors.bright_teal })
hi('ModeMsg', { fg = colors.bright_teal })
hi('WarningMsg', { fg = colors.muted_orange })
hi('ErrorMsg', { fg = colors.soft_red })

hi('MatchParen', { fg = colors.bright_teal, bold = true })
hi('SpecialKey', { fg = colors.dim_gray })
hi('NonText', { fg = colors.graphite })
hi('Whitespace', { fg = colors.graphite })

-- Syntax Highlighting
hi('Comment', { fg = colors.dim_gray, italic = true })

hi('Constant', { fg = colors.deep_teal })
hi('String', { fg = colors.rose_quartz })
hi('Character', { fg = colors.rose_quartz })
hi('Number', { fg = colors.deep_teal })
hi('Boolean', { fg = colors.bright_teal })
hi('Float', { fg = colors.deep_teal })

hi('Identifier', { fg = colors.seasalt })
hi('Function', { fg = colors.pure_white, bold = true })

hi('Statement', { fg = colors.bright_teal, italic = true })
hi('Conditional', { fg = colors.bright_teal, italic = true })
hi('Repeat', { fg = colors.bright_teal, italic = true })
hi('Label', { fg = colors.bright_teal })
hi('Operator', { fg = colors.slate_teal })
hi('Keyword', { fg = colors.bright_teal, italic = true })
hi('Exception', { fg = colors.bright_teal, italic = true })

hi('PreProc', { fg = colors.bright_teal })
hi('Include', { fg = colors.bright_teal })
hi('Define', { fg = colors.bright_teal })
hi('Macro', { fg = colors.bright_teal })
hi('PreCondit', { fg = colors.bright_teal })

hi('Type', { fg = colors.slate_teal })
hi('StorageClass', { fg = colors.slate_teal })
hi('Structure', { fg = colors.slate_teal })
hi('Typedef', { fg = colors.slate_teal })

hi('Special', { fg = colors.light_gray })
hi('SpecialChar', { fg = colors.bright_teal })
hi('Tag', { fg = colors.slate_teal })
hi('Delimiter', { fg = colors.silver_gray })
hi('SpecialComment', { fg = colors.storm_gray, italic = true })
hi('Debug', { fg = colors.soft_red })

hi('Underlined', { fg = colors.bright_teal, underline = true })
hi('Ignore', { fg = colors.dim_gray })
hi('Error', { fg = colors.soft_red, bold = true })
hi('Todo', { fg = colors.muted_orange, bold = true })

-- Treesitter
hi('@variable', { fg = colors.seasalt })
hi('@variable.builtin', { fg = colors.bright_teal })
hi('@variable.parameter', { fg = colors.light_gray })
hi('@variable.member', { fg = colors.seasalt })

hi('@constant', { fg = colors.deep_teal })
hi('@constant.builtin', { fg = colors.deep_teal })
hi('@constant.macro', { fg = colors.bright_teal })

hi('@string', { fg = colors.rose_quartz })
hi('@string.escape', { fg = colors.bright_teal })
hi('@string.special', { fg = colors.bright_teal })

hi('@character', { fg = colors.rose_quartz })
hi('@number', { fg = colors.deep_teal })
hi('@boolean', { fg = colors.bright_teal })
hi('@float', { fg = colors.deep_teal })

hi('@function', { fg = colors.pure_white, bold = true })
hi('@function.builtin', { fg = colors.pure_white, bold = true })
hi('@function.macro', { fg = colors.bright_teal })
hi('@function.method', { fg = colors.pure_white, bold = true })

hi('@constructor', { fg = colors.slate_teal })
hi('@operator', { fg = colors.slate_teal })
hi('@keyword', { fg = colors.bright_teal, italic = true })
hi('@keyword.function', { fg = colors.bright_teal, italic = true })
hi('@keyword.operator', { fg = colors.slate_teal })
hi('@keyword.return', { fg = colors.bright_teal, italic = true })

hi('@type', { fg = colors.slate_teal })
hi('@type.builtin', { fg = colors.slate_teal })
hi('@type.qualifier', { fg = colors.bright_teal })

hi('@property', { fg = colors.seasalt })
hi('@field', { fg = colors.seasalt })
hi('@parameter', { fg = colors.light_gray })

hi('@tag', { fg = colors.slate_teal })
hi('@tag.attribute', { fg = colors.light_gray })
hi('@tag.delimiter', { fg = colors.silver_gray })

hi('@comment', { fg = colors.dim_gray, italic = true })
hi('@comment.todo', { fg = colors.muted_orange, bold = true })
hi('@comment.warning', { fg = colors.muted_orange, bold = true })
hi('@comment.note', { fg = colors.info_blue })
hi('@comment.error', { fg = colors.soft_red, bold = true })

hi('@punctuation.delimiter', { fg = colors.silver_gray })
hi('@punctuation.bracket', { fg = colors.silver_gray })
hi('@punctuation.special', { fg = colors.bright_teal })

-- LSP Semantic Tokens
hi('@lsp.type.class', { fg = colors.slate_teal })
hi('@lsp.type.decorator', { fg = colors.bright_teal })
hi('@lsp.type.enum', { fg = colors.slate_teal })
hi('@lsp.type.enumMember', { fg = colors.deep_teal })
hi('@lsp.type.function', { fg = colors.pure_white, bold = true })
hi('@lsp.type.interface', { fg = colors.slate_teal })
hi('@lsp.type.macro', { fg = colors.bright_teal })
hi('@lsp.type.method', { fg = colors.pure_white, bold = true })
hi('@lsp.type.namespace', { fg = colors.slate_teal })
hi('@lsp.type.parameter', { fg = colors.light_gray })
hi('@lsp.type.property', { fg = colors.seasalt })
hi('@lsp.type.struct', { fg = colors.slate_teal })
hi('@lsp.type.type', { fg = colors.slate_teal })
hi('@lsp.type.typeParameter', { fg = colors.slate_teal })
hi('@lsp.type.variable', { fg = colors.seasalt })

-- Diagnostics
hi('DiagnosticError', { fg = colors.soft_red })
hi('DiagnosticWarn', { fg = colors.muted_orange })
hi('DiagnosticInfo', { fg = colors.info_blue })
hi('DiagnosticHint', { fg = colors.bright_teal })
hi('DiagnosticOk', { fg = colors.bright_teal })

hi('DiagnosticUnderlineError', { sp = colors.soft_red, undercurl = true })
hi('DiagnosticUnderlineWarn', { sp = colors.muted_orange, undercurl = true })
hi('DiagnosticUnderlineInfo', { sp = colors.info_blue, undercurl = true })
hi('DiagnosticUnderlineHint', { sp = colors.bright_teal, undercurl = true })

hi('DiagnosticVirtualTextError', { fg = colors.soft_red, bg = colors.shadow_gray })
hi('DiagnosticVirtualTextWarn', { fg = colors.muted_orange, bg = colors.shadow_gray })
hi('DiagnosticVirtualTextInfo', { fg = colors.info_blue, bg = colors.shadow_gray })
hi('DiagnosticVirtualTextHint', { fg = colors.bright_teal, bg = colors.shadow_gray })

hi('DiagnosticSignError', { fg = colors.soft_red })
hi('DiagnosticSignWarn', { fg = colors.muted_orange })
hi('DiagnosticSignInfo', { fg = colors.info_blue })
hi('DiagnosticSignHint', { fg = colors.bright_teal })

-- Git Signs
hi('DiffAdd', { fg = colors.bright_teal, bg = colors.muted_teal })
hi('DiffChange', { fg = colors.bright_teal, bg = colors.shadow_gray })
hi('DiffDelete', { fg = colors.soft_red, bg = colors.shadow_gray })
hi('DiffText', { fg = colors.bright_teal, bg = colors.deep_charcoal })

hi('diffAdded', { fg = colors.bright_teal })
hi('diffRemoved', { fg = colors.soft_red })
hi('diffChanged', { fg = colors.bright_teal })
hi('diffFile', { fg = colors.slate_teal })
hi('diffNewFile', { fg = colors.bright_teal })
hi('diffLine', { fg = colors.info_blue })

-- Mini.nvim specific
hi('MiniCursorword', { underline = true })
hi('MiniCursorwordCurrent', { underline = false })

hi('MiniStatuslineDevinfo', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('MiniStatuslineFileinfo', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('MiniStatuslineFilename', { fg = colors.light_gray, bg = colors.void_black })
hi('MiniStatuslineInactive', { fg = colors.dim_gray, bg = colors.shadow_gray })
hi('MiniStatuslineModeNormal', { fg = colors.void_black, bg = colors.bright_teal, bold = true })
hi('MiniStatuslineModeInsert', { fg = colors.void_black, bg = colors.info_blue, bold = true })
hi('MiniStatuslineModeVisual', { fg = colors.void_black, bg = colors.bright_teal, bold = true })
hi('MiniStatuslineModeReplace', { fg = colors.void_black, bg = colors.soft_red, bold = true })
hi('MiniStatuslineModeCommand', { fg = colors.void_black, bg = colors.slate_teal, bold = true })
hi('MiniStatuslineModeOther', { fg = colors.void_black, bg = colors.rose_quartz, bold = true })

hi('MiniTablineCurrent', { fg = colors.seasalt, bg = colors.eerie_black, bold = true })
hi('MiniTablineFill', { bg = colors.void_black })
hi('MiniTablineHidden', { fg = colors.dim_gray, bg = colors.void_black })
hi('MiniTablineModifiedCurrent', { fg = colors.muted_orange, bg = colors.eerie_black, bold = true })
hi('MiniTablineModifiedHidden', { fg = colors.muted_orange, bg = colors.void_black })
hi('MiniTablineModifiedVisible', { fg = colors.muted_orange, bg = colors.shadow_gray })
hi('MiniTablineVisible', { fg = colors.light_gray, bg = colors.shadow_gray })

hi('MiniDiffSignAdd', { fg = colors.bright_teal })
hi('MiniDiffSignChange', { fg = colors.muted_orange })
hi('MiniDiffSignDelete', { fg = colors.soft_red })

hi('MiniPickBorder', { fg = colors.shadow_gray, bg = colors.deep_charcoal })
hi('MiniPickBorderBusy', { fg = colors.muted_orange, bg = colors.deep_charcoal })
hi('MiniPickBorderText', { fg = colors.bright_teal, bg = colors.deep_charcoal })
hi('MiniPickIconDirectory', { fg = colors.slate_teal })
hi('MiniPickIconFile', { fg = colors.seasalt })
hi('MiniPickHeader', { fg = colors.pure_white, bold = true })
hi('MiniPickMatchCurrent', { bg = colors.dark_teal })
hi('MiniPickMatchMarked', { fg = colors.bright_teal, bold = true })
hi('MiniPickMatchRanges', { fg = colors.muted_orange, bold = true })
hi('MiniPickNormal', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('MiniPickPreviewLine', { bg = colors.deep_charcoal })
hi('MiniPickPreviewRegion', { bg = colors.dark_teal })
hi('MiniPickPrompt', { fg = colors.bright_teal, bg = colors.deep_charcoal, bold = true })

hi('MiniStarterCurrent', { fg = colors.bright_teal, underline = true })
hi('MiniStarterFooter', { fg = colors.dim_gray, italic = true })
hi('MiniStarterHeader', { fg = colors.bright_teal })
hi('MiniStarterInactive', { fg = colors.dim_gray })
hi('MiniStarterItem', { fg = colors.seasalt })
hi('MiniStarterItemBullet', { fg = colors.slate_teal })
hi('MiniStarterItemPrefix', { fg = colors.bright_teal })
hi('MiniStarterSection', { fg = colors.pure_white, bold = true })
hi('MiniStarterQuery', { fg = colors.bright_teal })

hi('MiniIndentscopeSymbol', { fg = colors.slate_teal })
hi('MiniIndentscopePrefix', { nocombine = true })

hi('MiniJump', { fg = colors.void_black, bg = colors.bright_teal, bold = true })
hi('MiniJump2dSpot', { fg = colors.void_black, bg = colors.bright_teal, bold = true })
hi('MiniJump2dSpotAhead', { fg = colors.void_black, bg = colors.slate_teal, bold = true })
hi('MiniJump2dSpotUnique', { fg = colors.void_black, bg = colors.bright_teal, bold = true })

hi('MiniMapNormal', { fg = colors.seasalt, bg = colors.void_black })
hi('MiniMapSymbolCount', { fg = colors.bright_teal })
hi('MiniMapSymbolLine', { fg = colors.slate_teal })
hi('MiniMapSymbolView', { fg = colors.muted_orange })

hi('MiniNotifyBorder', { fg = colors.shadow_gray, bg = colors.deep_charcoal })
hi('MiniNotifyNormal', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('MiniNotifyTitle', { fg = colors.bright_teal, bg = colors.deep_charcoal })

hi('MiniFilesBorder', { fg = colors.shadow_gray, bg = colors.deep_charcoal })
hi('MiniFilesBorderModified', { fg = colors.muted_orange, bg = colors.deep_charcoal })
hi('MiniFilesCursorLine', { bg = colors.dark_teal })
hi('MiniFilesDirectory', { fg = colors.slate_teal })
hi('MiniFilesFile', { fg = colors.seasalt })
hi('MiniFilesNormal', { fg = colors.seasalt, bg = colors.deep_charcoal })
hi('MiniFilesTitle', { fg = colors.bright_teal, bg = colors.deep_charcoal, bold = true })
hi('MiniFilesTitleFocused', { fg = colors.pure_white, bg = colors.slate_teal, bold = true })

hi('MiniHipatternsFixme', { fg = colors.void_black, bg = colors.soft_red, bold = true })
hi('MiniHipatternsHack', { fg = colors.void_black, bg = colors.bright_teal, bold = true })
hi('MiniHipatternsTodo', { fg = colors.void_black, bg = colors.info_blue, bold = true })
hi('MiniHipatternsNote', { fg = colors.void_black, bg = colors.bright_teal, bold = true })

hi('MiniCompletionActiveParameter', { underline = true })

hi('MiniTrailspace', { bg = colors.soft_red })
