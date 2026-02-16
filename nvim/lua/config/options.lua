-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.iskeyword:append("-")
opt.iskeyword:append("_")
opt.backspace = vim.list_extend(opt.backspace:get(), { "nostop" }) -- don't stop backspace at insert
opt.breakindent = true -- wrap indent to match  line start
opt.clipboard = "unnamedplus" -- connection to the system clipboard
opt.cmdheight = 0 -- hide command line unless needed
opt.confirm = true -- raise a dialog asking if you wish to save the current file(s)
opt.copyindent = true -- copy the previous indentation on autoindenting
opt.cursorline = true -- highlight the text line of the cursor
opt.diffopt = vim.list_extend(opt.diffopt:get(), { "algorithm:histogram", "linematch:60" }) -- enable linematch diff algorithm
opt.ignorecase = true -- case insensitive searching
opt.infercase = true -- infer cases in keyword completion
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- wrap lines at 'breakat'
opt.mouse = "a" -- enable mouse support
opt.number = true -- show numberline
opt.preserveindent = true -- preserve indent structure as much as possible
opt.pumheight = 10 -- height of the pop up menu
opt.relativenumber = false -- show relative numberline
opt.signcolumn = "yes" -- always show the sign column
opt.smartcase = true -- case sensitive searching
opt.termguicolors = true -- enable 24-bit RGB color in the TUI
opt.undofile = true -- enable persistent undo
opt.virtualedit = "block" -- allow going past end of line in visual block mode
opt.wrap = false -- disable wrapping of lines longer than the width of window

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diagnostic Configuration                                │
-- ╰─────────────────────────────────────────────────────────╯
vim.diagnostic.config({
  float = {
    border = "rounded",
    source = "if_many", -- Show source only if multiple sources exist
  },
  virtual_text = {
    prefix = "●",
    source = false, -- Don't show source in virtual text (would be too long)
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ Todo Comment Demo                                       │
-- ╰─────────────────────────────────────────────────────────╯
-- NOTE:
-- PERF:
-- HACK:
-- TODO:
-- WARN:
-- FIX:
-- BUG:
-- FIXIT:
-- ISSUE:
-- WARNING:
-- TEST:
