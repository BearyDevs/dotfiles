return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = function(_, opts)
    -- Other blankline configuration here
    return require("indent-rainbowline").make_opts(opts, {
      color_transparency = 0.20, -- default is 0.15 for normal background
      colors = { 0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0xff00ff, 0x00ffff, 0xffa500, 0x800080, 0x008080, 0x800000 },
    })
  end,
  dependencies = {
    "TheGLander/indent-rainbowline.nvim",
  },
}
