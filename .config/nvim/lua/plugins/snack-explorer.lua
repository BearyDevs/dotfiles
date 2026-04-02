return {
  "folke/snacks.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", false }, -- disable LazyVim default <leader>e for Snacks Explorer
    {
      "<leader>r",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer (Snacks)",
    },
    -- {
    --   "<leader>o",
    --   function()
    --     -- Toggle cursor between Buffer and Snacks Explorer
    --     local snacks_win = nil
    --     for _, win in ipairs(vim.api.nvim_list_wins()) do
    --       local buf = vim.api.nvim_win_get_buf(win)
    --       local ft = vim.bo[buf].filetype
    --       if ft == "snacks_picker_list" or ft == "snacks_explorer" then
    --         snacks_win = win
    --         break
    --       end
    --     end
    --     if snacks_win then
    --       local current_win = vim.api.nvim_get_current_win()
    --       if current_win == snacks_win then
    --         vim.cmd("wincmd p")
    --       else
    --         vim.api.nvim_set_current_win(snacks_win)
    --       end
    --     else
    --       Snacks.explorer()
    --     end
    --   end,
    --   desc = "Toggle Cursor between Buffer and Snacks Explorer",
    -- },
  },
  opts = {
    scroll = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        --     header = [[
        -- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        -- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
        -- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
        -- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        -- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        -- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
        --   ]],

        header = [[
 __________         __         .__        __   _________            .___             
 \______   \_____ _/  |________|__| ____ |  | _\_   ___ \  ____   __| _/____ ________
  |     ___/\__  \\   __\_  __ \  |/ ___\|  |/ /    \  \/ /  _ \ / __ |/ __ \\___   /
  |    |     / __ \|  |  |  | \/  \  \___|    <\     \___(  <_> ) /_/ \  ___/ /    / 
  |____|    (____  /__|  |__|  |__|\___  >__|_ \\______  /\____/\____ |\___  >_____ \
                 \/                    \/     \/       \/            \/    \/      \/

    .__________________________.
    | .___________________. |==|
    | | ................. | |  |
    | | ::::Apple ][::::: | |  |
    | | ::::::::::::::::: | |  |
    | | ::::::::::::::::: | |  |
    | | ::::::::::::::::: | |  |
    | | ::::::::::::::::: | |  |
    | | ::::::::::::::::: | | ,|
    | !___________________! |(c|
    !_______________________!__!
   /                            \
  /  [][][][][][][][][][][][][]  \
 /  [][][][][][][][][][][][][][]  \
(  [][][][][____________][][][][]  )
 \ ------------------------------ /
  \______________________________/
        ]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },

          {
            icon = " ", -- You can change this to any Nerd Font icon you like
            key = "G",
            desc = "Toggle Diffview",
            action = function()
              -- Simulates pressing <leader>gC to trigger your existing keymap
              local keys = vim.api.nvim_replace_termcodes("<leader>gC", true, false, true)
              vim.api.nvim_feedkeys(keys, "m", false)
            end,
          },

          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    picker = {
      hidden = true,
      ignored = true,
      win = {
        input = {
          keys = {
            ["h"] = { "toggle_hidden", mode = { "n" } },
            ["H"] = { "toggle_ignored", mode = { "n" } },
          },
        },
      },
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          auto_close = true,
          hidden = true,
          layout = {
            layout = {
              -- position = "right",
              position = "left",
            },
          },
        },
      },
    },
    -- indent = {
    --   enabled = true,
    --   chunk = {
    --     enabled = true,
    --     char = {
    --       corner_top = "╭",
    --       corner_bottom = "╰",
    --       horizontal = "─",
    --       vertical = "│",
    --       arrow = ">",
    --     },
    --   },
    -- },
  },
  -- config = function(_, opts)
  --   require("snacks").setup(opts)
  --   -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#E06C75" })  -- Custom redg
  --   -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#E06C75" })  -- Custom red for scope
  --   -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#E5C07B" })  -- Custom yellow
  --   -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#E5C07B" })  -- Custom yellow for scope
  --
  --   -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#FFB3D9" })  -- Light pink
  --   -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#FFB3D9" })  -- Light pink for scope
  --   vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#47ff9c" })
  --   vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#47ff9c" })
  -- end,
}
