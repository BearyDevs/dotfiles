return {
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim",
    },
    opts = {},
    config = function()
      vim.o.winwidth = 5
      vim.o.winminwidth = 5
      vim.o.equalalways = false
      require("windows").setup()
    end,
  },
}
