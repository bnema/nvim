local M = {}

function M.get_origin_base_branch()
  local handle = io.popen('git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null')
  local ref = handle and handle:read('*a') or ''
  if handle then handle:close() end

  local branch = vim.trim(ref):gsub('^refs/remotes/origin/', '')
  if branch == '' then
    branch = 'main'
  end

  return branch
end

return M
