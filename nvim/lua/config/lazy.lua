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
        -- colorscheme = "tokyonight-storm",
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
      opts = {
        ensure_installed = {"flake8", "pyright", "bash-debug-adapter", "ast-grep", "autopep8", "beautysh", "biome", "chrome-debug-adapter", "clang-format", "clangd", "codelldb", "cortex-debug", "cpplint", "cpptools", "csharp-language-server", "csharpier", "css-lsp", "css-variables-language-server", "cssmodules-language-server", "debugpy", "docker-compose-language-service", "dockerfile-language-server", "emmet-language-server", "emmet-ls", "erb-lint", "eslint-lsp", "eslint_d", "firefox-debug-adapter", "fixjson", "glow", "go-debug-adapter", "graphql-language-service-cli", "hadolint", "html-lsp", "htmlbeautifier", "htmlhint", "jq", "js-debug-adapter", "json-lsp", "jsonlint", "lua-language-server", "luacheck", "marksman", "markuplint", "netcoredbg", "nginx-language-server", "nxls", "omnisharp", "omnisharp-mono", "prettier", "prettierd", "prisma-language-server", "prosemd-lsp", "pylint", "python-lsp-server", "ruff-lsp", "rust-analyzer", "rustywind", "selene", "shellcheck", "shfmt", "snyk", "some-sass-language-server", "sql-formatter", "sqlfluff", "sqlfmt", "sqlls", "stylua", "tailwindcss-language-server", "taplo", "trivy", "ts-standard", "typescript-language-server", "vim-language-server", "vtsls", "write-good", "yaml-language-server", "yamlfix", "yamlfmt", "yamllint", "circleci-yaml-language-server", "sonarlint-language-server", "cfn-lint", "gitlab-ci-ls", "zk", "markdown-oxide", "gopls", "bash-language-server", "java-debug-adapter", "dot-language-server", "htmx-lsp", "mdx-analyzer", "vint", "asm-lsp", "zls", "svelte-language-server", "gradle-language-server", "vetur-vls", "vue-language-server", "luau-lsp", "goimports", "gofumpt", "gomodifytags", "impl", "delve", "semgrep", "jdtls", "vscode-java-decompiler", "google-java-format", "stylelint", "termux-language-server", "shellharden", "gersemi", "cmakelint", "cmakelang", "neocmakelsp", "cmake-language-server", "sleek", "eugene", "dart-debug-adapter", "dcm", "kulala-fmt", "quick-lint-js",},
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
        opts = {
          ensure_installed = {"javascript", "typescript", "tsx", "vue", "html", "css", "scss", "json", "json5", "jsdoc", "c_sharp", "vim", "sql", "lua", "dockerfile", "yaml", "http", "graphql", "gitcommit", "gitignore", "go", "gomod", "gowork", "gosum", "bash", "prisma", "svelte", "java", "dart", "python",},
          auto_install = true, -- Automatically install missing parsers

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
