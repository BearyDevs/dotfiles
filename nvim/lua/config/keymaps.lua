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
  vim.diagnostic.open_float()
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
