-- File: lua/custom/plugins/copilot.lua

return {
	{
		"zbirenbaum/copilot.lua",
		lazy = false,
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = false,
				},
				suggestion = {
					enabled = false,
					auto_trigger = true,
				}
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		lazy = false,
		config = function()
			require("copilot_cmp").setup()
		end
	}
}
