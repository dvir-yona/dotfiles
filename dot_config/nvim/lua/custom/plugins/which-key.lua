return {
	{ -- Useful plugin to show you pending keybinds.
		'folke/which-key.nvim',
		event = 'VimEnter',
		opts = {
			delay = 0,
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = '<Up> ',
					Down = '<Down> ',
					Left = '<Left> ',
					Right = '<Right> ',
					C = '<C-…> ',
					M = '<M-…> ',
					D = '<D-…> ',
					S = '<S-…> ',
					CR = '<CR> ',
					Esc = '<Esc> ',
					ScrollWheelDown = '<ScrollWheelDown> ',
					ScrollWheelUp = '<ScrollWheelUp> ',
					NL = '<NL> ',
					BS = '<BS> ',
					Space = '<Space> ',
					Tab = '<Tab> ',
					F1 = '<F1>',
					F2 = '<F2>',
					F3 = '<F3>',
					F4 = '<F4>',
					F5 = '<F5>',
					F6 = '<F6>',
					F7 = '<F7>',
					F8 = '<F8>',
					F9 = '<F9>',
					F10 = '<F10>',
					F11 = '<F11>',
					F12 = '<F12>',
				},
			},
			spec = {
				{ '<leader>s', group = '[S]earch' },
				{ '<leader>t', group = '[T]oggle' },
				{ '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
				{ '<leader>l', group = '[L]sp' },
				{ '<leader>d', group = '[D]ebug' },
				{ '<leader>df', group = '[D]ebug [F]ocus' },
			},
		},
		config = function(_, opts)
			require('which-key').setup(opts)
			-- lua/custom/persistent_whichkey.lua

			local M = {}
			-- This variable will hold the state of our persistent mode.
			local is_active = false
			-- Create a dedicated autocommand group to easily manage our autocmd.
			local augroup = vim.api.nvim_create_augroup('PersistentWhichKey', { clear = true })
			--- Stops the persistent WhichKey mode.
			function M.stop()
				if not is_active then
					return
				end
				is_active = false
				-- Clear the autocmd to stop the loop.
				vim.api.nvim_clear_autocmds { group = augroup }
				vim.notify('Persistent WhichKey mode stopped.', vim.log.levels.INFO)
			end
			--- Starts the persistent WhichKey mode.
			function M.start()
				-- If it's already running, do nothing.
				if is_active then
					vim.notify('Persistent WhichKey is already active.', vim.log.levels.WARN)
					return
				end
				is_active = true
				vim.notify('Persistent WhichKey started. Press <C-Esc> to stop.', vim.log.levels.INFO)
				-- This is the core of the solution.
				-- The 'SafeState' event fires when Neovim is idle and waiting for user input.
				-- After you close which-key (or run a command from it), Neovim will eventually
				-- enter this state, and our autocmd will re-trigger which-key.
				vim.api.nvim_create_autocmd('SafeState', {
					group = augroup,
					pattern = '*',
					callback = function()
						-- We check the flag again because the autocmd might fire
						-- right as we are trying to disable it.
						if is_active then
							-- We use defer_fn to avoid potential recursion issues with autocmds
							-- and ensure the UI has settled before showing the popup.
							vim.defer_fn(function()
								-- Final check
								if is_active then
									require('which-key').show()
								end
							end, 10) -- 10ms delay is usually sufficient
						end
					end,
				})
				-- Show which-key for the first time to kick off the loop.
				require('which-key').show()
			end
			--- Toggles the persistent mode on and off.
			function M.toggle()
				if is_active then
					M.stop()
				else
					M.start()
				end
			end

			vim.keymap.set('n', '<leader>?', M.toggle, { desc = 'Toggle Persistent WhichKey (Control-C to stop)' })
			vim.keymap.set({ 'n', 'i', 'v' }, '<C-c>', M.stop, { desc = 'Stop Persistent WhichKey' })
			return M
		end,
	},
}
