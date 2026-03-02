local config = require("cmdmacro.config")
local term = require("cmdmacro.term")
local ui = require("cmdmacro.ui")
local utils = require("cmdmacro.utils")

local M = {}

local state = {
	win = -1,
	buf = -1,
	contents = {},
	json_table = {},
	macros = {}
}
local data_path = vim.fn.stdpath("data") .. "/cmdmacro"
if vim.fn.isdirectory(data_path) == 0 then
	vim.fn.mkdir(data_path, "p", "448")
end
local cwd = vim.fn.getcwd()
local hashed_name = vim.fn.sha256(cwd)
local data_file = string.format("%s/%s.json", data_path, hashed_name)

---Converts data stored in JSON files to user configuration, shown in the editor buffer.
---@param data any
---@return table
local function data_to_buf(data)
	local out = {}
	for i, macro in ipairs(data[cwd].macros) do
		if i ~= 1 then
			table.insert(out, "---")
		end
		for key, value in pairs(macro) do
			if type(value) == "string" then
				table.insert(out, string.format("%s = \"%s\"", key, value))
			elseif type(value) == "table" then
				local str = ""
				for j, n in ipairs(value) do
					if j ~= 1 then
						str = str .. ", "
					end
					str = str .. '"' .. n .. '"'
				end
				table.insert(out, string.format("%s = [ %s ]", key, str))
			end
		end
	end
	return out
end

---Converts user configuration from the editor buffer to JSON data stored in files.
---@param contents any
---@return table
local function buf_to_data(contents)
	local cumul_data = {}
	local data = {}
	for i, line in ipairs(contents) do
		if line:match("^%s*$") then
			goto continue
		end
		if line:match("^%-%-%-") then
			if next(data) then
				table.insert(cumul_data, data)
			end
			data = {}
			goto continue
		end
		local key, raw_value = line:match("^%s*([%w_]+)%s*=%s*(.*)%s*$")
		assert(key and raw_value, string.format("Error: Invalid cmd-macro input in editor at line %d.", i))
		local value
		if raw_value:match("^%[") then
			value = {}
			for item in raw_value:gmatch('"([^"]+)"') do
				table.insert(value, item)
			end
		else
			value = raw_value:match('^"([^"]+)"')
		end
		data[key] = value
		::continue::
	end
	if next(data) then
		table.insert(cumul_data, data)
	end
	local out = {}
	out[cwd] = { macros = cumul_data }
	return out
end

---Loads editor buffer.
local function load_editor()
	local buf
	if vim.api.nvim_buf_is_valid(state.buf) then
		buf = state.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		state.buf = buf
	end
	local exists, data = utils.load_json_file(data_file)
	if exists then
		state.contents = data_to_buf(data)
		state.json_table = data
		state.macros = state.json_table[cwd].macros
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, state.contents)
		vim.bo[buf].modified = false
	end
	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].bufhidden = "hide"
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function() -- todo
			state.contents = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			state.json_table = buf_to_data(state.contents)
			state.macros = state.json_table[cwd].macros
			utils.write_json_file(data_file, state.json_table)
			vim.bo[buf].modified = false
			M.refresh_macros(state.macros)
		end,
		group = utils.cmdmacro_augroup
	})
end

---Returns the editor buffer number.
---@return integer
M.get_buffer = function()
	return state.buf
end

---Opens the editor window.
---@param opts cmdmacro.editor_config
M.open_editor = function(opts)
	if vim.api.nvim_win_is_valid(state.win) then
		M.close_editor()
		return
	end
	if not vim.api.nvim_buf_is_valid(state.buf) then
		load_editor()
	end
	state = ui.create_floating_window(state.buf, opts.window)

	local win = state.win
	local buf = state.buf
	vim.wo[win].number = opts.number
	vim.wo[win].relativenumber = opts.relativenumber
	vim.api.nvim_buf_set_name(buf, "cmd-macro editor")

	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = buf,
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(win) then
				M.close_editor()
			end
		end,
		group = utils.cmdmacro_augroup
	})
end

---Closes the editor window.
M.close_editor = function()
	local win = state.win
	local buf = state.buf
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	vim.api.nvim_win_hide(win)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_set_name(buf, "")
	else
		buf = vim.api.nvim_create_buf(false, true)
	end
	state.win = -1
end

---Loads the editor with the data corresponding to the current working directory.
---@return cmdmacro.macro[]
M.load_content = function()
	load_editor()
	return state.macros
end

---Sets the macros/keymaps.
---@param macros cmdmacro.macro[]
M.set_macros = function(macros)
	for _, macro in ipairs(macros) do
		local keymap_opts = {}
		if macro.name then
			keymap_opts = { desc = "cmd-macro " .. macro.name }
		end
		utils.set_keymaps("n", macro.keymap, function()
			M.close_editor()
			term.send_command(macro.command)
		end, keymap_opts)
	end
end

---Deletes previously defined macros that are specific to the current working directory and setting up new ones.
---@param macros cmdmacro.macro[]
M.refresh_macros = function(macros)
	for _, prev_macro in ipairs(config.opts.specific_macros) do
		if type(prev_macro.keymap) == "string" then
			vim.api.nvim_del_keymap("n", prev_macro.keymap)
		else
			for _, n in ipairs(prev_macro.keymap) do
				vim.api.nvim_del_keymap("n", n)
			end
		end
	end
	M.specific_macros = macros
	M.set_macros(macros)
end

return M
