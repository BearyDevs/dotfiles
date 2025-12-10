local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        -- colorscheme = "solarized-osaka",
        -- colorscheme = "tokyonight", -- default colorscheme
        colorscheme = "tokyonight-storm",
        news = {
          lazyvim = true,
          neovim = true,
        },
      },
    },

    -- ╭─────────────────────────────────────────────────────────╮
    -- │ Override defaults config                                │
    -- ╰─────────────────────────────────────────────────────────╯
    {
      "folke/tokyonight.nvim",
      lazy = true,
      opts = {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      },
    },
    {
      "akinsho/bufferline.nvim",
      keys = {
        { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
        { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
      },
      opts = {
        options = {
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      },
    },
    {
      "folke/snacks.nvim",
      opts = {
        scroll = { enabled = false },
        dashboard = {
          enabled = false,
          preset = {
            header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
          },
        },
        picker = {
          hidden = true,
          ignored = true,
          sources = {
            -- explorer = false

            explorer = {
              auto_close = true,
              hidden = true,

              -- ╭─────────────────────────────────────────────────────────╮
              -- │ Normal Layout                                           │
              -- ╰─────────────────────────────────────────────────────────╯
              layout = {
                layout = {
                  -- position = "right",
                  position = "left",
                },
              },

              -- ╭─────────────────────────────────────────────────────────╮
              -- │ Floating                                                │
              -- ╰─────────────────────────────────────────────────────────╯
              -- layout = {
              --   { preview = true },
              --   layout = {
              --     box = "horizontal",
              --     width = 0.8,
              --     height = 0.95,
              --     {
              --       box = "vertical",
              --       border = "rounded",
              --       title = "{source} {live} {flags}",
              --       title_pos = "center",
              --       { win = "input", height = 1, border = "bottom" },
              --       { win = "list", border = "none" },
              --     },
              --     { win = "preview", border = "rounded", width = 0.7, title = "{preview}" },
              --   },
              -- },
            },
          },
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = function(_, opts)
        local LazyVim = require("lazyvim.util")

        -- Set lualine theme to 'solarized-osaka'
        opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
          -- theme = "solarized-osaka",
          -- theme = "tokyonight",
          theme = "tokyonight-storm",
        })

        opts.sections.lualine_c[4] = {
          LazyVim.lualine.pretty_path({
            length = 0,
            relative = "cwd",
            modified_hl = "MatchParen",
            directory_hl = "",
            filename_hl = "Bold",
            modified_sign = "",
            readonly_icon = " 󰌾 ",
          }),
        }
      end,
      config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        local colors = {
          blue = "#65D1FF",
          green = "#3EFFDC",
          violet = "#FF61EF",
          yellow = "#FFDA7B",
          red = "#FF4A4A",
          fg = "#c3ccdc",
          bg = "#112638",
          inactive_bg = "#2c3043",
        }

        local my_lualine_theme = {
          normal = {
            a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          insert = {
            a = { bg = colors.green, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          visual = {
            a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          command = {
            a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          replace = {
            a = { bg = colors.red, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          inactive = {
            a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
            b = { bg = colors.inactive_bg, fg = colors.semilightgray },
            c = { bg = colors.inactive_bg, fg = colors.semilightgray },
          },
        }

        -- configure lualine with modified theme
        lualine.setup({
          options = {
            theme = my_lualine_theme,
          },
          sections = {
            lualine_x = {
              {
                lazy_status.updates,
                cond = lazy_status.has_updates,
                color = { fg = "#ff9e64" },
              },
              { "encoding" },
              { "fileformat" },
              { "filetype" },
            },
          },
        })
      end,
    },
    -- {
    --   "nvim-neo-tree/neo-tree.nvim",
    --   opts = {
    --     filesystem = {
    --       window = {
    --         -- width = 35,
    --         -- position = "right",
    --       },
    --     },
    --     event_handlers = {
    --       {
    --         event = "file_opened",
    --         handler = function()
    --           require("neo-tree.command").execute({ action = "close" })
    --         end,
    --       },
    --     },
    --     close_if_last_window = true,
    --   },
    -- },

    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
