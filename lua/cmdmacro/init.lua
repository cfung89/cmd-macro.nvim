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

	-- set editor keymaps
	utils.set_keymaps("n", config.opts.editor.keymaps.quit, editor.close_editor, { buffer = editor.get_buffer() })
	if config.opts.editor.keymaps.template then
		utils.set_keymaps("i", "-", editor.template, { buffer = editor.get_buffer() })
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
	local term_keymaps = opts.terminal_settings.keymaps
	if term_keymaps ~= nil then
		utils.set_keymaps("t", term_keymaps.term_to_normal, "<c-\\><c-n>", { buffer = term.get_buffer() })
		utils.set_keymaps("n", term_keymaps.quit, function()
				vim.schedule(function()
					if term.get_window() and vim.api.nvim_win_is_valid(term.get_window()) and term.get_buffer() == vim.api.nvim_get_current_buf() then
						term.close_terminal();
					end
				end)
			end,
			{ expr = true, buffer = term.get_buffer() })
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
