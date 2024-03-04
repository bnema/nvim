-- File: lua/custom/plugins/copilot.lua

return {
	{
		'code-biscuits/nvim-biscuits',
		requires = {
			'nvim-treesitter/nvim-treesitter',
			run = ':TSUpdate'
		},
	}
}
