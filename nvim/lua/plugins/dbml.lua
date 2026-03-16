-- ╭─────────────────────────────────────────────────────────╮
-- │ DBML (Database Markup Language) support                 │
-- │                                                         │
-- │ Features:                                               │
-- │   - Syntax highlighting (vim-dbml)                      │
-- │   - Tree-sitter highlighting (experimental)             │
-- │   - LSP via dbml-language-server (basic completion)     │
-- │   - Render DBML to SVG  (<leader>dp)                    │
-- │   - Convert DBML to SQL (<leader>ds)                    │
-- ╰─────────────────────────────────────────────────────────╯
return {
  -- ── Syntax highlighting ──────────────────────────────────
  { "jidn/vim-dbml", ft = "dbml" },

  -- ── Tree-sitter (experimental) ───────────────────────────
  -- Registers custom parser via User TSUpdate autocmd (modern nvim-treesitter API).
  -- After restarting Neovim, run :TSInstall dbml to install the parser.
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({ extension = { dbml = "dbml" } })
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").dbml = {
            install_info = {
              url = "https://github.com/dynamotn/tree-sitter-dbml",
              branch = "main",
            },
            tier = 4,
          }
        end,
      })
    end,
  },

  -- ── LSP (dbml-language-server) ───────────────────────────
  -- POC-level: provides basic semantic completion only.
  -- No goto-definition, no diagnostics, no renaming.
  -- Comment out this block if you find it not useful.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dbml_ls = {
          cmd = { vim.fn.expand("~/.local/bin/dbml-language-server") },
          filetypes = { "dbml" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(".git", "*.dbml")(fname)
              or require("lspconfig.util").path.dirname(fname)
          end,
          single_file_support = true,
        },
      },
    },
  },

  -- ── Keybindings for render / convert ─────────────────────
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>D", group = "dbml", icon = "" },
      },
    },
  },

  -- ── FileType autocmd for DBML keymaps ────────────────────
  {
    "jidn/vim-dbml",
    ft = "dbml",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbml",
        callback = function(ev)
          local map = vim.keymap.set

          -- Preview DBML as SVG (rendered in HTML wrapper, fit-to-screen)
          map("n", "<leader>Dp", function()
            local file = vim.fn.expand("%:p")
            local svg = vim.fn.expand("%:p:r") .. ".svg"
            local name = vim.fn.expand("%:t:r")
            local result = vim.fn.system({ "dbml-renderer", "-i", file, "-o", svg })
            if vim.v.shell_error ~= 0 then
              vim.notify("DBML render failed:\n" .. result, vim.log.levels.ERROR, { title = "DBML" })
              return
            end
            -- Create HTML wrapper for fit-to-viewport preview
            local html_path = "/tmp/dbml-preview-" .. name .. ".html"
            local html = string.format(
              [[<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>DBML: %s</title>
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: flex-start;
      background: #1a1b26;
      padding: 24px;
    }
    img {
      max-width: 100%%;
      height: auto;
    }
  </style>
</head>
<body>
  <img src="file://%s" />
</body>
</html>]],
              name,
              svg
            )
            local f = io.open(html_path, "w")
            if f then
              f:write(html)
              f:close()
              vim.fn.system({ "open", html_path })
              vim.notify("Preview: " .. name .. ".svg", vim.log.levels.INFO, { title = "DBML" })
            else
              vim.notify("Failed to create HTML preview", vim.log.levels.ERROR, { title = "DBML" })
            end
          end, { buffer = ev.buf, desc = "Preview DBML as SVG" })

          -- Convert DBML to SQL (PostgreSQL by default)
          map("n", "<leader>Ds", function()
            local file = vim.fn.expand("%:p")
            local out = vim.fn.expand("%:p:r") .. ".sql"
            local result = vim.fn.system({ "dbml2sql", file, "-o", out })
            if vim.v.shell_error ~= 0 then
              vim.notify("DBML to SQL failed:\n" .. result, vim.log.levels.ERROR, { title = "DBML" })
            else
              vim.cmd("edit " .. vim.fn.fnameescape(out))
              vim.notify(
                "Generated SQL (PostgreSQL): " .. vim.fn.fnamemodify(out, ":t"),
                vim.log.levels.INFO,
                { title = "DBML" }
              )
            end
          end, { buffer = ev.buf, desc = "Convert DBML to SQL" })

          -- Convert DBML to MySQL
          map("n", "<leader>Dm", function()
            local file = vim.fn.expand("%:p")
            local out = vim.fn.expand("%:p:r") .. ".sql"
            local result = vim.fn.system({ "dbml2sql", file, "--mysql", "-o", out })
            if vim.v.shell_error ~= 0 then
              vim.notify("DBML to MySQL failed:\n" .. result, vim.log.levels.ERROR, { title = "DBML" })
            else
              vim.cmd("edit " .. vim.fn.fnameescape(out))
              vim.notify(
                "Generated SQL (MySQL): " .. vim.fn.fnamemodify(out, ":t"),
                vim.log.levels.INFO,
                { title = "DBML" }
              )
            end
          end, { buffer = ev.buf, desc = "Convert DBML to MySQL" })
        end,
      })
    end,
  },
}
