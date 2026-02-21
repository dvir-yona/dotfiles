return {
	{
		'lewis6991/gitsigns.nvim',
		opts = {
			on_attach = function(bufnr)
				local gitsigns = require 'gitsigns'
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- navigation
				map('n', ']c', function()
					if vim.wo.diff then
						vim.cmd.normal { ']c', bang = true }
					else
						gitsigns.nav_hunk 'next'
					end
				end, { desc = 'jump to next git [c]hange' })
				map('n', '[c', function()
					if vim.wo.diff then
						vim.cmd.normal { '[c', bang = true }
					else
						gitsigns.nav_hunk 'prev'
					end
				end, { desc = 'jump to previous git [c]hange' })

				-- actions
				-- visual mode
				map('v', '<leader>hs', function()
					gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
				end, { desc = 'git [s]tage hunk' })
				map('v', '<leader>hr', function()
					gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
				end, { desc = 'git [r]eset hunk' })
				-- normal mode
				map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
				map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
				map('n', '<leader>hs', gitsigns.stage_buffer, { desc = 'git [s]tage buffer' })
				map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
				map('n', '<leader>hr', gitsigns.reset_buffer, { desc = 'git [r]eset buffer' })
				map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
				map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
				map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
				map('n', '<leader>hd', function()
					gitsigns.diffthis '@'
				end, { desc = 'git [d]iff against last commit' })
				map('n', '<leader>ho', function()
					local telescope = require 'telescope.builtin'
					local actions = require 'telescope.actions'
					local action_state = require 'telescope.actions.state'
					local gitsigns = require 'gitsigns'

					telescope.git_commits {
						attach_mappings = function(prompt_bufnr, map)
							local diff_against_commit = function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if selection then
									gitsigns.diffthis(selection.value)
								end
							end

							-- Override <CR> in normal and insert mode
							map('n', '<CR>', diff_against_commit)
							map('i', '<CR>', diff_against_commit)

							-- Keep default actions for other keys
							return true
						end,
					}
				end, { desc = 'git [d]iff against [o]lder commit' })
				map('n', '<leader>ha', function()
					local telescope = require 'telescope.builtin'
					local actions = require 'telescope.actions'
					local action_state = require 'telescope.actions.state'

					telescope.git_commits {
						attach_mappings = function(prompt_bufnr, map)
							local show_all_changes = function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if selection then
									vim.cmd('new | set ft=diff | r!git diff ' .. selection.value .. ' HEAD')
								end
							end

							-- Override <CR> in normal and insert mode
							map('n', '<CR>', show_all_changes)
							map('i', '<CR>', show_all_changes)

							-- Keep default actions for other keys
							return true
						end,
					}
				end, { desc = 'git show [a]ll changes since commit' })
				-- toggles
				map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[t]oggle git show [b]lame line' })
				map('n', '<leader>td', gitsigns.preview_hunk_inline, { desc = '[t]oggle git show [d]eleted' })
			end,
		},
	},
}
