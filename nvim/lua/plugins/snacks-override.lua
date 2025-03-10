return {
  "folke/snacks.nvim",
  enabled = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    picker = {
      sources = {
        explorer = {
          auto_close = true,
          hidden = true,
        },
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    { "<leader>r", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
    { "<leader>R", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
  },
}
