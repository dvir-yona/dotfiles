return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		'folke/lazydev.nvim',
		dependencies = {
			'LelouchHe/xmake-luals-addon',
		},
		ft = 'lua',
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = '${3rd}/luv/library', words = { 'vim%.uv' } },

				-- xmake
				{
					path = 'xmake-luals-addon/library',
					files = { 'xmake.lua' },
				},
			},
		},
	},

	{
		'neovim/nvim-lspconfig',
		dependencies = {
			{ 'mason-org/mason.nvim', opts = {} },
			'mason-org/mason-lspconfig.nvim',
			'WhoIsSethDaniel/mason-tool-installer.nvim',
			{ 'j-hui/fidget.nvim', opts = {} },
			'saghen/blink.cmp',
		},

		config = function()
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or 'n'
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
					end

					map('<leader>lr', vim.lsp.buf.rename, '[Lsp] [R]ename')
					map('<leader>la', vim.lsp.buf.code_action, '[L]sp Code [A]ction', { 'n', 'x' })
					map('<leader>lh', vim.lsp.buf.hover, '[L]sp [H]over', { 'n', 'x' })
					map('<leader>lg', require('telescope.builtin').lsp_references, '[L]sp [G]oto References')
					-- Jump to the implementation of the word under your cursor.
					map('<leader>li', require('telescope.builtin').lsp_implementations, '[L]sp Goto [I]mplementation')
					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					map('<leader>ld', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map('<leader>lD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map('<leader>lO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map('<leader>lW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map('<leader>lt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has 'nvim-0.11' == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
						local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
						vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd('LspDetach', {
							group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
						map('<leader>th', function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
						end, '[T]oggle Inlay [H]ints')
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config {
				severity_sort = true,
				float = { border = 'rounded', source = 'if_many' },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = '󰅚 ',
						[vim.diagnostic.severity.WARN] = '󰀪 ',
						[vim.diagnostic.severity.INFO] = '󰋽 ',
						[vim.diagnostic.severity.HINT] = '󰌶 ',
					},
				} or {},
				virtual_lines = {
					current_line = true,
				},
				virtual_text = {
					source = 'if_many',
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			}

			local capabilities = require('blink.cmp').get_lsp_capabilities()

			-- lsp servers only (configs go here)
			local lsp_servers = {
				zls = {},
				svelte = {},
				eslint = {
					settings = {
						format = false, -- use prettier via conform for formatting
						workingdirectories = { 'src' }, -- adjust for sveltekit structure if needed
					},
				},
				clangd = {
					-- 1. Tell clangd to attach to mpp files
					filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'mpp' },
					-- 2. Enable modules and pointing to your specific clangd executable
					cmd = {
						'/usr/bin/clangd', -- Use the system clangd (v18+) that supports modules
						'--experimental-modules-support',
						'--background-index',
						'--clang-tidy',
						'--header-insertion=iwyu',
					},
				},
				-- note: python (use pyright or ruff_lsp instead of pylsp for better perf; add if needed)
				ruff = {},
				basedpyright = {},
				-- note: go
				golangci_lint_ls = {},
				gopls = {},
				-- note: json
				jsonls = {},
				-- note: markdown
				marksman = {},
				-- note: elixir
				nextls = {},
				elixirls = {},
				-- note: js\ts
				ts_ls = {},
				-- note: java
				jdtls = {},
				-- note: general
				tailwindcss = {
					filetypes = {
						'html',
						'javascript',
						'typescript',
						'javascriptreact',
						'typescriptreact',
						'svelte',
						'vue',
						'heex',
						'elixir',
					},
					init_options = {
						userlanguages = {
							heex = 'html-eex',
							elixir = 'html-eex',
							svelte = 'html',
						},
					},
					settings = {
						tailwindcss = {
							experimental = {
								classregex = {
									'class[:]\\s*"([^"]*)"',
								},
							},
						},
					},
				},
				-- note: nvim
				lua_ls = {
					settings = {
						lua = {
							completion = {
								callsnippet = 'replace',
							},
						},
					},
				},
			}

			-- non-lsp tools (formatters, linters, debuggers)
			local tools = {
				-- note: go
				['goimports-reviser'] = {},
				['golangci-lint'] = {},
				-- note: python
				black = {},
				-- note: general
				['typos-lsp'] = {},
				prettierd = {},
				prettier = {
					install_args = { 'prettier-plugin-svelte' },
				},
				-- note: nvim
				stylua = {},
				['clang-format'] = {},
			}

			local all_ensure_installed = vim.list_extend(vim.tbl_keys(lsp_servers), vim.tbl_keys(tools))
			require('mason-tool-installer').setup { ensure_installed = all_ensure_installed }

			require('mason-lspconfig').setup {
				ensure_installed = vim.tbl_keys(lsp_servers), -- array of server names to trigger handlers
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = lsp_servers[server_name] or {} -- fixed: use lsp_servers
						server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
						require('lspconfig')[server_name].setup(server)
					end,
					['clangd'] = function()
						local clangd_capabilities = vim.tbl_deep_extend('force', {}, capabilities, {
							offsetEncoding = { 'utf-8' }, -- Fixes "multiple different encodings" warning
						})

						require('lspconfig').clangd.setup {
							capabilities = clangd_capabilities,
							-- EXPANDED FILETYPES to include mpp
							filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'mpp' },
							-- MODULES SUPPORT COMMAND
							cmd = {
								'/usr/bin/clangd', -- Using your system binary (v18+ recommended)
								'--experimental-modules-support',
								'--background-index',
								'--clang-tidy',
								'--header-insertion=iwyu',
								'--completion-style=detailed',
							},
							-- OPTIONAL: Root directory detection
							root_dir = require('lspconfig.util').root_pattern('.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', '.git'),
						}
					end,
				},
			}
			vim.lsp.set_log_level 'debug'

			vim.filetype.add {
				extension = {
					mpp = 'cpp',
				},
			}
		end,
	},

	{ -- Autoformat
		'stevearc/conform.nvim',
		event = { 'BufWritePre' },
		cmd = { 'ConformInfo' },
		keys = {
			{
				'<leader>f',
				function()
					require('conform').format { async = true, lsp_format = 'fallback' }
				end,
				mode = '',
				desc = '[F]ormat buffer',
			},
		},
		opts = {
			notify_on_error = true,
			format_after_save = function(bufnr)
				local disable_filetypes = {}
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						async = true,
						timeout_ms = 2500,
						lsp_fallback = true,
					}
				end
			end,
			formatters_by_ft = {
				lua = { 'stylua' },
				javascript = { 'prettierd', 'prettier', stop_after_first = true },
				typescript = { 'prettierd', 'prettier', stop_after_first = true },
				svelte = { 'prettierd', 'prettier', stop_after_first = true },
				java = { 'jdtls' },
				python = { 'black' },
				yaml = { 'prettierd' },
				c = { 'clang_format' },
				cpp = { 'clang_format' },
				go = { 'goimports-reviser', 'gofmt' },
				zig = { 'zigfmt' },
			},
		},
	},

	{ -- advanced snippits
		'L3MON4D3/LuaSnip',
		build = vim.fn.has 'win32' ~= 0 and 'make install_jsregexp' or nil,
		dependencies = {
			'lervag/vimtex',
			'rafamadriz/friendly-snippets',
			'benfowler/telescope-luasnip.nvim',
		},
		config = function(_, opts)
			if opts then
				require('luasnip').config.setup(opts)
			end
			vim.tbl_map(function(type)
				require('luasnip.loaders.from_' .. type).lazy_load()
			end, { 'vscode', 'snipmate', 'lua' })
			-- see https://github.com/rafamadriz/friendly-snippets/tree/main/snippets
			require('luasnip').filetype_extend('typescript', { 'tsdoc' })
			require('luasnip').filetype_extend('javascript', { 'jsdoc' })
			require('luasnip').filetype_extend('lua', { 'luadoc', 'lua' })
			require('luasnip').filetype_extend('python', { 'pydoc', 'py' })
			require('luasnip').filetype_extend('rust', { 'rustdoc' })
			require('luasnip').filetype_extend('cs', { 'csharpdoc' })
			require('luasnip').filetype_extend('java', { 'javadoc', 'java' })
			require('luasnip').filetype_extend('c', { 'cdoc', 'c' })
			require('luasnip').filetype_extend('cpp', { 'cppdoc', 'cpp' })
			require('luasnip').filetype_extend('sh', { 'shelldoc', 'shell' })
			require('luasnip').filetype_extend('markdown', { 'latex' })
			require('luasnip').filetype_extend('svelte', { 'html', 'javascript', 'typescript', 'css' })
			vim.keymap.set('n', '<leader>ls', require('telescope').extensions.luasnip.luasnip, { desc = 'LSP: ' .. '[S]nippits' })
			vim.keymap.set({ 'i', 's' }, '<C-J>', function()
				if require('luasnip').expand_or_jumpable() then
					require('luasnip').expand_or_jump()
				end
			end, { silent = true })
			vim.keymap.set({ 'i', 's' }, '<C-L>', function()
				if require('luasnip').jumpable(1) then
					require('luasnip').jump(1)
				end
			end, { silent = true, desc = 'Luasnip: Jump to Next Node' })

			vim.keymap.set({ 'i', 's' }, '<C-H>', function()
				if require('luasnip').jumpable(-1) then
					require('luasnip').jump(-1)
				end
			end, { silent = true, desc = 'Luasnip: Jump to Previous Node' })
		end,
	},

	{ -- Autocompletion
		'saghen/blink.cmp',
		event = 'VimEnter',
		build = 'cargo +nightly build --release',
		version = '*',
		dependencies = {
			'folke/lazydev.nvim',
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				-- TODO: change keybindings
				--
				-- 'default' (recommended) for mappings similar to built-in completions
				--   <c-y> to accept ([y]es) the completion.
				--    This will auto-import if your LSP supports it.
				--    This will expand snippets if the LSP sent a snippet.
				-- 'super-tab' for tab to accept
				-- 'enter' for enter to accept
				-- 'none' for no mappings
				--
				-- For an understanding of why the 'default' preset is recommended,
				-- you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				--
				-- All presets have the following mappings:
				-- <tab>/<s-tab>: move to right/left of your snippet expansion
				-- <c-space>: Open menu or open docs if already open
				-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
				-- <c-e>: Hide menu
				-- <c-k>: Toggle signature help
				--
				-- See :h blink-cmp-config-keymap for defining your own keymap
				preset = 'default',
				-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
				--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
			},
			appearance = {
				nerd_font_variant = 'mono',
			},
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},
			sources = {
				default = { 'lsp', 'path', 'snippets', 'lazydev' },
				providers = {
					lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
				},
			},
			snippets = { preset = 'luasnip' },
			fuzzy = { implementation = 'lua' },
			signature = { enabled = true },
		},
	},
}
