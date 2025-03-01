return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>fo", LazyVim.pick("oldfiles"), desc = "Recent" },
    {
      "<leader>fO",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent (cwd)",
    },
  },
}
