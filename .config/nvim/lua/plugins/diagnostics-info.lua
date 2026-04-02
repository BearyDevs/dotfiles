return {
  "neovim/nvim-lspconfig",
  keys = {
    {
      "<leader>di",
      function()
        local buf = vim.api.nvim_get_current_buf()
        local filetype = vim.bo[buf].filetype

        -- Map LSP source names to Mason package names
        local source_map = {
          -- TypeScript/JavaScript
          ["ts"] = "typescript-language-server",
          ["tsserver"] = "typescript-language-server",
          ["ts_ls"] = "typescript-language-server",
          ["vtsls"] = "vtsls",
          ["eslint"] = "eslint-lsp",
          ["eslint_d"] = "eslint_d",

          -- Lua
          ["lua_ls"] = "lua-language-server",
          ["Lua Syntax Check."] = "lua-language-server",

          -- CSS/Styling
          ["tailwindcss"] = "tailwindcss-language-server",
          ["cssls"] = "css-lsp",
          ["css_variables"] = "css-variables-language-server",
          ["cssmodules_ls"] = "cssmodules-language-server",

          -- HTML/Emmet
          ["html"] = "html-lsp",
          ["emmet_ls"] = "emmet-ls",
          ["emmet_language_server"] = "emmet-language-server",

          -- Data formats
          ["jsonls"] = "json-lsp",
          ["yamlls"] = "yaml-language-server",
          ["taplo"] = "taplo",

          -- Docker
          ["dockerls"] = "dockerfile-language-server",
          ["docker_language_server"] = "docker-language-server",
          ["docker_compose_language_service"] = "docker-compose-language-service",

          -- Database
          ["prismals"] = "prisma-language-server",
          ["sqls"] = "sqls",
          ["postgres_lsp"] = "postgres-language-server",
          ["bqls"] = "bqls",

          -- Shell/Bash
          ["bashls"] = "bash-language-server",

          -- Markdown
          ["marksman"] = "marksman",
          ["markdownlint"] = "markdownlint-cli2",

          -- CI/CD
          ["gh_actions_ls"] = "gh-actions-language-server",
          ["gitlab_ci_ls"] = "gitlab-ci-ls",

          -- Security/Linting
          ["sonarlint"] = "sonarlint-language-server",
          --["hadolint"] = "hadolint",
          ["dotenv-linter"] = "dotenv-linter",
          ["trivy"] = "trivy",
          ["snyk"] = "snyk",

          -- Formatters
          ["prettier"] = "prettier",
          ["prettierd"] = "prettierd",
          ["stylua"] = "stylua",
          ["beautysh"] = "beautysh",
          ["shfmt"] = "shfmt",
          ["rustywind"] = "rustywind",
        }

        -- Get active LSP clients
        local lsp_clients = vim.lsp.get_clients({ bufnr = buf })
        local lsp_info = {}
        for _, client in ipairs(lsp_clients) do
          table.insert(lsp_info, {
            name = client.name,
            root_dir = client.config.root_dir or "N/A",
          })
        end

        -- Get diagnostics by source
        local diagnostics = vim.diagnostic.get(buf)
        local sources = {}
        for _, diag in ipairs(diagnostics) do
          local source = diag.source or "unknown"
          local display_source = source_map[source] or source
          sources[display_source] = (sources[display_source] or 0) + 1
        end

        -- Build info display
        local lines = {
          "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
          "📊 Diagnostics Info for: " .. filetype,
          "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
          "",
          "🔧 Active LSP Clients:",
        }

        if #lsp_info > 0 then
          for _, client in ipairs(lsp_info) do
            table.insert(lines, "  • " .. client.name)
            table.insert(lines, "    └─ Root: " .. client.root_dir)
          end
        else
          table.insert(lines, "  (none active)")
        end

        table.insert(lines, "")
        table.insert(lines, "⚠️  Diagnostic Sources (Mason packages):")

        if next(sources) then
          for source, count in pairs(sources) do
            table.insert(lines, string.format("  • %s: %d issue(s)", source, count))
          end
        else
          table.insert(lines, "  ✅ No diagnostics!")
        end

        -- Check for nvim-lint
        local lint_ok, lint = pcall(require, "lint")
        if lint_ok and lint.linters_by_ft[filetype] then
          table.insert(lines, "")
          table.insert(lines, "🔍 nvim-lint Linters:")
          for _, linter in ipairs(lint.linters_by_ft[filetype]) do
            table.insert(lines, "  • " .. linter)
          end
        end

        -- Check for conform formatters
        local conform_ok, conform = pcall(require, "conform")
        if conform_ok then
          local formatters = conform.list_formatters(buf)
          if #formatters > 0 then
            table.insert(lines, "")
            table.insert(lines, "✨ Active Formatters:")
            for _, formatter in ipairs(formatters) do
              table.insert(lines, "  • " .. formatter.name)
            end
          end
        end

        table.insert(lines, "")
        table.insert(
          lines,
          "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        )
        table.insert(lines, "💡 Tip: Hover on diagnostic for source info")

        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
          title = "Diagnostic Sources",
          timeout = 5000,
        })
      end,
      desc = "Show diagnostic sources info",
    },
  },
}
