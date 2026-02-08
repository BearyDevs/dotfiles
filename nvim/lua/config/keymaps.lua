-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set
local opts = { noremap = true, silent = true, nowait = true }

--
local function show_relative_path()
  local relative_path = vim.fn.expand("%")
  print("Relative Path: " .. relative_path)
end
map("n", "<leader>$", function()
  return show_relative_path()
end, { desc = "Show Relative Path" })
--
local function show_project_path()
  local project_path = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    project_path = vim.fn.getcwd()
  end
  print("Project Path: " .. project_path)
end
map("n", "<leader>%", function()
  return show_project_path()
end, { desc = "Show Relative th" })
--

map("n", ";", ":", { noremap = true, nowait = true })
map("n", "q", "", opts) -- disable record macro
map("n", "Dw", "vb_d", opts) -- delete word backward
---
map("n", "<C-a>", "gg<S-v>G", opts) -- select all
--
map("n", "mk", "<cmd>m-2<cr>", opts) -- move line up
map("n", "mj", "<cmd>m+1<cr>", opts) -- move line down
--
map("n", "+", "<cmd>vertical resize +3<cr>", opts)
map("n", "_", "<cmd>vertical resize -3<cr>", opts)
map("n", ")", "<cmd>horizontal resize +3<cr>", opts)
map("n", "(", "<cmd>horizontal resize -3<cr>", opts)

