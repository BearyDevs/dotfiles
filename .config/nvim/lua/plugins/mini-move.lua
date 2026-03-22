return {
  "nvim-mini/mini.move",
  config = function(_, opts)
    require("mini.move").setup(opts)
  end,
  keys = {
    { "<C-l>", mode = { "v" } },
    { "<C-k>", mode = { "v" } },
    { "<C-j>", mode = { "v" } },
    { "<C-h>", mode = { "v" } },
  },
  opts = {
    mappings = {
      left = "<C-h>",
      right = "<C-l>",
      down = "<C-j>",
      up = "<C-k>",
    },
  },
}
