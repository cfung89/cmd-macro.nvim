local M = {}

---Returns default configuration.
---@return table
M.get_defaults = function()
	local total_cols = vim.o.columns
	local total_lines = vim.o.lines

	local center_h = math.floor(total_lines * 0.8)
	local center_w = math.floor(total_cols * 0.8)
	local center_col = math.floor((vim.o.columns - center_w) / 2)
	local center_row = math.floor((vim.o.lines - center_h) / 2)

	local editor_h = math.floor(total_lines * 0.6)
	local editor_w = math.floor(total_cols * 0.6)
	local editor_col = math.floor((vim.o.columns - editor_w) / 2)
	local editor_row = math.floor((vim.o.lines - editor_h) / 2)

	return {
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
			number = false, -- line numbers in terminal window
			relativenumber = false, -- relative line numbers in terminal window
			-- Keymap to escape from terminal mode to normal mode.
			-- Disable by setting this to `nil`.
			term_to_normal = "<C-[><C-[>"
		},

		-- Window configurations for terminals and editor
		terminals = {
			Top = {
				wincmd = "K",
				height = 8,
				width = total_cols
			},
			Bottom = {
				wincmd = "J",
				height = 8,
				width = total_cols
			},
			Left = {
				wincmd = "H",
				height = total_lines,
				width = math.floor(vim.o.columns * 0.5)
			},
			Right = {
				wincmd = "L",
				height = total_lines,
				width = math.floor(vim.o.columns * 0.5)
			},
			Center = {
				relative = "editor",
				style = "minimal",
				border = "rounded",
				title = " cmd-macro terminal ",
				title_pos = "center",
				width = center_w,
				height = center_h,
				col = center_col,
				row = center_row,
			},
		},
		editor = {
			number = true,
			relativenumber = true,
			window = {
				relative = "editor",
				style = "minimal",
				border = "rounded",
				title = " cmd-macro editor ",
				title_pos = "center",
				width = editor_w,
				height = editor_h,
				col = editor_col,
				row = editor_row,
			},
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
end

---Sets the opts configuration table.
---@param opts table?
M.set = function(opts)
	opts = opts or {}
	local defaults = M.get_defaults()
	M.opts = vim.tbl_deep_extend("force", defaults, opts)
end

return M
