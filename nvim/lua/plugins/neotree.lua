return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      -- "<leader>fE",
      "<leader>R",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root(), focus = false })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    {
      -- "<leader>fe",
      "<leader>r",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd(), focus = false })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (Root Dir)", remap = true },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
  },
  opts = {
    filesystem = {
      window = {
        -- width = 35,
        -- position = "float",
        -- position = "right",

        -- position = "bottom",
        -- height = function()
        --   local screen_height = vim.api.nvim_list_uis()[1].height -- Get total screen height
        --   return math.floor(screen_height * 0.55) -- 55% of screen height
        -- end,
      },
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          require("neo-tree.command").execute({ action = "close" })
        end,
      },
    },
  },
}
