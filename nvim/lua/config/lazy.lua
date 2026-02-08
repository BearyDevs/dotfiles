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
        -- storm, dark, moon, night, day
        colorscheme = "tokyonight-moon",
        -- colorscheme = "catppuccin-mocha",
        -- colorscheme = "solarized-osaka",
      },
    },
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
      "folke/snacks.nvim",
      opts = {
        scroll = { enabled = false },
        dashboard = {
          enabled = false,
          --   preset = {
          --     header = [[
          -- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
          -- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
          -- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
          -- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
          -- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
          -- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
          --   ]],
          --   },
        },
        picker = {
          hidden = true,
          ignored = true,
          sources = {
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
      --   -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#E06C75" })  -- Custom red
      --   -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#E06C75" })  -- Custom red for scope
      --   -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#E5C07B" })  -- Custom yellow
      --   -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#E5C07B" })  -- Custom yellow for scope
      --
      --   -- vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#FFB3D9" })  -- Light pink
      --   -- vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#FFB3D9" })  -- Light pink for scope
      --   vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#47ff9c" })
      --   vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#47ff9c" })
      -- end,
    },
    {
      "mason-org/mason.nvim",
      lazy = true,
      opts = {
        ui = {
          icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
          },
        },
        ensure_installed = {
          "gitlab-ci-ls",
          "prisma-language-server",
          "css-variables-language-server",
          "trivy",
          "lua-language-server",
          "bash-language-server",
          "beautysh",
          "bqls",
          "css-lsp",
          "cssmodules-language-server",
          "docker-compose-language-service",
          "docker-language-server",
          "dockerfile-language-server",
          "dotenv-linter",
          "emmet-language-server",
          "emmet-ls",
          "eslint-lsp",
          "eslint_d",
          "gh-actions-language-server",
          "gitui",
          "hadolint",
          "html-lsp",
          "htmlbeautifier",
          "js-debug-adapter",
          "json-lsp",
          "markdown-toc",
          "markdownlint-cli2",
          "marksman",
          "pgformatter",
          "postgres-language-server",
          "prettier",
          "rustywind",
          "shfmt",
          "sonarlint-language-server",
          "sql-formatter",
          "sqls",
          "stylua",
          "tailwindcss-language-server",
          "taplo",
          "typescript-language-server",
          "vtsls",
          "yaml-language-server",
        },
      },
    },
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
