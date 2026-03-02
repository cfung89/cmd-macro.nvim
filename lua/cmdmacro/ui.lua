local M = {}

---Creates a floating window.
---@param buf integer
---@param opts vim.api.keyset.win_config
---@return cmdmacro.window_state
M.create_floating_window = function(buf, opts)
	-- Buffer creation
	if not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true)
	end

	-- Window configuration with configuration
	local win = vim.api.nvim_open_win(buf, true, opts)

	return { buf = buf, win = win }
end

return M
