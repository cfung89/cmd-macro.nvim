local config = require("cmdmacro.config")
local ui = require("cmdmacro.ui")
local utils = require("cmdmacro.utils")

local M = {}

local state = {
	win = -1,
	buf = -1,
	location = nil
}

---Sets split window configuration.
---@param win integer
---@param opts cmdmacro.split_window_config
local function set_terminal_win(win, opts)
	if opts.wincmd ~= nil then
		vim.cmd.wincmd(opts.wincmd)
	end
	vim.api.nvim_win_set_height(win, opts.height)
	vim.api.nvim_win_set_width(win, opts.width)
end

---Creates split terminal window.
---@param location string
---@param opts cmdmacro.split_window_config
---@return cmdmacro.window_state
local function create_terminal(location, opts)
	-- create window
	vim.cmd.vnew()
	local new_win = vim.api.nvim_get_current_win()

	local buf
	if vim.api.nvim_buf_is_valid(state.buf) then
		-- if valid buf, load the buffer in the new window
		buf = state.buf
	else
		-- else, create buffer
		buf = vim.api.nvim_create_buf(false, true)
	end
	vim.api.nvim_win_set_buf(new_win, buf)

	if vim.bo[buf].buftype ~= "terminal" then
		vim.api.nvim_win_call(new_win, function() vim.cmd.term() end)
	end

	-- set window settings
	set_terminal_win(new_win, opts)

	return { win = new_win, buf = buf, location = location }
end

---Creates a floating terminal window.
---@param location string
---@param opts vim.api.keyset.win_config
---@return cmdmacro.window_state
local function create_floating_terminal(location, opts)
	local new_state = ui.create_floating_window(state.buf, opts)
	new_state.location = location
	if vim.bo[new_state.buf].buftype ~= "terminal" then
		vim.api.nvim_win_call(new_state.win, function() vim.cmd.term() end)
	end
	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = new_state.buf,
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(new_state.win) then
				M.close_terminal()
			end
		end,
		group = utils.cmdmacro_augroup
	})
	return new_state
end

---Handles the terminal window and buffer.
---If the terminal window is open, there are 2 possible oucomes:
---    - If the input location is the same as the open window, the window is closed.
---    - If the input location is not the same as the open window, the window is moved to the new location.
---The buffer keeps its state even if the window is closed.
---@param location string
M.handle_terminal_win = function(location)
	local opts = config.opts.terminals[location]

	-- close previously opened terminal
	if vim.api.nvim_win_is_valid(state.win) then
		local prev_location = state.location
		M.close_terminal()
		if prev_location == location then
			return
		end
	end

	-- create new terminal
	if opts.wincmd ~= nil then
		state = create_terminal(location, opts)
	else
		state = create_floating_terminal(location, opts)
	end
	vim.api.nvim_buf_set_name(state.buf, "cmd-macro terminal")
end

---Close terminal window.
M.close_terminal = function()
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
		vim.cmd.term()
	end
	state.win = -1
	state.location = nil
end

---Send command to terminal buffer and run it.
---If a terminal window is already open, the command will execute in that window. Otherwise, the default terminal window is opened. The cursor does not move from its original position.
---@param cmd string
M.send_command = function(cmd)
	local current_win = vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(state.win) then
		-- if no window open, open default terminal window
		M.handle_terminal_win(config.opts.default_terminal)
	end

	-- send command to terminal
	local term_id = vim.b[state.buf].terminal_job_id
	if term_id == nil then
		return
	end
	vim.fn.chansend(term_id, cmd .. "\n")

	-- set cursor to end of terminal
	local line_count = vim.api.nvim_buf_line_count(state.buf)
	vim.api.nvim_win_set_cursor(state.win, { line_count, 0 })

	if config.opts.terminals[state.location].wincmd ~= nil and vim.api.nvim_get_current_win() ~= current_win then
		-- reset cursor
		vim.api.nvim_set_current_win(current_win)
	end
end

return M
