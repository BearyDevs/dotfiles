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
    {
      "snacks.nvim",
      opts = {
        scroll = { enabled = false },
        dashboard = {
          preset = {
            header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
   ]],
            --             header = [[
            -- __________                            ________
            -- \______   \ ____ _____ _______ ___.__.\_____  \   _______  ________
            --  |    |  _// __ \__   \_  __  <   |  | |    |  \_/ __ \  \/ /  ___/
            --  |    |   \  ___/ / __ \|  | \/\___  | |    `   \  ___/\   /\___ \
            --  |______  /\___  >____  /__|   / ____|/_______  /\___  >\_//____  >
            --         \/     \/     \/       \/             \/     \/         \/
            --    ]],
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
          theme = "tokyonight",
        })

        -- codeium
        table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("codeium"))

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
    {
      "williamboman/mason.nvim",
      lazy = true,
      cmd = "Mason",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        ensure_installed = {
          "flake8",
          "pyright",
          "bash-debug-adapter",
          "ast-grep",
          "autopep8",
          "beautysh",
          "biome",
          "chrome-debug-adapter",
          "clang-format",
          "clangd",
          "codelldb",
          "cortex-debug",
          "cpplint",
          "cpptools",
          "csharp-language-server",
          "csharpier",
          "css-lsp",
          "css-variables-language-server",
          "cssmodules-language-server",
          "debugpy",
          "docker-compose-language-service",
          "dockerfile-language-server",
          "emmet-language-server",
          "emmet-ls",
          "erb-lint",
          "eslint-lsp",
          "eslint_d",
          "firefox-debug-adapter",
          "fixjson",
          "glow",
          "go-debug-adapter",
          "graphql-language-service-cli",
          "hadolint",
          "html-lsp",
          "htmlbeautifier",
          "htmlhint",
          "jq",
          "js-debug-adapter",
          "json-lsp",
          "jsonlint",
          "lua-language-server",
          "luacheck",
          "marksman",
          "markuplint",
          "netcoredbg",
          "nginx-language-server",
          "nxls",
          "omnisharp",
          "omnisharp-mono",
          "prettier",
          "prettierd",
          "prisma-language-server",
          "prosemd-lsp",
          "pylint",
          "python-lsp-server",
          "ruff-lsp",
          "rust-analyzer",
          "rustywind",
          "selene",
          "shellcheck",
          "shfmt",
          "snyk",
          "some-sass-language-server",
          "sql-formatter",
          "sqlfluff",
          "sqlfmt",
          "sqlls",
          "stylua",
          "tailwindcss-language-server",
          "taplo",
          "trivy",
          "ts-standard",
          "typescript-language-server",
          "vim-language-server",
          "vtsls",
          "write-good",
          "yaml-language-server",
          "yamlfix",
          "yamlfmt",
          "yamllint",
          "circleci-yaml-language-server",
          "sonarlint-language-server",
          "cfn-lint",
          "gitlab-ci-ls",
          "zk",
          "markdown-oxide",
          "gopls",
          "bash-language-server",
          "java-debug-adapter",
          "dot-language-server",
          "htmx-lsp",
          "mdx-analyzer",
          "vint",
          "asm-lsp",
          "zls",
          "svelte-language-server",
          "gradle-language-server",
          "vetur-vls",
          "vue-language-server",
          "luau-lsp",
          "goimports",
          "gofumpt",
          "gomodifytags",
          "impl",
          "delve",
          "semgrep",
          "jdtls",
          "vscode-java-decompiler",
          "google-java-format",
          "stylelint",
          "termux-language-server",
          "shellharden",
          "gersemi",
          "cmakelint",
          "cmakelang",
          "neocmakelsp",
          "cmake-language-server",
          "sleek",
          "eugene",
          "dart-debug-adapter",
          "dcm",
          "kulala-fmt",
          "quick-lint-js",
        },
        ui = {
          icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
          },
        },
      },
      -- ╭─────────────────────────────────────────────────────────╮
      -- │ Manual Install with cmd :MasonInstallAll                │
      -- ╰─────────────────────────────────────────────────────────╯
      config = function(_, opts)
        require("mason").setup(opts)

        -- Remove auto-install behavior
        -- Instead, define a manual command for installing all ensure_installed packages
        vim.api.nvim_create_user_command("MasonInstallAll", function()
          local mr = require("mason-registry")
          mr.refresh(function()
            for _, tool in ipairs(opts.ensure_installed) do
              local p = mr.get_package(tool)
              if not p:is_installed() then
                p:install()
              end
            end
          end)
        end, { desc = "Manually install all Mason tools from ensure_installed" })
      end,

      -- ╭─────────────────────────────────────────────────────────╮
      -- │ Auto-Install                                            │
      -- ╰─────────────────────────────────────────────────────────╯
      ------@param opts MasonSettings | {ensure_installed: string[]}
      ---config = function(_, opts)
      ---  require("mason").setup(opts)
      ---  local mr = require("mason-registry")
      ---  mr:on("package:install:success", function()
      ---    vim.defer_fn(function()
      ---      -- trigger FileType event to possibly load this newly installed LSP server
      ---      require("lazy.core.handler.event").trigger({
      ---        event = "FileType",
      ---        buf = vim.api.nvim_get_current_buf(),
      ---      })
      ---    end, 100)
      ---  end)
      ---
      ---  mr.refresh(function()
      ---    for _, tool in ipairs(opts.ensure_installed) do
      ---      local p = mr.get_package(tool)
      ---      if not p:is_installed() then
      ---        p:install()
      ---      end
      ---    end
      ---  end)
      ---end,
    },
    {
      { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
      {
        "nvim-treesitter/nvim-treesitter",
        lazy = true,
        event = { "BufReadPost", "BufNewFile" },
        opts = {
          ensure_installed = {
            "javascript",
            "typescript",
            "tsx",
            "vue",
            "html",
            "css",
            "scss",
            "json",
            "json5",
            "jsdoc",
            "c_sharp",
            "vim",
            "sql",
            "lua",
            "dockerfile",
            "yaml",
            "http",
            "graphql",
            "gitcommit",
            "gitignore",
            "go",
            "gomod",
            "gowork",
            "gosum",
            "bash",
            "prisma",
            "svelte",
            "java",
            "dart",
            "python",
          },
          auto_install = false, -- Only install when needed

          matchup = {
            enable = true,
          },

          -- https://github.com/nvim-treesitter/playground#query-linter
          query_linter = {
            enable = true,
            use_virtual_text = true,
            lint_events = { "BufWrite", "CursorHold" },
          },

          playground = {
            enable = true,
            disable = {},
            updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
            persist_queries = true, -- Whether the query persists across vim sessions
            keybindings = {
              toggle_query_editor = "o",
              toggle_hl_groups = "i",
              toggle_injected_languages = "t",
              toggle_anonymous_nodes = "a",
              toggle_language_display = "I",
              focus_language = "f",
              unfocus_language = "F",
              update = "R",
              goto_node = "<cr>",
              show_help = "?",
            },
          },
        },
        config = function(_, opts)
          require("nvim-treesitter.configs").setup(opts)

          -- MDX
          vim.filetype.add({
            extension = {
              mdx = "mdx",
            },
          })
          vim.treesitter.language.register("markdown", "mdx")
        end,
      },
    },
    {
      "Exafunction/codeium.nvim",
      cmd = "Codeium",
      event = "InsertEnter",
      build = ":Codeium Auth",
      opts = function()
        return {
          enable_cmp_source = vim.g.ai_cmp,
          virtual_text = {
            -- enabled = not vim.g.ai_cmp,
            enabled = true,
            key_bindings = {
              -- accept = false, -- handled by nvim-cmp / blink.cmp
              accept = "<C-h>",
              -- next = "<M-]>",
              -- prev = "<M-[>",
              next = "<C-h>",
              prev = "<C-l>",
            },
          },
          -- LazyVim AI accept action
          ai_accept = function()
            if require("codeium.virtual_text").get_current_completion_item() then
              LazyVim.create_undo()
              vim.api.nvim_input(require("codeium.virtual_text").accept())
              return true
            end
          end,
        }
      end,
    },
    -- {
    --   "folke/snacks.nvim",
    --   opts = {
    --     picker = {
    --       sources = {
    --         explorer = {
    --           auto_close = true,
    --           hidden = true,
    --         },
    --       },
    --     },
    --   },
    -- },

    -- import/override with your plugins
    { import = "plugins" },
  },

  -- ╭─────────────────────────────────────────────────────────╮
  -- │ default config                                          │
  -- ╰─────────────────────────────────────────────────────────╯
  -- defaults = {
  --   -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
  --   -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
  --   lazy = true,
  --   -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
  --   -- have outdated releases, which may break your Neovim install.
  --   version = false, -- always use the latest git commit
  --   -- version = "*", -- try installing the latest stable version for plugins that support semver
  -- },
  -- install = { colorscheme = { "tokyonight", "habamax" } },
  -- checker = {
  --   enabled = false, -- check for plugin updates periodically
  --   notify = true, -- notify on update
  -- }, -- automatically check for plugin updates
  -- performance = {
  --   rtp = {
  --     -- disable some rtp plugins
  --     disabled_plugins = {
  --       "gzip",
  --       -- "matchit",
  --       -- "matchparen",
  --       -- "netrwPlugin",
  --       "tarPlugin",
  --       "tohtml",
  --       "tutor",
  --       "zipPlugin",
  --     },
  --   },
  -- },

  -- ╭─────────────────────────────────────────────────────────╮
  -- │ Claude optimized                                        │
  -- ╰─────────────────────────────────────────────────────────╯
  defaults = {
    -- Set custom plugins to lazy-load by default for better startup time
    lazy = true,
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
    reset_packpath = true,
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "rplugin",
        "spellfile",
        "editorconfig",
      },
      paths = {},
      reset = true,
    },
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      config = { enabled = true },
      readme = { enabled = false },
    },
  },
})
