return {
  "uga-rosa/ccc.nvim",
  event = { "InsertEnter", "BufReadPre" },
  cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
  keys = {
    { "<leader>z", desc = "Color Picker" },
    { "<leader>zc", "<cmd>CccConvert<cr>", desc = "Convert color" },
    { "<leader>zp", "<cmd>CccPick<cr>", desc = "Pick Color" },
  },
  opts = {
    highlighter = {
      auto_enable = true,
      lsp = false,
    },
  },
  config = function(_, opts)
    require("ccc").setup(opts)

    local success, lsp_handler = pcall(require, "ccc.handler.lsp")
    if success and lsp_handler then
      lsp_handler.update = function() end
    end

    if opts.highlighter and opts.highlighter.auto_enable then
      vim.cmd.CccHighlighterEnable()
    end
  end,
}
