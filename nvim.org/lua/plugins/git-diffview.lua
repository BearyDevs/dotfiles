return {
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggle" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.b[bufnr].view_activated = false
        end,
      },
    },
    keys = {
      -- override of leader gd git diff view hunks
      { "<leader>gd", function()
          local lib = require("diffview.lib")
          if lib.get_current_view() then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Toggle Diffview",
      },
      -- { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
      -- { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
    },
  },
  {
    "neogitorg/neogit",
    optional = true,
    opts = { integrations = { diffview = true } },
  },
}
