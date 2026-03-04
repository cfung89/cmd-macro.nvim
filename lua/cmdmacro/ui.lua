local M = {}

---Creates a floating window.
---@param buf integer
---@param opts cmdmacro.floating_window_config
---@return cmdmacro.window_state
M.create_floating_window = function(buf, opts)
	-- Buffer creation
	if not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true)
	end

	-- Load configuration
	local loaded_opts = M.calculate_floating_win_config(opts)

	-- Window configuration
	local win = vim.api.nvim_open_win(buf, true, loaded_opts)

	return { buf = buf, win = win }
end

---Convert `cmdmacro.floating_window_config` to `vim.api.keyset.win_config`
---by running the functions associated with the `row`, `col`, `width`, and `height` attributes
---(if they are functions).
---@param opts cmdmacro.floating_window_config
---@return vim.api.keyset.win_config
M.calculate_floating_win_config = function(opts)
	local loaded_opts = {}
	for k, v in pairs(opts) do
		local loaded_v = v
		if k == "row" or k == "col" or k == "width" or k == "height" and type(v) == "function" then
			loaded_v = v()
			assert(type(loaded_v) == "number")
		end
		loaded_opts[k] = loaded_v
	end
	return loaded_opts
end

return M
