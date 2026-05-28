-- Treesitter Configuration (main branch)

local parsers = {
  "lua", "vim", "vimdoc", "query",
  "go", "javascript", "typescript", "svelte",
  "c", "toml", "yaml",
  "html", "css", "json", "bash",
  "markdown", "markdown_inline",
}

if vim.fn.exepath("zig") ~= "" then
  table.insert(parsers, "zig")
end

require("nvim-treesitter").setup()
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  pattern = parsers,
  callback = function()
    vim.treesitter.start()                                            -- highlighting
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- indentation
  end,
})
