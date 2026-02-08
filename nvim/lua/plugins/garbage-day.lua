-- ╭─────────────────────────────────────────────────────────╮
-- │ Garbage collector that stops inactive LSP clients to    │
-- │ free RAM                                                │
-- ╰─────────────────────────────────────────────────────────╯
return {
  "zeioth/garbage-day.nvim",
  enabled = false,
  dependencies = "neovim/nvim-lspconfig",
  event = "VeryLazy",
  opts = {},
}
