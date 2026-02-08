---@type LazySpec
return {
  "nvim-mini/mini-git",
  main = "mini.git",
  event = "BufReadPre",
  cmd = "Git",
  opts = {},
}
