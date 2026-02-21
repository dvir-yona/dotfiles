return {
	{
		'evesdropper/luasnip-latex-snippets.nvim',
	},
	{
		'jghauser/follow-md-links.nvim',
	},
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			latex = {
				enabled = false,
			},
		},
	},
	{
		'folke/snacks.nvim',
		priority = 1000,
		lazy = false,
		opts = {
			image = {
				formats = {
					'png',
					'jpg',
					'jpeg',
					'gif',
					'bmp',
					'webp',
					'tiff',
					'heic',
					'avif',
					'mp4',
					'mov',
					'avi',
					'mkv',
					'webm',
					'pdf',
					'icns',
				},
				doc = {
					enabled = true,
					inline = true,
					float = true,
					max_width = 80,
					max_height = 40,
				},
				cache = vim.fn.stdpath 'cache' .. '/snacks/image',
				enabled = true,
				icons = {
					math = '󰪚 ',
					chart = '󰄧 ',
					image = ' ',
				},
				convert = {
					notify = true,
					---@type snacks.image.args
					mermaid = function()
						local theme = vim.o.background == 'light' and 'neutral' or 'dark'
						return { '-i', '{src}', '-o', '{file}', '-b', 'transparent', '-t', theme, '-s', '{scale}' }
					end,
					---@type table<string,snacks.image.args>
					magick = {
						default = { '{src}[0]', '-scale', '1920x1080>' },
						vector = { '-density', 192, '{src}[{page}]' },
						math = { '-density', 192, '{src}[{page}]', '-trim' },
						pdf = { '-density', 192, '{src}[{page}]', '-background', 'white', '-alpha', 'remove', '-trim' },
					},
				},
				math = {
					latex = {
						font_size = 'large',
						packages = { 'amsmath', 'amssymb', 'amsfonts', 'amscd', 'mathtools', 'mhchem' },
						tpl = [[
        \documentclass[preview,border=0pt,varwidth,12pt]{standalone}
        \usepackage{${packages}}
        \begin{document}
        ${header}
        { \${font_size} \selectfont
          \color[HTML]{${color}}
        ${content}}
        \end{document}]],
					},
				},
			},
			input = { enabled = true },
		},
	},
}
