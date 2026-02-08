return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup({
        -- views = {
        --   default = "virtual",  -- Set the default view to virtual
        -- },
      })
      vim.api.nvim_set_keymap("n", "<Leader>9", ":BlameToggle<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<Leader>0", ":BlameToggle virtual<CR>", { noremap = true, silent = true }) -- Keymap for virtual mode
    end,
    opts = {
      blame_options = { "-w", width = 15 },
    },
  },
}
