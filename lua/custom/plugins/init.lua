-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{ 'akinsho/bufferline.nvim', version = "*",  dependencies = 'nvim-tree/nvim-web-devicons' },
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
	{ 'echasnovski/mini.nvim',   version = false },
	{ "nvim-neotest/nvim-nio" },
	{
		'maxmx03/solarized.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.background = 'dark' -- or 'light'

			vim.cmd.colorscheme 'solarized'
		end,
	},
}
