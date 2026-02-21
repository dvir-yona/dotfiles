return {
	{ -- Linting
		'mfussenegger/nvim-lint',
		event = { 'BufReadPre', 'BufNewFile' },
		config = function()
			local lint = require 'lint'

			lint.linters.zlint = {
				cmd = 'zlint',
				name = 'zlint',
				stdin = false,
				append_fname = false,
				args = { '-f', 'json', '--no-summary' },
				stream = 'stdout',
				ignore_exitcode = true,
				parser = function(output, input)
					local current_file = vim.api.nvim_buf_get_name(0)

					local diagnostics = {}
					if output == nil or output == '' then
						return diagnostics
					end

					local lines = vim.split(output, '\n', { trimempty = true })
					for _, line in ipairs(lines) do
						local ok, decoded = pcall(vim.json.decode, line)
						if ok and decoded then
							local is_current_file = false
							if decoded.source_name and decoded.source_name ~= vim.NIL then
								if string.find(current_file, decoded.source_name, 1, true) then
									is_current_file = true
								end
							end
							if is_current_file then
								local sev = vim.diagnostic.severity.WARN
								if decoded.level == 'error' then
									sev = vim.diagnostic.severity.ERROR
								end

								local msg = decoded.message or 'Linter warning'
								if decoded.help ~= nil and decoded.help ~= vim.NIL and decoded.help ~= '' then
									msg = msg .. '\nHelp: ' .. decoded.help
								end

								local labs = decoded.labels[1]

								-- Add diagnostic
								table.insert(diagnostics, {
									lnum = (labs['start'].line - 1 or 1),
									col = (labs['start'].column or 1),
									end_lnum = (labs['end'].line - 1 or 1),
									end_col = (labs['end'].column or 1),
									severity = sev,
									source = 'zlint',
									code = decoded.code,
									message = msg,
								})
							end
						end
					end
					return diagnostics
				end,
			}

			lint.linters_by_ft = {
				zig = { 'zlint' },
				elixir = { 'credo' },
				javascript = { 'eslint' },
				typescript = { 'eslint' },
				svelte = { 'eslint' },
			}

			local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
			vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
				group = lint_augroup,
				callback = function()
					if vim.bo.modifiable then
						lint.try_lint()
					end
				end,
			})
		end,
	},
}
