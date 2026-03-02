local config = require("cmdmacro.config")
local editor = require("cmdmacro.editor")
local term = require("cmdmacro.term")
local utils = require("cmdmacro.utils")

local M = {}

---Applies configuraiton from config.opts.
---Loads the user commands and keymaps, along with user-defined macros.
local function apply_config()
	local opts = config.opts

	-- set terminal user commands
	for location, _ in pairs(opts.terminals) do
		vim.api.nvim_create_user_command("Terminal" .. location, function()
			editor.close_editor()
			term.handle_terminal_win(location)
		end, {})
	end
	vim.api.nvim_create_user_command("TerminalClose", function()
		editor.close_editor()
		term.close_terminal()
	end, {})
	vim.api.nvim_create_user_command("MacroEditor", function() editor.open_editor(config.opts.editor) end, {})

	-- set terminal keymaps
	for action, keybind in pairs(opts.keymaps) do
		utils.set_keymaps("n", keybind, string.format("<cmd>%s<CR>", opts.commands[action]))
	end

	-- set command macros
	editor.set_macros(opts.macros)
	editor.set_macros(opts.specific_macros)

	-- general terminal settings
	vim.api.nvim_create_autocmd("TermOpen", {
		callback = function()
			vim.opt.number = opts.terminal_settings.number
			vim.opt.relativenumber = opts.terminal_settings.relativenumber
		end,
		group = utils.cmdmacro_augroup
	})
	local term_to_normal = opts.terminal_settings.term_to_normal
	if term_to_normal ~= nil then
		utils.set_keymaps("t", opts.terminal_settings.term_to_normal, "<c-\\><c-n>")
	end
end

---cmd-macro setup function.
---@param opts table?
M.setup = function(opts)
	opts = opts or {}
	local macros = editor.load_content()
	opts.specific_macros = macros
	config.set(opts)
	apply_config()
end

return M
