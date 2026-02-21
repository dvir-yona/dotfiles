return {
	{
		'Mythos-404/xmake.nvim',
		lazy = true,
		event = {
			'BufReadPost xmake.lua',
			'FileType cpp',
			'FileType c',
		},
		dependencies = {
			'MunifTanjim/nui.nvim',
			'nvim-tree/nvim-web-devicons',
			'mfussenegger/nvim-dap',
		},
		config = function()
			require('xmake').setup {
				on_save = {
					reload_project_info = true,
					lsp_compile_commands = {
						enable = true,
						output_dir = 'build',
					},
				},
				lsp = {
					enable = true,
					language = 'en',
				},
				debuger = {
					rules = { 'debug', 'releasedbg' },
					dap = {
						name = 'Xmake Debug',
						type = 'codelldb',
						request = 'launch',
						cwd = '${workspaceFolder}',
						console = 'integratedTerminal',
						stopOnEntry = false,
						runInTerminal = true,
					},
				},
			}
		end,
	},
}
