return {
	{ -- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		main = 'nvim-treesitter.configs',
		build = ':TSUpdate',
		lazy = false,
		opts = {
			ensure_installed = {
				'bash',
				'c',
				'diff',
				'html',
				'typescript',
				'javascript',
				'svelte',
				'lua',
				'luadoc',
				'markdown',
				'markdown_inline',
				'query',
				'vim',
				'vimdoc',
				'elixir',
				'heex',
				'latex',
				'embedded_template',
			},
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
			fold = {
				enable = true,
			},
		},
		config = function(_, opts)
			local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
			if not status_ok then
				return
			end
			configs.setup(opts)
			vim.api.nvim_create_autocmd({ 'FileType' }, {
				callback = function()
					if require('nvim-treesitter.parsers').has_parser() then
						vim.opt.foldmethod = 'expr'
						vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
					else
						vim.opt.foldmethod = 'syntax'
					end
				end,
			})
		end,
		-- TODO:
		-- There are additional nvim-treesitter modules that you can use to interact
		-- with nvim-treesitter. You should go explore a few and see what interests you:
		--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
		--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
		--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	},
}