map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
map("n", "<leader>V", "<cmd>split<cr>", { desc = "Horizontal Split" })
--
map("n", "x", '"_x', opts)
map("n", "c", '"_c', opts)
map("v", "c", '"_c', opts)
map("n", "X", '"_X', opts)
map("n", "C", '"_C', opts)
map("v", "C", '"_C', opts)
map("i", "jk", "<ESC>", opts) -- Quick exit insert mode
--
map("n", "<leader>\\", "<cmd>LazyExtras<CR>", { desc = "LazyExtras" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Dynamic search and replace                              │
-- ╰─────────────────────────────────────────────────────────╯
vim.keymap.set("n", "<leader>sR", function()
  vim.ui.input({ prompt = "Search: " }, function(search)
    if search and search ~= "" then
      vim.ui.input({ prompt = "Replace: " }, function(replace)
        if replace then
          local cmd = string.format("%%s/%s/%s/gc", vim.fn.escape(search, "/\\"), vim.fn.escape(replace or "", "/\\"))
          vim.cmd(cmd)
        end
      end)
    end
  end)
end, { desc = "Dynamic search and replace" })

-- Visual mode version
vim.keymap.set("v", "<leader>sR", function()
  vim.ui.input({ prompt = "Search: " }, function(search)
    if search and search ~= "" then
      vim.ui.input({ prompt = "Replace: " }, function(replace)
        if replace then
          local cmd =
            string.format("'<,'>s/%s/%s/gc", vim.fn.escape(search, "/\\"), vim.fn.escape(replace or "", "/\\"))
          vim.cmd(cmd)
        end
      end)
    end
  end)
end, { desc = "Dynamic search and replace in selection" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diagnostics                                             │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "gl", function()
  -- Map LSP source names to Mason package names for clarity
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
    ["hadolint"] = "hadolint",
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

  vim.diagnostic.open_float({
    border = "rounded",
    source = "if_many", -- Show source only if multiple sources exist
    format = function(diagnostic)
      local message = diagnostic.message
      local code = diagnostic.code

      -- If code exists and is not already in the message, append it
      if code and not message:find(vim.pesc(tostring(code))) then
        return string.format("%s [%s]", message, code)
      end

      return message
    end,
    prefix = function(diagnostic, i, total)
      local icon = "●"
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        icon = ""
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        icon = ""
      elseif diagnostic.severity == vim.diagnostic.severity.INFO then
        icon = ""
      elseif diagnostic.severity == vim.diagnostic.severity.HINT then
        icon = ""
      end

      -- Map source to Mason package name
      local source = diagnostic.source or ""
      local display_source = source_map[source] or source

      if display_source ~= "" then
        return string.format("%d. %s [%s] ", i, icon, display_source),
          "DiagnosticFloating" .. vim.diagnostic.severity[diagnostic.severity]
      end

      return string.format("%d. %s ", i, icon), "DiagnosticFloating" .. vim.diagnostic.severity[diagnostic.severity]
    end,
  })
end, { desc = "Show diagnostics hover" })

map("n", "gj", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })

map("n", "gk", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Snacks                                                  │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>qh", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>qH", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>'", function()
  Snacks.picker.pick("files", {
    hidden = true, -- Include hidden files (dotfiles)
    no_ignore = true, -- Include files ignored by .gitignore
    root = true, -- Use the current working directory
  })
end, { desc = "Find files (Root Dir) (including hidden)" })
map("n", "<leader>fo", function()
  Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "Recent Files (cwd)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ LepLens                                                 │
-- ╰─────────────────────────────────────────────────────────╯
local lsplens_state = false -- Track state manually (assumes starts disabled)
local function toggle_lsplens()
  vim.cmd("LspLensToggle")
  lsplens_state = not lsplens_state
  local message = lsplens_state and "LspLens enable !" or "LspLens disable !"
  vim.notify(message, vim.log.levels.INFO, {
    title = "🔍 LspLens",
    timeout = 2000,
  })
end
map("n", "<leader>cL", toggle_lsplens, { desc = "Toggle LspLens" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Formatting                                              │
-- ╰─────────────────────────────────────────────────────────╯
map({ "n", "v" }, "gm", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diffview                                                │
-- ╰─────────────────────────────────────────────────────────╯
local function toggle_diffview()
  local view = require("diffview.lib").get_current_view()
  if view then
    -- If a view is open, close it
    vim.cmd("DiffviewClose")
  else
    -- If no view is open, open it
    vim.cmd("DiffviewOpen")
  end
end
map("n", "<leader>gC", toggle_diffview, { noremap = true, silent = true, desc = "Toggle Diffview" })
map("n", "gC", toggle_diffview, { noremap = true, silent = true, desc = "Toggle Diffview" })
map("n", "<leader>gF", "<cmd>DiffviewFocusFiles<cr>", { noremap = true, silent = true })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { noremap = true, silent = true })
map("n", "<leader>gH", "<cmd>DiffviewClose<cr>", { noremap = true, silent = true, desc = "Close Diffview" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Twilight                                                │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>U", "<cmd>Twilight<cr>", { noremap = true, silent = true, desc = "Toggle Twilight" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ GitGraph                                                │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>gG", function()
  require("gitgraph").draw({}, { all = true, max_count = 5000 })
end, { desc = "GitGraph" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Show all active Mason tools for current buffer          │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>gM", function()
  local mason_ok, mason_registry = pcall(require, "mason-registry")
  if not mason_ok then
    vim.notify("Mason not available", vim.log.levels.WARN)
    return
  end

  local filetype = vim.bo.filetype
  local lsp_clients = vim.lsp.get_clients({ bufnr = 0 })
  local installed_packages = mason_registry.get_installed_packages()

  local active_tools = {}
  local lsp_names = {}

  -- Get active LSP clients
  for _, client in ipairs(lsp_clients) do
    table.insert(lsp_names, client.name)
  end

  -- Find related Mason packages for this filetype
  for _, pkg in ipairs(installed_packages) do
    local pkg_name = pkg.name
    -- Common patterns for different filetypes
    if filetype == "lua" and (pkg_name:match("lua") or pkg_name == "selene" or pkg_name == "luacheck") then
      table.insert(active_tools, pkg_name)
    elseif
      filetype == "javascript"
      or filetype == "typescript"
        and (pkg_name:match("js") or pkg_name:match("ts") or pkg_name:match("eslint") or pkg_name == "prettier" or pkg_name == "biome")
    then
      table.insert(active_tools, pkg_name)
    -- DISABLED: gopls causing diffview inlayHint errors
    -- elseif filetype == "go" and (pkg_name:match("go") or pkg_name == "gopls") then
    --   table.insert(active_tools, pkg_name)
    elseif filetype == "python" and (pkg_name:match("py") or pkg_name == "ruff") then
      table.insert(active_tools, pkg_name)
    end
  end

  local info = {
    "Mason Tools for " .. filetype .. ":",
    "─────────────────────────",
    "Active LSP clients: " .. table.concat(lsp_names, ", "),
    "Related Mason packages:",
  }

  for _, tool in ipairs(active_tools) do
    table.insert(info, "  • " .. tool)
  end

  if #active_tools == 0 then
    table.insert(info, "  (none found)")
  end

  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO, { title = "Mason Tools", timeout = 2000 })
end, { desc = "Show Mason tools for current buffer" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Code Fold keymap                                        │
-- ╰─────────────────────────────────────────────────────────╯
-- za - Toggle the current fold
-- zc - Close the current fold
-- zo - Open the current fold
-- zM - Close all folds
-- zR - Open all folds
