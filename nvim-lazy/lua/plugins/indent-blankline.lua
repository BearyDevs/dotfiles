return {
  "lukas-reineke/indent-blankline.nvim",
  event = "LazyFile",
  opts = function()
    Snacks.toggle({
      name = "Indention Guides",
      get = function()
        return require("ibl.config").get_config(0).enabled
      end,
      set = function(state)
        require("ibl").setup_buffer(0, { enabled = state })
      end,
    }):map("<leader>ug")

    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowPink",
      "RainbowGold",
    }

    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#FF6B6B" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowPink", { fg = "#FF69B4" })
      vim.api.nvim_set_hl(0, "RainbowGold", { fg = "#FFD700" })
      -- vim.api.nvim_set_hl(0, "IblScope", { fg = "#47ff9c" })
    end)

    return {
      indent = {
        char = "│",
        tab_char = "│",
        highlight = highlight, -- Add the rainbow highlights here
      },
      scope = { show_start = true, show_end = true },
      exclude = {
        filetypes = {
          "Trouble",
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
      },
    }
  end,
  main = "ibl",
}
