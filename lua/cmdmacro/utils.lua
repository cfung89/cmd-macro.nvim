local M = {}

---@class cmdmacro.window_state
---@field buf integer
---@field win integer
---@field location string?

---@class cmdmacro.split_window_config
---@field wincmd string
---@field height integer
---@field width integer

---@class cmdmacro.editor_config
---@field number boolean
---@field relativenumber boolean
---@field window vim.api.keyset.win_config

---@class cmdmacro.macro
---@field name string?
---@field keymap string|string[]
---@field command string

M.cmdmacro_augroup = vim.api.nvim_create_augroup("cmd-macro", { clear = true })

---Sets the keymap(s).
---@param mode string|string[]
---@param keybind string|string[]
---@param action string|function
---@param opts table?
M.set_keymaps = function(mode, keybind, action, opts)
	if keybind == nil then
		return
	end
	if type(keybind) == "string" then
		vim.keymap.set(mode, keybind, action, opts)
		return
	end
	for _, n in ipairs(keybind) do
		vim.keymap.set(mode, n, action, opts)
	end
end

---@param path string
---@return boolean
M.file_exists = function(path)
	local f = io.open(path, "r")
	if f then f:close() end
	return f ~= nil
end

---@param path string
---@return boolean, any
M.load_json_file = function(path)
	local f = io.open(path, "r")
	if not f then return false, {} end
	local data = f:read("*a")
	f:close()
	return true, vim.fn.json_decode(data)
end

---@param path string
---@param data table
---@return boolean
M.write_json_file = function(path, data)
	local f = io.open(path, "w")
	if not f then return false end
	f:write(vim.fn.json_encode(data))
	f:close()
	return true
end

return M
