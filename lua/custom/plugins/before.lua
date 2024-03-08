return {
	'bloznelis/before.nvim',
	config = function()
		local before = require('before')
		before.setup()

		vim.keymap.set('n', '<C-,>', before.jump_to_last_edit, {})
		vim.keymap.set('n', '<C-.>', before.jump_to_next_edit, {})
	end
}
