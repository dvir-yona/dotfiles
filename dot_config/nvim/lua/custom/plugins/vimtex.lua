return {
	'lervag/vimtex',
	ft = { 'tex', 'bib' },

	init = function()
		vim.g.vimtex_view_method = 'zathura'
		vim.g.vimtex_compiler_method = 'latexmk'

		vim.g.vimtex_quickfix_ignore_filters = {
			'Underfull',
			'Overfull',
			'Package hyperref Warning',
		}
	end,
}
