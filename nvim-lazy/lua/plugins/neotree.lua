return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    -- {
    --   "<leader>fE",
    --   function()
    --     require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root(), focus = false })
    --   end,
    --   desc = "Explorer NeoTree (Root Dir)",
    -- },
    -- {
    --   "<leader>fe",
    --   function()
    --     require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd(), focus = false })
    --   end,
    --   desc = "Explorer NeoTree (cwd)",
    -- },
    -- { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (Root Dir)", remap = true },
    -- { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
    -- { "<leader>r", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
    {
      "<leader>r",
      -- "<leader>e",
      function()
        local neo_tree_win = nil

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if string.match(buf_name, "neo%-tree") then
            neo_tree_win = win
            break
          end
        end

        if neo_tree_win then
          local current_win = vim.api.nvim_get_current_win()
          if current_win == neo_tree_win then
            require("neo-tree.command").execute({ action = "close" })
          else
            vim.api.nvim_set_current_win(neo_tree_win)
            require("neo-tree.command").execute({
              action = "focus",
              reveal_file = vim.fn.expand("%:p"),
              reveal_force_cwd = true,
            })
          end
        else
          require("neo-tree.command").execute({
            action = "focus",
            source = "filesystem",
            -- position = "right",
            position = "left",
            reveal_file = vim.fn.expand("%:p"),
            reveal_force_cwd = true,
          })
        end
      end,
      desc = "Toggle Neo-Tree with Focus",
      remap = true,
    },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- Show hidden files by default
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        width = 40,
        -- position = "float",
        -- position = "right",
        position = "left",

        -- position = "bottom",
        -- height = function()
        --   local screen_height = vim.api.nvim_list_uis()[1].height -- Get total screen height
        --   return math.floor(screen_height * 0.55) -- 55% of screen height
        -- end,
        mappings = {
          ["O"] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()

            -- If it's a file, get the directory containing it
            if node.type == "file" then
              path = vim.fn.fnamemodify(path, ":h")
            end

            -- Open Finder with the path
            vim.fn.system("open '" .. path .. "'")
          end,
        },
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
