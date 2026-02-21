vim.g.have_nerd_font = true

if os.getenv 'SSH_CONNECTION' ~= nil then
	vim.g.clipboard = {
		name = 'OSC 52',
		copy = {
			['+'] = require('vim.ui.clipboard.osc52').copy '+',
			['*'] = require('vim.ui.clipboard.osc52').copy '*',
		},
		paste = {
			['+'] = require('vim.ui.clipboard.osc52').paste '+',
			['*'] = require('vim.ui.clipboard.osc52').paste '*',
		},
	}
end

require 'vim-options'
require 'keybindings'

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		error('Error cloning lazy.nvim:\n' .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
	{ import = 'custom.plugins' },

	-- TODO:
	-- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = '⌘',
			config = '🛠',
			event = '📅',
			ft = '📂',
			init = '⚙',
			keys = '🗝',
			plugin = '🔌',
			runtime = '💻',
			require = '🌙',
			source = '📄',
			start = '🚀',
			task = '📌',
			lazy = '💤 ',
		},
	},
})
