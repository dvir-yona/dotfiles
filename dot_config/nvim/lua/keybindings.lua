local spell_ns = vim.api.nvim_create_namespace 'spell_practice'

local function practice_typo()
	vim.cmd 'normal! [s'
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line, col = cursor[1] - 1, cursor[2]

	local bad_word = vim.fn.expand '<cword>'
	local suggestions = vim.fn.spellsuggest(bad_word, 10)

	if #suggestions == 0 then
		return
	end

	vim.ui.select(suggestions, {
		prompt = "Correction for '" .. bad_word .. "':",
	}, function(choice)
		if not choice then
			return
		end

		local target_word = choice
		local typed_count = 0
		local au_group = vim.api.nvim_create_augroup('SpellPractice', { clear = true })

		vim.cmd 'normal! ciw'
		vim.api.nvim_feedkeys('a', 'n', true)

		vim.api.nvim_buf_set_extmark(0, spell_ns, line, col, {
			virt_text = { { target_word, 'Comment' } },
			virt_text_pos = 'overlay',
		})

		local function block_err(msg)
			return function()
				vim.api.nvim_echo({ { msg, 'WarningMsg' } }, false, {})
			end
		end

		local forbidden_keys = {
			'<BS>',
			'<C-h>',
			'<Del>',
			'<CR>',
			'<Tab>',
			'<Up>',
			'<Down>',
			'<Left>',
			'<Right>',
			'<Home>',
			'<End>',
			'<PageUp>',
			'<PageDown>',
		}

		for _, key in ipairs(forbidden_keys) do
			vim.keymap.set('i', key, block_err ' Locked! Only Esc or the correct letter works.', { buffer = true })
		end

		for i = 97, 122 do -- a-z
			local char = string.char(i)
			if char ~= 'c' then
				vim.keymap.set('i', '<C-' .. char .. '>', block_err ' Control keys disabled!', { buffer = true })
			end
		end

		vim.api.nvim_create_autocmd('InsertCharPre', {
			group = au_group,
			callback = function()
				local char = vim.v.char
				local expected = target_word:sub(typed_count + 1, typed_count + 1)

				if char ~= expected then
					vim.v.char = '' -- Swallow the keystroke
					vim.api.nvim_echo({ { " WRONG: Expected '" .. expected .. "'", 'ErrorMsg' } }, false, {})
				else
					typed_count = typed_count + 1
				end
			end,
		})

		vim.api.nvim_create_autocmd('TextChangedI', {
			group = au_group,
			callback = function()
				local cur = vim.api.nvim_win_get_cursor(0)
				vim.api.nvim_buf_clear_namespace(0, spell_ns, 0, -1)

				if typed_count < #target_word then
					local remaining = target_word:sub(typed_count + 1)
					vim.api.nvim_buf_set_extmark(0, spell_ns, cur[1] - 1, cur[2], {
						virt_text = { { remaining, 'Comment' } },
						virt_text_pos = 'overlay',
					})
				else
					vim.api.nvim_echo({ { ' Correct!', 'String' } }, false, {})
					vim.schedule(function()
						local finish_cur = vim.api.nvim_win_get_cursor(0)
						local bufnr = vim.api.nvim_get_current_buf()
						vim.highlight.range(
							bufnr,
							spell_ns,
							'String',
							{ finish_cur[1] - 1, finish_cur[2] - #target_word },
							{ finish_cur[1] - 1, finish_cur[2] },
							{ regtype = 'v', inclusive = true }
						)

						vim.defer_fn(function()
							if vim.api.nvim_buf_is_valid(bufnr) then
								vim.api.nvim_buf_clear_namespace(bufnr, spell_ns, 0, -1)
							end
						end, 500)
					end)
				end
			end,
		})

		local function cleanup()
			vim.api.nvim_buf_clear_namespace(0, spell_ns, 0, -1)
			vim.api.nvim_del_augroup_by_id(au_group)
			pcall(function()
				for _, key in ipairs(forbidden_keys) do
					vim.keymap.del('i', key, { buffer = true })
				end
				for i = 97, 122 do
					local char = string.char(i)
					if char ~= 'c' then
						vim.keymap.del('i', '<C-' .. char .. '>', { buffer = true })
					end
				end
			end)
		end

		vim.api.nvim_create_autocmd('InsertLeave', {
			group = au_group,
			once = true,
			callback = cleanup,
		})
	end)
end

-- DICTIONARY LOGIC
local dict_win = nil
local dict_buf = nil

local function close_dict_popup()
	if dict_win and vim.api.nvim_win_is_valid(dict_win) then
		vim.api.nvim_win_close(dict_win, true)
	end
	dict_win = nil
	dict_buf = nil
end

local function lookup_word()
	local word = vim.fn.expand '<cword>'
	if word == '' then
		return
	end

	-- 1. Fetch data
	local url = 'https://api.dictionaryapi.dev/api/v2/entries/en/' .. word
	local cmd = string.format("curl -s '%s'", url)
	local result = vim.fn.system(cmd)

	local ok, data = pcall(vim.fn.json_decode, result)
	if not ok or not data or data.message then
		print('No definition found for: ' .. word)
		return
	end

	local entry = data[1]
	local lines = {}
	local highlights = {} -- To store where to apply colors: {line_index, group, start_col, end_col}

	-- Helper to add a line and track highlights
	local function add_line(text, hl_group)
		table.insert(lines, text)
		if hl_group then
			table.insert(highlights, { #lines - 1, hl_group, 0, -1 })
		end
	end

	-- 2. Build the Content (Scott Berrevoets Style)

	-- Padding at top
	add_line ''

	-- The Word (Title)
	add_line('  ' .. entry.word, 'Title')
	add_line ''

	for _, meaning in ipairs(entry.meanings) do
		-- Part of Speech + Synonyms
		-- Example: "noun (contingency, choice, option)"
		local pos = meaning.partOfSpeech
		local synonym_text = ''

		-- Gather up to 3 synonyms to keep it clean
		if meaning.synonyms and #meaning.synonyms > 0 then
			local limit = math.min(3, #meaning.synonyms)
			local s_list = {}
			for i = 1, limit do
				table.insert(s_list, meaning.synonyms[i])
			end
			synonym_text = ' (' .. table.concat(s_list, ', ') .. ')'
		end

		local line_str = '  ' .. pos .. synonym_text
		table.insert(lines, line_str)

		-- complex highlighting for this line:
		-- 1. "noun" gets blue (Function or Identifier)
		-- 2. "(synonyms)" gets gray (Comment)
		local line_idx = #lines - 1
		table.insert(highlights, { line_idx, 'Statement', 2, 2 + #pos }) -- Blue for POS
		table.insert(highlights, { line_idx, 'Comment', 2 + #pos, -1 }) -- Gray for synonyms

		-- Definitions
		for i, def in ipairs(meaning.definitions) do
			-- Wrap text if it's too long (simple approach)
			table.insert(lines, string.format('    %d. %s', i, def.definition))
		end
		add_line '' -- Empty line between meanings
	end

	-- 3. Create Buffer and Window
	dict_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(dict_buf, 0, -1, false, lines)

	-- Apply Highlights
	for _, hl in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(dict_buf, -1, hl[2], hl[1], hl[3], hl[4])
	end

	-- Window Geometry (Wider and positioned nicely)
	-- Scott's version is wide (approx 80 chars)
	local width = math.min(80, vim.o.columns - 4)
	local height = math.min(25, #lines)

	dict_win = vim.api.nvim_open_win(dict_buf, false, {
		relative = 'cursor',
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = 'minimal',
		border = 'rounded', -- or 'single', 'double', 'solid'
		focusable = false,
	})

	-- Set wrapping so long definitions don't get cut off
	vim.api.nvim_set_option_value('wrap', true, { win = dict_win })
	vim.api.nvim_set_option_value('breakindent', true, { win = dict_win }) -- Keeps indentation on wrapped lines

	-- Auto-close
	vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
		buffer = 0,
		once = true,
		callback = close_dict_popup,
	})
end

-- MARKDOWN LINK
local function add_google_meaning_link()
	local word = vim.fn.expand '<cword>'
	if word == '' then
		return
	end
	local url = 'https://www.google.com/search?q=' .. word .. '+meaning'
	local link = string.format('[%s](%s)', word, url)
	vim.cmd('normal! ciw' .. link)
end

vim.keymap.set('n', '<leader>ml', add_google_meaning_link, { desc = 'Add Markdown Google Meaning link' })
vim.keymap.set('n', '<A-f>', practice_typo, { desc = 'Strict Forward-only practice' })

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'markdown',
	callback = function()
		vim.keymap.set('n', 'K', lookup_word, { buffer = true, desc = 'Dictionary Lookup' })
	end,
})
