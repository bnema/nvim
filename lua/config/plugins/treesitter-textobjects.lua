-- Treesitter Textobjects (main branch)

local ts = require("nvim-treesitter-textobjects")
local select = require("nvim-treesitter-textobjects.select").select_textobject
local move = require("nvim-treesitter-textobjects.move")

ts.setup({ select = { lookahead = true } })

-- Selection: af/if (function), ac/ic (class)
for _, obj in ipairs({ "function", "class" }) do
  local key = obj:sub(1, 1)
  vim.keymap.set({ "x", "o" }, "a" .. key, function() select("@" .. obj .. ".outer", "textobjects") end)
  vim.keymap.set({ "x", "o" }, "i" .. key, function() select("@" .. obj .. ".inner", "textobjects") end)
end

-- Movement: ]f/[f (function), ]c/[c (class)
for _, obj in ipairs({ "function", "class" }) do
  local key = obj:sub(1, 1)
  vim.keymap.set({ "n", "x", "o" }, "]" .. key, function() move.goto_next_start("@" .. obj .. ".outer", "textobjects") end)
  vim.keymap.set({ "n", "x", "o" }, "[" .. key, function() move.goto_previous_start("@" .. obj .. ".outer", "textobjects") end)
end
