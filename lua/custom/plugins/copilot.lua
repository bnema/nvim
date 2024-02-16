-- File: lua/custom/plugins/copilot.lua

return {
	{
		"zbirenbaum/copilot.lua",
		lazy = false,
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end
	}
}
