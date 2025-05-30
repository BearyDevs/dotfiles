return {
  "altermo/ultimate-autopair.nvim",
  event = "InsertEnter",
  branch = "v0.6", --recommended as each new version will have breaking changes
  opts = {
    -- disable autopair in the command line: https://github.com/altermo/ultimate-autopair.nvim/issues/8
    cmap = false,
    extensions = {
      cond = {
        -- disable in comments
        -- https://github.com/altermo/ultimate-autopair.nvim/blob/6fd0d6aa976a97dd6f1bed4d46be1b437613a52f/Q%26A.md?plain=1#L26
        cond = {
          function(fn) return not fn.in_node "comment" end,
        },
      },
      -- get fly mode working on strings:
      -- https://github.com/altermo/ultimate-autopair.nvim/issues/33
      fly = {
        nofilter = true,
      },
    },
    config_internal_pairs = {
      { '"', '"', fly = true },
      { "'", "'", fly = true },
    },
  },
}
