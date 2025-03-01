return {
  "stevearc/conform.nvim",
  optional = true,
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    -- Add Go formatters
    opts.formatters_by_ft.go = { "goimports", "gofumpt" }

    -- Preserve existing Prettier configuration for Svelte
    if LazyVim.has_extra("formatting.prettier") then
      opts.formatters_by_ft.svelte = { "prettier" }
    end
  end,
}
