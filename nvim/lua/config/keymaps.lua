-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local key = vim.keymap
local opts = { noremap = true, silent = true, nowait = true }

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
key.set("n", "<leader>|", "", opts) -- disable Vertical split
key.set("n", "<leader>-", "", opts) -- disable Horizontal split
key.set("n", ";", ":", { noremap = true, nowait = true })
key.set("n", "q", "", opts) -- disable record macro

key.set("n", "<leader>$", function()
  return show_relative_path()
end, { desc = "Show Relative Path" })
key.set("n", "<leader>%", function()
  return show_project_path()
end, { desc = "Show Relative th" })
key.set("n", "Dw", "vb_d", opts) -- delete word backward
key.set("n", "<C-a>", "gg<S-v>G", opts) -- select all
key.set("n", "mk", "<cmd>m-2<cr>", opts) -- move line up
key.set("n", "mj", "<cmd>m+1<cr>", opts) -- move line down
key.set("n", "+", "<cmd>vertical resize +3<cr>", opts)
key.set("n", "_", "<cmd>vertical resize -3<cr>", opts)
key.set("n", ")", "<cmd>horizontal resize +3<cr>", opts)
key.set("n", "(", "<cmd>horizontal resize -3<cr>", opts)
key.set("n", "x", '"_x', opts)
key.set("n", "c", '"_c', opts)
key.set("v", "c", '"_c', opts)
key.set("n", "X", '"_X', opts)
key.set("n", "C", '"_C', opts)
key.set("v", "C", '"_C', opts)
key.set("i", "jk", "<ESC>", opts) -- Quick exit insert mode
key.set("n", "<leader>v", "<cmd>:vsplit<cr>", { desc = "Vertical Split" })
key.set("n", "<leader>V", "<cmd>:split<cr>", { desc = "Horizontal Split" })

key.set("n", "<leader>qh", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
key.set("n", "<leader>qH", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Snacks                                                  │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>'", function()
  Snacks.picker.pick("files", {
    hidden = true, -- Include hidden files (dotfiles)
    no_ignore = true, -- Include files ignored by .gitignore
    root = false, -- Use the current working directory
  })
end, { desc = "Find files (including hidden)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Avante                                                  │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>a", "", { desc = "Avante" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Recent                                                  │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>fo", LazyVim.pick("oldfiles"), { desc = "Recent Files" })
key.set("n", "<leader>fO", function()
  Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "Recent Files (cwd)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ increment/decrement numbers                             │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>+", "<M-a>", { desc = "Increment number" }) -- increment
key.set("n", "<leader>-", "<M-x>", { desc = "Decrement number" }) -- decrement

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diagnostics                                             │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostics hover" })

key.set("n", "gj", function()
  vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })

key.set("n", "gk", function()
  vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

key.set("n", "<leader>\\", "<cmd>LazyExtras<CR>", { desc = "LazyExtras" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ LspLens (link JetBrain that show implementatino and     │
-- │ reference)                                              │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>cL", "<cmd>LspLensToggle<CR>", { desc = "LspLensToggle" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Terminal                                                │
-- ╰─────────────────────────────────────────────────────────╯
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

key.set("n", "<leader>fL", function()
  Snacks.terminal(nil, { win = { position = "left" } })
end, { desc = "Terminal left" })

key.set("n", "<leader>fR", function()
  Snacks.terminal(nil, { win = { position = "right" } })
end, { desc = "Terminal right" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Formatting                                              │
-- ╰─────────────────────────────────────────────────────────╯
key.set({ "n", "v" }, "gm", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Neotree                                                 │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>e", function()
  require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd(), reveal = true })
end, { desc = "Explorer NeoTree (cwd)" })
key.set("n", "<leader>E", function()
  require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root(), reveal = true })
end, { desc = "Explorer NeoTree (Root Dir)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diffview                                                │
-- ╰─────────────────────────────────────────────────────────╯
key.set("n", "<leader>gO", "<cmd>DiffviewOpen<cr>", { noremap = true, silent = true })
key.set("n", "<leader>gC", "<cmd>DiffviewClose<cr>", { noremap = true, silent = true })
key.set("n", "<leader>gF", "<cmd>DiffviewFocusFiles<cr>", { noremap = true, silent = true })
key.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { noremap = true, silent = true })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Code Fold keymap                                        │
-- ╰─────────────────────────────────────────────────────────╯
-- za - Toggle the current fold
-- zc - Close the current fold
-- zo - Open the current fold
-- zM - Close all folds
-- zR - Open all folds
