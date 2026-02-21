return {
	{
		'stevearc/oil.nvim',
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			win_options = {
				cursorcolumn = true,
			},

			keymaps = {
				['g?'] = { 'actions.show_help', mode = 'n' },
				['<CR>'] = 'actions.select',
				['<C-s>'] = { 'actions.select', opts = { vertical = true } },
				['<C-d>'] = { 'actions.select', opts = { horizontal = true } },
				['<C-t>'] = { 'actions.select', opts = { tab = true } },
				['<C-p>'] = 'actions.preview',
				['<C-c>'] = { 'actions.close', mode = 'n' },
				['<C-l>'] = 'actions.refresh',
				['-'] = { 'actions.parent', mode = 'n' },
				['_'] = { 'actions.open_cwd', mode = 'n' },
				['`'] = { 'actions.cd', mode = 'n' },
				['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
				['gs'] = { 'actions.change_sort', mode = 'n' },
				['gx'] = 'actions.open_external',
				['g.'] = { 'actions.toggle_hidden', mode = 'n' },
				['g\\'] = { 'actions.toggle_trash', mode = 'n' },
			},

			view_options = {
				show_hidden = true,
			},
		},
		dependencies = { { 'echasnovski/mini.icons', opts = {} } },
		lazy = false,
		config = function(_, opts)
			require('oil').setup(opts)
			vim.keymap.set('n', '<leader>-', '<CMD>Oil<CR>', { desc = 'Open parent directory (oil nvim)' })
		end,
	},
}
