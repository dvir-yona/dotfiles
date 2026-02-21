return {
	{ -- Collection of various small independent plugins/modules
		-- TODO: Go over https://github.com/nvim-mini/mini.nvim?tab=readme-ov-file
		'echasnovski/mini.nvim',
		config = function()
			-- TODO: learn
			--
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require('mini.ai').setup { n_lines = 500 }

			-- TODO: learn
			--
			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require('mini.surround').setup()

			--TODO: look at more options https://github.com/nvim-mini/mini.nvim?tab=readme-ov-file#modules

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require 'mini.statusline'
			local function get_ssh_indicator()
				if vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil then
					return 'SSH '
				end
				return ''
			end
			statusline.setup {
				content = {
					active = function()
						local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
						local git = statusline.section_git { trunc_width = 75 }
						local diff = statusline.section_diff { trunc_width = 75 }
						local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
						local filename = statusline.section_filename { trunc_width = 140 }
						local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
						local location = statusline.section_location { trunc_width = 75 }

						local ssh = get_ssh_indicator()

						return statusline.combine_groups {
							{ hl = mode_hl, strings = { mode } },
							{ hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics } },
							-- Add the SSH indicator here (with a custom highlight if you want)
							{ hl = 'ErrorMsg', strings = { ssh } },
							'%<', -- Mark general truncate point
							{ hl = 'MiniStatuslineFilename', strings = { filename } },
							'%=', -- End left alignment
							{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
							{ hl = mode_hl, strings = { location } },
						}
					end,
				},
				use_icons = vim.g.have_nerd_font,
			}

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return '%2l:%-2v'
			end
		end,
	},
}
