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
        colorscheme = "solarized-osaka",
        -- colorscheme = "tokyonight",
        -- colorscheme = "tokyonight-storm",
        news = {
          lazyvim = true,
          neovim = true,
        },
      },
    },
    { "HiPhish/rainbow-delimiters.nvim", dependencies = "nvim-treesitter/nvim-treesitter" },

    -- ╭─────────────────────────────────────────────────────────╮
    -- │ Override                                                │
    -- ╰─────────────────────────────────────────────────────────╯
    {
      "folke/noice.nvim",
      opts = function(_, opts)
        table.insert(opts.routes, {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        })
        local focused = true
        vim.api.nvim_create_autocmd("FocusGained", {
          callback = function()
            focused = true
          end,
        })
        vim.api.nvim_create_autocmd("FocusLost", {
          callback = function()
            focused = false
          end,
        })
        table.insert(opts.routes, 1, {
          filter = {
            cond = function()
              return not focused
            end,
          },
          view = "notify_send",
          opts = { stop = false },
        })

        opts.commands = {
          all = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {},
          },
        }

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function(event)
            vim.schedule(function()
              require("noice.text.markdown").keys(event.buf)
            end)
          end,
        })

        opts.presets.lsp_doc_border = true
      end,
    },
    {
      "echasnovski/mini.hipatterns",
      event = "BufReadPre",
      opts = {
        highlighters = {
          hsl_color = {
            pattern = "hsl%(%d+,? %d+%%?,? %d+%%?%)",
            group = function(_, match)
              local utils = require("solarized-osaka.hsl")
              --- @type string, string, string
              local nh, ns, nl = match:match("hsl%((%d+),? (%d+)%%?,? (%d+)%%?%)")
              --- @type number?, number?, number?
              local h, s, l = tonumber(nh), tonumber(ns), tonumber(nl)
              --- @type string
              local hex_color = utils.hslToHex(h, s, l)
              return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
            end,
          },
        },
      },
    },
    -- {
    --   "saghen/blink.cmp",
    --   optional = true,
    --   dependencies = { "codeium.nvim", "saghen/blink.compat" },
    --   opts = {
    --     completion = {
    --       menu = {
    --         winblend = vim.o.pumblend,
    --       },
    --     },
    --     signature = {
    --       window = {
    --         winblend = vim.o.pumblend,
    --       },
    --     },
    --     sources = {
    --       compat = { "codeium" },
    --       providers = {
    --         codeium = {
    --           kind = "Codeium",
    --           score_offset = 100,
    --           async = true,
    --         },
    --       },
    --     },
    --   },
    -- },
    {
      "echasnovski/mini.surround",
      recommended = true,
      keys = function(_, keys)
        -- Populate the keys based on the user's options
        local opts = LazyVim.opts("mini.surround")
        local mappings = {
          { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "v" } },
          { opts.mappings.delete, desc = "Delete Surrounding" },
          { opts.mappings.find, desc = "Find Right Surrounding" },
          { opts.mappings.find_left, desc = "Find Left Surrounding" },
          { opts.mappings.highlight, desc = "Highlight Surrounding" },
          { opts.mappings.replace, desc = "Replace Surrounding" },
          { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
        }
        mappings = vim.tbl_filter(function(m)
          return m[1] and #m[1] > 0
        end, mappings)
        return vim.list_extend(mappings, keys)
      end,
      opts = {
        mappings = {
          add = "gsa", -- Add surrounding in Normal and Visual modes
          delete = "gsd", -- Delete surrounding
          find = "gsf", -- Find surrounding (to the right)
          find_left = "gsF", -- Find surrounding (to the left)
          highlight = "gsh", -- Highlight surrounding
          replace = "gsr", -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      },
    },
    {
      "akinsho/bufferline.nvim",
      event = "VeryLazy",
      keys = {
        { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
        { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
      },
      opts = function()
        local opts = {
          options = {
            show_buffer_close_icons = false,
            show_close_icon = false,
          },
        }

        -- Offset logic for edgy.nvim integration
        local Offset = require("bufferline.offset")
        if not Offset.edgy then
          local get = Offset.get
          Offset.get = function()
            if package.loaded.edgy then
              local old_offset = get()
              local layout = require("edgy.config").layout
              local ret = { left = "", left_size = 0, right = "", right_size = 0 }
              for _, pos in ipairs({ "left", "right" }) do
                local sb = layout[pos]
                local title = " Sidebar" .. string.rep(" ", sb.bounds.width - 8)
                if sb and #sb.wins > 0 then
                  ret[pos] = old_offset[pos .. "_size"] > 0 and old_offset[pos]
                    or pos == "left" and ("%#Bold#" .. title .. "%*" .. "%#BufferLineOffsetSeparator#│%*")
                    or pos == "right" and ("%#BufferLineOffsetSeparator#│%*" .. "%#Bold#" .. title .. "%*")
                  ret[pos .. "_size"] = old_offset[pos .. "_size"] > 0 and old_offset[pos .. "_size"] or sb.bounds.width
                end
              end
              ret.total_size = ret.left_size + ret.right_size
              if ret.total_size > 0 then
                return ret
              end
            end
            return get()
          end
          Offset.edgy = true
        end

        return opts
      end,
    },
    -- disable scroll animation
    {
      "snacks.nvim",
      opts = {
        scroll = { enabled = false },
        dashboard = {
          preset = {
            header = [[
__________                            ________                     
\______   \ ____ _____ _______ ___.__.\_____  \   _______  ________
 |    |  _// __ \__   \_  __  <   |  | |    |  \_/ __ \  \/ /  ___/
 |    |   \  ___/ / __ \|  | \/\___  | |    `   \  ___/\   /\___ \ 
 |______  /\___  >____  /__|   / ____|/_______  /\___  >\_//____  >
        \/     \/     \/       \/             \/     \/         \/ 
   ]],
          },
        },
      },
    },

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
    enabled = false, -- check for plugin updates periodically
    notify = true, -- notify on update
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
