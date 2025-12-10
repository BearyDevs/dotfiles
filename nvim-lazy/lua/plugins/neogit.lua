return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
  },
  opts = {
    integrations = {
      telescope = true,
      diffview = true,
    },
    graph_style = "unicode",
  },
}
