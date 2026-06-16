-- Auto-reload buffers when files are changed externally
-- Neovim 0.13+ provides a native file watcher (nvim.autoread) that handles live reload
-- of files modified by external tools (AI assistants, formatters, git, etc.).

vim.opt.autoread = true
