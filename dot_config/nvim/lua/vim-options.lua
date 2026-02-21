-- NOTE: For more options, you can see `:help option-list`

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.o.number = true
vim.o.relativenumber = true
-- not needed, exsists in the status line
vim.o.showmode = false
-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'
-- Decrease update time
vim.o.updatetime = 1000
-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '> ', trail = '·', nbsp = '␣' }
-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
-- Show which line your cursor is on
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 15
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true
-- spelling
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- show all diagnostics errors and warnings in a list
vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
-- Exit terminal mode (into normal mode) in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
--  TODO: ADD MORE WINDOWS SHORTCUTS (CREATE, MOVE)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- copy indication
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
	vim.o.clipboard = 'unnamedplus'
end)

vim.opt.foldenable = false
-- A custom function to open Markdown links in Zathura, with support for page numbers.
-- This version correctly resolves paths relative to the Markdown file itself
-- and correctly finds the link under the cursor.
local function open_pdf_link_with_page()
	-- Get the directory of the current file for resolving relative paths.
	local current_file_dir = vim.fn.expand '%:p:h'

	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed column

	local link_target
	local search_start = 1 -- Start searching from the beginning of the line

	-- *** THE FIX IS HERE ***
	-- Loop through all markdown links on the line to find the one under the cursor.
	while true do
		-- Find the start and end positions of the *next* full link: [text](target)
		local start_pos, end_pos = line:find('%[[^]]*]%(.-%)', search_start)

		if not start_pos then
			break -- No more links found, exit the loop.
		end

		-- Check if the cursor is within the bounds of this link.
		-- start_pos is 1-indexed, col is 0-indexed, so we compare col with start_pos - 1.
		if col >= start_pos - 1 and col < end_pos then
			-- The cursor is inside this link. Extract the target part from between the parentheses.
			local full_link_text = line:sub(start_pos, end_pos)
			link_target = full_link_text:match '%((.*)%)'
			break -- Found our link, no need to search further.
		end

		-- Move the search position to after the link we just checked.
		search_start = end_pos + 1
	end

	if not link_target then
		print 'Error: Could not find a Markdown link under the cursor.'
		return
	end

	-- Separate the file path from the page number fragment.
	local filepath_from_link, page_number = link_target:match '([^#]+)#page=(%d+)'
	if not filepath_from_link then
		filepath_from_link = link_target
	end

	-- Determine the final, absolute path to the PDF.
	local absolute_filepath
	if filepath_from_link:match '^/' or filepath_from_link:match '^~' then
		absolute_filepath = filepath_from_link
	else
		absolute_filepath = current_file_dir .. '/' .. filepath_from_link
	end

	-- Build the final command for Zathura.
	local cmd
	if page_number then
		print('Opening ' .. absolute_filepath .. ' at page ' .. page_number)
		cmd = 'zathura --page=' .. page_number .. ' ' .. vim.fn.shellescape(absolute_filepath)
	else
		print('Opening ' .. absolute_filepath)
		cmd = 'zathura ' .. vim.fn.shellescape(absolute_filepath)
	end

	-- Execute the command silently in the background.
	vim.cmd('silent !' .. cmd .. ' &')
end

-- Map the function to "gX" in normal mode for Markdown files.
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'markdown',
	callback = function()
		vim.keymap.set('n', 'gX', open_pdf_link_with_page, {
			noremap = true,
			silent = true,
			buffer = true,
			desc = 'Open link under cursor (with PDF page support)',
		})
	end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
	pattern = { '*.cl' },
	callback = function()
		vim.bo.filetype = 'opencl'
	end,
})
