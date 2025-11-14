-- Yank operations with context metadata
-- Provides various yank commands that copy text with file path, line numbers, and diagnostics

local M = {}

-- ============================================
-- Helper Functions
-- ============================================

-- Get file path relative to git root (or cwd as fallback)
local function get_relative_path(file_path)
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
  if vim.v.shell_error == 0 and git_root then
    return vim.fn.fnamemodify(file_path, ':s?' .. git_root .. '/??')
  else
    return vim.fn.fnamemodify(file_path, ':~:.')
  end
end

-- Get line text from buffer
local function get_line_text(bufnr, lnum)
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, lnum, lnum + 1, false)
  if ok and lines[1] then
    return lines[1]
  end
  return ''
end

-- Format diagnostic with severity prefix
local function format_diagnostic(diag)
  local severity = vim.diagnostic.severity[diag.severity]
  return string.format('[%s] %s', severity, diag.message)
end

-- Copy to clipboard and show notification
local function yank_to_clipboard(text, message)
  vim.fn.setreg('+', text)
  vim.notify(message, vim.log.levels.INFO)
end

-- Build context header for file and line range
local function build_context_header(relative_path, start_line, end_line)
  if start_line == end_line then
    return string.format('From: %s (line %d)', relative_path, start_line)
  else
    return string.format('From: %s (lines %d-%d)', relative_path, start_line, end_line)
  end
end

-- ============================================
-- Yank Operations
-- ============================================

-- Yank line (plain text, no context)
function M.yank_line()
  local line = vim.fn.getline('.')
  yank_to_clipboard(line, 'Yanked line to clipboard')
end

-- Yank diagnostic message(s) only (no context)
function M.yank_diagnostic()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
  if #diagnostics == 0 then
    vim.notify('No diagnostics on current line', vim.log.levels.WARN)
    return
  end

  local messages = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(messages, diag.message)
  end

  local text = table.concat(messages, '\n')
  yank_to_clipboard(text, 'Yanked diagnostic(s) to clipboard')
end

-- Yank diagnostic with context (current line)
function M.yank_diagnostic_with_context()
  local line_num = vim.fn.line('.')
  local diagnostics = vim.diagnostic.get(0, { lnum = line_num - 1 })

  if #diagnostics == 0 then
    vim.notify('No diagnostics on current line', vim.log.levels.WARN)
    return
  end

  local file_path = vim.fn.expand('%:p')
  local relative_path = get_relative_path(file_path)
  local line_text = vim.fn.getline('.')

  -- Format diagnostics with severity
  local messages = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(messages, format_diagnostic(diag))
  end
  local diag_text = table.concat(messages, '\n')

  -- Build context
  local context = string.format('%s\n\n%s\n\nDiagnostic:\n%s',
    build_context_header(relative_path, line_num, line_num),
    line_text,
    diag_text
  )

  yank_to_clipboard(context, string.format('Yanked diagnostic with context: %s:%d', relative_path, line_num))
end

-- Yank all buffer diagnostics with context
function M.yank_buffer_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local all_diagnostics = vim.diagnostic.get(bufnr)

  if #all_diagnostics == 0 then
    vim.notify('No diagnostics in current buffer', vim.log.levels.WARN)
    return
  end

  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local relative_path = get_relative_path(file_path)

  -- Sort diagnostics by line number
  table.sort(all_diagnostics, function(a, b)
    return a.lnum < b.lnum
  end)

  -- Build output
  local output = {}
  table.insert(output, string.format('Buffer Diagnostics: %s (%d total)\n', relative_path, #all_diagnostics))
  table.insert(output, string.rep('=', 80) .. '\n')

  for _, diag in ipairs(all_diagnostics) do
    local line_num = diag.lnum + 1  -- Convert 0-indexed to 1-indexed
    local line_text = get_line_text(bufnr, diag.lnum)

    table.insert(output, string.format('\nLine %d:', line_num))
    if line_text ~= '' then
      table.insert(output, string.format('\n%s', line_text))
    end
    table.insert(output, string.format('\nDiagnostic: %s\n', format_diagnostic(diag)))
  end

  local context = table.concat(output, '')
  yank_to_clipboard(context, string.format('Yanked %d buffer diagnostics to clipboard', #all_diagnostics))
end

-- Yank all workspace diagnostics with context
function M.yank_workspace_diagnostics()
  local all_diagnostics = vim.diagnostic.get(nil)

  if #all_diagnostics == 0 then
    vim.notify('No diagnostics in workspace', vim.log.levels.WARN)
    return
  end

  -- Group diagnostics by buffer
  local diag_by_buffer = {}
  for _, diag in ipairs(all_diagnostics) do
    local bufnr = diag.bufnr
    if not diag_by_buffer[bufnr] then
      diag_by_buffer[bufnr] = {}
    end
    table.insert(diag_by_buffer[bufnr], diag)
  end

  -- Build output
  local output = {}
  table.insert(output, string.format('Workspace Diagnostics (%d total)\n', #all_diagnostics))
  table.insert(output, string.rep('=', 80) .. '\n')

  -- Sort buffers for consistent output
  local bufnrs = vim.tbl_keys(diag_by_buffer)
  table.sort(bufnrs)

  for _, bufnr in ipairs(bufnrs) do
    local diagnostics = diag_by_buffer[bufnr]
    local file_path = vim.api.nvim_buf_get_name(bufnr)
    local relative_path = get_relative_path(file_path)

    -- Sort diagnostics by line number
    table.sort(diagnostics, function(a, b)
      return a.lnum < b.lnum
    end)

    -- Add each diagnostic with context
    for _, diag in ipairs(diagnostics) do
      local line_num = diag.lnum + 1  -- Convert 0-indexed to 1-indexed
      local line_text = ''

      if vim.api.nvim_buf_is_loaded(bufnr) then
        line_text = get_line_text(bufnr, diag.lnum)
      end

      table.insert(output, string.format('\nFrom: %s (line %d)', relative_path, line_num))
      if line_text ~= '' then
        table.insert(output, string.format('\n%s', line_text))
      end
      table.insert(output, string.format('\nDiagnostic: %s\n', format_diagnostic(diag)))
    end
  end

  local context = table.concat(output, '')
  yank_to_clipboard(context, string.format('Yanked %d workspace diagnostics to clipboard', #all_diagnostics))
end

-- Yank current line with context
function M.yank_line_with_context()
  local line_num = vim.fn.line('.')
  local file_path = vim.fn.expand('%:p')
  local relative_path = get_relative_path(file_path)
  local line_text = vim.fn.getline('.')

  local context = string.format('%s\n\n%s',
    build_context_header(relative_path, line_num, line_num),
    line_text
  )

  yank_to_clipboard(context, string.format('Yanked with context: %s:%d', relative_path, line_num))
end

-- Yank visual selection with context
function M.yank_selection_with_context()
  -- Get visual selection range
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')

  -- Ensure start_line <= end_line
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local file_path = vim.fn.expand('%:p')
  local relative_path = get_relative_path(file_path)

  -- Get the selected text
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg('v')

  local context = string.format('%s\n\n%s',
    build_context_header(relative_path, start_line, end_line),
    selected_text
  )

  yank_to_clipboard(context, string.format('Yanked with context: %s:%d-%d', relative_path, start_line, end_line))
end

return M
