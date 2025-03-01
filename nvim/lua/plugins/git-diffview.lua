return {
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    cmd = { "DiffviewOpen" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.b[bufnr].view_activated = false
        end,
      },
    },
    keys = {
      { "<leader>gD", desc = "Diffview" },
      { "<leader>gDo", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
      { "<leader>gDc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    },
  },
  {
    "NeogitOrg/neogit",
    optional = true,
    opts = { integrations = { diffview = true } },
  },
}
