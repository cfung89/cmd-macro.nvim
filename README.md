# cmd-macro.nvim

`cmd-macro.nvim` is a Neovim plugin that manages terminal windows within Neovim, and can be used to set up keymaps to quickly run shell commands.

## Features

- Smart terminal window toggle.
- Fully customizable window UI.
- General-purpose macros: Keymaps that can be used from any directory.
- Project-specific macros: Keymaps that can only be used from a specific directory.
- Simple macro editor: Window editor to configure project macros, with hot reloaded project macros.
- Automated persistence: Saves and restores project macros.

## Installation

#### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cfung89/cmd-macro.nvim",
  config = function()
    require("cmdmacro").setup()  -- For default options
  end
}
```

## Usage

### Terminal Management

If the terminal window is open, there are 2 possible outcomes if the user attempts to open another terminal window:
- If the input location is the same as the open window, the window is closed.
- If the input location is not the same as the open window, the window is moved to the new location.
Thus, only 1 terminal managed by `cmd-macro` can be open at a time. The buffer keeps its state even if the window is closed.

### Macro Editor

A window can be opened to set up the macros for a specific project. In the editor, macros can be added by specifying an optional name attribute, the keymap, and the shell command. Keymaps can be strings or arrays. Different macros are separated by 3 or more hyphens (`-`).

Example:
```
name = "hello"
keymap = "<leader>th"
command = "echo hello"
---
keymap = [ "<leader>tc", "<leader>tb" ]
command = "cargo build"
```
Double-quotes must be used for strings.

### Using Macros

Keybinds for macros send command to the terminal buffer and run it. If a terminal window is already open, the command will execute in that window. Otherwise, the default terminal window is opened. The cursor remains in its original position.

`cmd-macro` manges two different types of macros:
- *General-purpose macros* can be used from any directory. These are configured in your Neovim configuration.
- *Project-specific macros* can only be used from a specific directory. These are configured in the macro editor.

## Configuration

The following is the provided default configuration:

``` lua
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
```

## References

- [TJ Devries' Advent of Neovim](https://www.youtube.com/playlist?list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM)
- [ThePrimeagen's Harpoon](https://github.com/ThePrimeagen/harpoon)
