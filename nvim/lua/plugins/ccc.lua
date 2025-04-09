return {
  "uga-rosa/ccc.nvim",
  event = { "InsertEnter", "BufReadPre" },
  cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
  keys = {
    -- { "<leader>uC", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle colorizer" },
    { "<leader>z", desc = "Color Picker" },
    { "<leader>zc", "<cmd>CccConvert<cr>", desc = "Convert color" },
    { "<leader>zp", "<cmd>CccPick<cr>", desc = "Pick Color" },
  },
  opts = {
    highlighter = {
      auto_enable = true,
      -- Disable LSP integration to fix the error you're encountering
      lsp = false,
    },
  },
  config = function(_, opts)
    require("ccc").setup(opts)

    -- Override the LSP update function to prevent errors
    local success, lsp_handler = pcall(require, "ccc.handler.lsp")
    if success and lsp_handler then
      lsp_handler.update = function() end
    end

    -- Enable the highlighter only if auto_enable is true
    if opts.highlighter and opts.highlighter.auto_enable then
      vim.cmd.CccHighlighterEnable()
    end
  end,
}
