return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      enabled = true,
      chunk = {
        enabled = true,
        char = {
          corner_top = "╭",
          corner_bottom = "╰",
          horizontal = "─",
          vertical = "│",
          arrow = ">",
        },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#E06C75" })  -- Custom red
    -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#E06C75" })  -- Custom red for scope
    -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#E5C07B" })  -- Custom yellow
    -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#E5C07B" })  -- Custom yellow for scope

    -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#FFB3D9" })  -- Light pink
    -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#FFB3D9" })  -- Light pink for scope
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#47ff9c" })
    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#47ff9c" })
  end,
}
