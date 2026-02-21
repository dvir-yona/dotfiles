return {
	{
		'mfussenegger/nvim-dap',
		dependencies = {
			-- DAP UI
			{
				'rcarriga/nvim-dap-ui',
				dependencies = { 'nvim-neotest/nvim-nio' },
				keys = {
					{
						'<leader>du',
						function()
							require('dapui').toggle()
						end,
						desc = '[D]ebug: Toggle [u]I',
					},
					{
						'<leader>de',
						function()
							require('dapui').eval()
						end,
						desc = '[D]ebug: [e]valuate',
					},
					{
						'<leader>dv',
						function()
							require('dapui').toggle 'scopes'
						end,
						desc = '[D]ebug: Toggle [v]ariables View',
					},
					{
						'<leader>ds',
						function()
							require('dapui').toggle 'stacks'
						end,
						desc = '[D]ebug: Toggle [s]tack Trace View',
					},
				},
				opts = {
					layouts = {
						{
							elements = {
								{ id = 'scopes', size = 0.25 },
								{ id = 'breakpoints', size = 0.25 },
								{ id = 'stacks', size = 0.25 },
								{ id = 'watches', size = 0.25 },
							},
							size = 40,
							position = 'left',
						},
						{
							elements = {
								{ id = 'repl', size = 0.5 },
								{ id = 'console', size = 0.5 },
							},
							size = 10,
							position = 'bottom',
						},
					},
					floating = { border = 'rounded' },
					controls = { enabled = true },
				},
				config = function(_, opts)
					local dap = require 'dap'
					local dapui = require 'dapui'
					dapui.setup(opts)

					-- Auto-open/close DAP UI
					dap.listeners.after.event_initialized['dapui_config'] = function()
						dapui.open()
					end
					dap.listeners.before.event_terminated['dapui_config'] = function()
						dapui.close()
					end
					dap.listeners.before.event_exited['dapui_config'] = function()
						dapui.close()
					end
				end,
			},
			-- Mason integration for DAP adapters
			{
				'jay-babu/mason-nvim-dap.nvim',
				dependencies = {
					'williamboman/mason.nvim',
				},
				opts = {
					ensure_installed = { 'codelldb' },
					automatic_installation = true,
					handlers = {},
				},
			},
		},
		keys = {
			{
				'<leader>db',
				function()
					require('dap').toggle_breakpoint()
				end,
				desc = '[D]ebug: Toggle [b]reakpoint',
			},
			{
				'<leader>di',
				function()
					require('dap').step_into()
				end,
				desc = '[D]ebug: Step [i]nto',
			},
			{
				'<leader>do',
				function()
					require('dap').step_over()
				end,
				desc = '[D]ebug: Step [O]ver',
			},
			{
				'<leader>dO',
				function()
					require('dap').step_out()
				end,
				desc = '[D]ebug: Step [o]ut',
			},
			{
				'<leader>dr',
				function()
					require('dap').repl.open()
				end,
				desc = '[D]ebug: [r]EPL',
			},
			{
				'<leader>dl',
				function()
					require('dap').run_last()
				end,
				desc = '[D]ebug: Run [l]ast',
			},
			{
				'<leader>dt',
				function()
					require('dap').terminate()
				end,
				desc = '[D]ebug: [t]erminate Session',
			},
		},
		config = function()
			local dap = require 'dap'

			dap.adapters.codelldb = {
				type = 'server',
				port = '${port}',
				executable = {
					command = 'codelldb',
					args = { '--port', '${port}' },
				},
			}

			local XmakeTable = {
				name = 'Launch via xmake',
				type = 'codelldb',
				request = 'launch',
				program = function()
					vim.schedule(function()
						vim.cmd 'Xmake debug'
					end)
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
			}

			dap.configurations.cpp = dap.configurations.cpp or {}
			table.insert(dap.configurations.cpp, 1, XmakeTable)
			dap.configurations.c = dap.configurations.c or {}
			table.insert(dap.configurations.c, 1, XmakeTable)

			local source_buf = nil

			local function launch_or_continue()
				source_buf = vim.api.nvim_get_current_buf()
				dap.continue()
			end

			local function focus_code()
				if source_buf then
					local win = vim.fn.bufwinid(source_buf)
					if win > 0 then
						vim.api.nvim_set_current_win(win)
						return
					end
				end
				-- Fallback: close UI to refocus code
				require('dapui').close()
				source_buf = nil
			end

			local function focus_panel(element_id)
				local dapui = require 'dapui'
				if not dapui.is_open() then
					dapui.open()
				end
				-- Try to find and focus in layout
				local config = dapui.get_config()
				for _, layout in ipairs(config.layouts) do
					for i, el in ipairs(layout.elements) do
						if el.id == element_id then
							local win = layout.windows[i]
							if win and vim.api.nvim_win_is_valid(win) then
								vim.api.nvim_set_current_win(win)
								return
							end
						end
					end
				end
				-- Fallback: open floating and enter
				dapui.float_element(element_id, { enter = true })
			end

			vim.keymap.set('n', '<leader>dc', launch_or_continue, { desc = '[D]ebug: [c]ontinue' })
			vim.keymap.set('n', '<leader>dfv', function()
				focus_panel 'scopes'
			end, { desc = '[D]ebug: [f]ocus [v]ariables View' })
			vim.keymap.set('n', '<leader>dfs', function()
				focus_panel 'stacks'
			end, { desc = '[D]ebug: [f]ocus [s]tack View' })
			vim.keymap.set('n', '<leader>dfc', focus_code, { desc = '[D]ebug: [f]ocus [c]ode View' })
		end,
	},
}
