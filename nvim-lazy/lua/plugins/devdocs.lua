local prefix = "<leader>fd"

return {
  "luckasRanarison/nvim-devdocs",
  cond = not vim.g.vscode,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = {
    "DevdocsFetch",
    "DevdocsInstall",
    "DevdocsUninstall",
    "DevdocsOpen",
    "DevdocsOpenFloat",
    "DevdocsUpdate",
    "DevdocsUpdateAll",
  },
  keys = {
    { prefix .. "", "", desc = "Devdocs", mode = { "n" } },
    { prefix .. "d", "<cmd>DevdocsOpenCurrentFloat<CR>", desc = "Find Devdocs for current file", mode = { "n" } },
    { prefix .. "f", "<cmd>DevdocsFetch<CR>", desc = "Fetch Devdocs", mode = { "n" } },
    { prefix .. "o", "<cmd>DevdocsOpen<CR>", desc = "Open Devdocs", mode = { "n" } },
    { prefix .. "u", "<cmd>DevdocsUpdateAll<CR>", desc = "Update All Devdocs", mode = { "n" } },
  },
  opts = {
    previewer_cmd = vim.fn.executable("glow") == 1 and "glow" or nil,
    cmd_args = { "-s", "dark", "-w", "80" },
    picker_cmd = true,
    picker_cmd_args = { "-p" },
  },
}
