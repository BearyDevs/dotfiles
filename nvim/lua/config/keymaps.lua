-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")
local keymap = vim.keymap
local opts = { noremap = true, silent = true, nowait = true }
local telescope = require("telescope.builtin")
local themes = require("telescope.themes")

local function show_relative_path()
  local relative_path = vim.fn.expand("%")
  print("Relative Path: " .. relative_path)
end

local function show_project_path()
  local project_path = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    project_path = vim.fn.getcwd()
  end
  print("Project Path: " .. project_path)
end

-- ╭─────────────────────────────────────────────────────────╮
-- │ override default                                        │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "<leader>|", "", opts) -- disable Vertical split
keymap.set("n", "<leader>-", "", opts) -- disable Horizontal split
keymap.set("n", ";", ":", { noremap = true, nowait = true })
keymap.set("n", "q", "", opts) -- disable record macro

keymap.set("n", "<leader>$", function()
  return show_relative_path()
end, { desc = "Show Relative Path" })
keymap.set("n", "<leader>%", function()
  return show_project_path()
end, { desc = "Show Relative th" })
keymap.set("n", "Dw", "vb_d", opts) -- delete word backward
keymap.set("n", "<C-a>", "gg<S-v>G", opts) -- select all
keymap.set("n", "mk", "<cmd>m-2<cr>", opts) -- move line up
keymap.set("n", "mj", "<cmd>m+1<cr>", opts) -- move line down
keymap.set("n", "+", "<cmd>vertical resize +3<cr>", opts)
keymap.set("n", "_", "<cmd>vertical resize -3<cr>", opts)
keymap.set("n", ")", "<cmd>horizontal resize +3<cr>", opts)
keymap.set("n", "(", "<cmd>horizontal resize -3<cr>", opts)
keymap.set("n", "x", '"_x', opts)
keymap.set("n", "c", '"_c', opts)
keymap.set("v", "c", '"_c', opts)
keymap.set("n", "X", '"_X', opts)
keymap.set("n", "C", '"_C', opts)
keymap.set("v", "C", '"_C', opts)
keymap.set("i", "jk", "<ESC>", opts) -- Quick exit insert mode
keymap.set("n", "<leader>v", "<cmd>:vsplit<cr>", { desc = "Vertical Split" })
keymap.set("n", "<leader>V", "<cmd>:split<cr>", { desc = "Horizontal Split" })

keymap.set("n", "<leader>h", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
keymap.set("n", "<leader>H", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Snacks                                                  │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "<leader>'", function()
  Snacks.picker.pick("files", {
    hidden = true, -- Include hidden files (dotfiles)
    no_ignore = true, -- Include files ignored by .gitignore
    root = false, -- Use the current working directory
  })
end, { desc = "Find files (including hidden)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Telescope                                               │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "<leader>gF", function()
  telescope.find_files(themes.get_ivy({
    hidden = true, -- Show hidden files (dotfiles)
    no_ignore = true, -- Include files ignored by .gitignore
  }))
end, { desc = "Find files (including hidden) in Telescope" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ GitSign                                                 │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "<leader>G", function()
  require("gitsigns").blame() -- Show blame information
end, { desc = "Gitsigns Blame" })

keymap.set("n", "gb", function()
  require("gitsigns").blame_line({ full = true }) -- Show blame information
end, { desc = "Gitsigns hunk Blame line" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Neo-tree jump to current file                           │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "<leader>o", function()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd.wincmd("p")
  else
    vim.cmd.Neotree("focus")
  end
end, { desc = "Toggle Explorer Focus" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ increment/decrement numbers                             │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "<leader>+", "<M-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<M-x>", { desc = "Decrement number" }) -- decrement

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diagnostics                                             │
-- ╰─────────────────────────────────────────────────────────╯
keymap.set("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostics hover" })

keymap.set("n", "gj", function()
  vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })

keymap.set("n", "gk", function()
  vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

keymap.set("n", "<leader>\\", "<cmd>LazyExtras<CR>", { desc = "LazyExtras" })
keymap.set({ "n", "v" }, "gm", function()
  Util.format({ force = true })
end, { desc = "Format" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Terminal                                                │
-- ╰─────────────────────────────────────────────────────────╯
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Code Fold keymap                                        │
-- ╰─────────────────────────────────────────────────────────╯
-- za - Toggle the current fold
-- zc - Close the current fold
-- zo - Open the current fold
-- zM - Close all folds
-- zR - Open all folds
