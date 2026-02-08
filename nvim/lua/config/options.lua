-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

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
