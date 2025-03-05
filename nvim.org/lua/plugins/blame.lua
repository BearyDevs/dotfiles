return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup({})
      vim.api.nvim_set_keymap("n", "<Leader>B", ":BlameToggle<CR>", { noremap = true, silent = true })
    end,
    opts = {
      blame_options = { "-w", width = 15 },
    },
  },
}
