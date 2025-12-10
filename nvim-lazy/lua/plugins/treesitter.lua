return {
  -- { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss" })
      end
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
        callback = function()
          vim.treesitter.start(nil, "angular")
        end,
      })
    end,
  },
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
        "graphql",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "prisma",
        "svelte",
        "java",
        "dart",
        "python",
      },
      auto_install = true, -- Only install when needed

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
    -- config = function(_, opts)
    --   require("nvim-treesitter.configs").setup(opts)
    --
    --   -- MDX
    --   vim.filetype.add({
    --     extension = {
    --       mdx = "mdx",
    --     },
    --   })
    --   vim.treesitter.language.register("markdown", "mdx")
    -- end,
  },
}
