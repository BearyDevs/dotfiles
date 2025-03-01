return {
  {
    "uga-rosa/ccc.nvim",
    event = { "InsertEnter", "BufReadPre" },
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    keys = {
      -- { "<leader>uu", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle colorizer" },
      { "<leader>z", desc = "Color Picker" },
      { "<leader>zc", "<cmd>CccConvert<cr>", desc = "Convert color" },
      { "<leader>zp", "<cmd>CccPick<cr>", desc = "Pick Color" },
    },
    opts = {
      highlighter = {
        auto_enable = false,
        lsp = false,
      },
    },
  },
}
