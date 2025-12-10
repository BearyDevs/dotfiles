return {
  "nvim-mini/mini.splitjoin",
  version = "*",
  opts = {
    mappings = {
      toggle = "gS",
      split = "",
      join = "",
    },
    detect = {
      brackets = nil,
      separator = ",",
      exclude_regions = nil,
    },
    split = {
      hooks_pre = {},
      hooks_post = {},
    },
    join = {
      hooks_pre = {},
      hooks_post = {},
    },
  },
}
