return {
  "LiadOz/nvim-dap-repl-highlights",
  lazy = true,
  specs = {
    {
      "nvim-treesitter/nvim-treesitter",
      dependencies = {
        "LiadOz/nvim-dap-repl-highlights",
        dependencies = { "mfussenegger/nvim-dap" },
        opts = {},
      },
    },
  },
}
