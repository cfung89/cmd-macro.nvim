local M = {}

--- Default configuration.
M.defaults = {
	commands = {
		toggle_editor = "MacroEditor", -- toggle the editor window
		terminal_close = "TerminalClose", -- close any open window (terminal and editor)
		toggle_terminal = "TerminalCenter", -- toggle the center terminal
		terminal_top = "TerminalTop", -- toggle the top terminal
		terminal_bottom = "TerminalBottom", -- toggle the bottom terminal
		terminal_left = "TerminalLeft", -- toggle the left terminal
		terminal_right = "TerminalRight", -- toggle the right terminal
	},

	-- Keymaps have a corresponding user command defined above.
	keymaps = {
		toggle_editor = "<leader>te",
		terminal_close = "<leader>tc",
		toggle_terminal = "<leader>tt",
		terminal_top = "<leader>tk",
		terminal_bottom = "<leader>tj",
		terminal_left = "<leader>th",
		terminal_right = "<leader>tl",
	},

	-- Default terminal: if a macro is run and no terminal window is open,
	-- opens the default terminal window and runs the command in it
	default_terminal = "Right",

	-- General terminal settings
	terminal_settings = {
		number = false,   -- line numbers in terminal window
		relativenumber = false, -- relative line numbers in terminal window
		-- Keymap to escape from terminal mode to normal mode.
		-- Disable by setting this to `nil`.
		term_to_normal = "<C-[><C-[>"
	},

	-- Window configurations for terminals
	terminals = {
		-- Top, Bottom, Left, and Right are split windows, identified by the presence of the `wincmd` attribute.
		-- The `wincmd`, `height`, and `width` attributes are the only configurable UI attributes for split windows.
		-- The `height` and `width` attributes can be an integer or a function that returns an integer.
		-- Passing in a function allows cmd-macro to resize the Neovim window if the terminal emulator window is resized.
		Top = {
			wincmd = "K",
			height = function() return math.floor(0.15 * vim.o.lines) end,
			width = vim.o.columns
		},
		Bottom = {
			wincmd = "J",
			height = function() return math.floor(0.15 * vim.o.lines) end,
			width = vim.o.columns
		},
		Left = {
			wincmd = "H",
			height = vim.o.lines,
			width = function() return math.floor(0.5 * vim.o.columns) end
		},
		Right = {
			wincmd = "L",
			height = vim.o.lines,
			width = function() return math.floor(0.5 * vim.o.columns) end
		},

		-- Center is a floating window, identified by the lack of the `wincmd` attribute.
		-- The `height`, `width`, `row`, and `col` attributes can be an integer/number or a function that returns an integer/number.
		-- Passing in a function allows cmd-macro to resize the Neovim window if the terminal emulator window is resized.
		-- It has type `vim.api.keyset.win_config`, and with the exception of the `height`, `width`, `row`, and `col` attributes,
		-- the table is passed directly to`vim.api.nvim_open_win({buffer}, {enter}, {config})` as the `config` argument.
		Center = {
			relative = "editor",
			style = "minimal",
			border = "rounded",
			title = " cmd-macro terminal ",
			title_pos = "center",
			height = function() return math.floor(0.8 * vim.o.lines) end,
			width = function() return math.floor(0.8 * vim.o.columns) end,
			row = function() return math.floor(0.2 * vim.o.lines / 2) end,
			col = function() return math.floor(0.2 * vim.o.columns / 2) end,
		},
	},

	-- Window configurations for the macro editor
	editor = {
		number = true,
		relativenumber = true,
		-- The editor window is a floating window and can be configured the same way as the Center window above.
		window = {
			relative = "editor",
			style = "minimal",
			border = "rounded",
			title = " cmd-macro editor ",
			title_pos = "center",
			height = function() return math.floor(0.6 * vim.o.lines) end,
			width = function() return math.floor(0.6 * vim.o.columns) end,
			row = function() return math.floor(0.4 * vim.o.lines / 2) end,
			col = function() return math.floor(0.4 * vim.o.columns / 2) end,
		},
		-- Editor specific keymaps (`quit` is currently the only one)
		keymaps = {
			quit = { "q", "<Esc>" },
		},
	},

	-- Set of general-purpose macros
	macros = {
		-- Macros are of the following form: { name = "", keymap = "", command = "" },
		-- Example: { name = "git_status", keymap = "<leader>gs", command = "git status" },
	}
}

---Sets the opts configuration table.
---@param opts table?
M.set = function(opts)
	opts = opts or {}
	local defaults = M.defaults
	M.opts = vim.tbl_deep_extend("force", defaults, opts)
end

return M
