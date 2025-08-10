-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set
local opts = { noremap = true, silent = true, nowait = true }

local function show_relative_path()
  local relative_path = vim.fn.expand("%")
  print("Relative Path: " .. relative_path)
end

local function show_project_path()
  local project_path = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    project_path = vim.fn.getcwd()
  end
  print("Project Path: " .. project_path)
end

-- ╭─────────────────────────────────────────────────────────╮
-- │ override default                                        │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>|", "", opts) -- disable Vertical split
map("n", "<leader>-", "", opts) -- disable Horizontal split
map("n", ";", ":", { noremap = true, nowait = true })
map("n", "q", "", opts) -- disable record macro

map("n", "<leader>$", function()
  return show_relative_path()
end, { desc = "Show Relative Path" })
map("n", "<leader>%", function()
  return show_project_path()
end, { desc = "Show Relative th" })
map("n", "Dw", "vb_d", opts) -- delete word backward
map("n", "<C-a>", "gg<S-v>G", opts) -- select all
map("n", "mk", "<cmd>m-2<cr>", opts) -- move line up
map("n", "mj", "<cmd>m+1<cr>", opts) -- move line down
map("n", "+", "<cmd>vertical resize +3<cr>", opts)
map("n", "_", "<cmd>vertical resize -3<cr>", opts)
map("n", ")", "<cmd>horizontal resize +3<cr>", opts)
map("n", "(", "<cmd>horizontal resize -3<cr>", opts)
map("n", "x", '"_x', opts)
map("n", "c", '"_c', opts)
map("v", "c", '"_c', opts)
map("n", "X", '"_X', opts)
map("n", "C", '"_C', opts)
map("v", "C", '"_C', opts)
map("i", "jk", "<ESC>", opts) -- Quick exit insert mode
map("n", "<leader>v", "<cmd>:vsplit<cr>", { desc = "Vertical Split" })
map("n", "<leader>V", "<cmd>:split<cr>", { desc = "Horizontal Split" })

map("n", "<leader>qh", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>qH", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Snacks                                                  │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>'", function()
  Snacks.picker.pick("files", {
    hidden = true, -- Include hidden files (dotfiles)
    no_ignore = true, -- Include files ignored by .gitignore
    root = true, -- Use the current working directory
  })
end, { desc = "Find files (Root Dir) (including hidden)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Avante                                                  │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>a", "", { desc = "Avante" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Recent                                                  │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>fo", LazyVim.pick("oldfiles"), { desc = "Recent Files" })
map("n", "<leader>fO", function()
  Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "Recent Files (cwd)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ increment/decrement numbers                             │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>+", "<M-a>", { desc = "Increment number" }) -- increment
map("n", "<leader>-", "<M-x>", { desc = "Decrement number" }) -- decrement

-- ╭─────────────────────────────────────────────────────────╮
-- │ Diagnostics                                             │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostics hover" })

map("n", "gj", function()
  vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })

map("n", "gk", function()
  vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

map("n", "<leader>\\", "<cmd>LazyExtras<CR>", { desc = "LazyExtras" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ LspLens (link JetBrain that show implementatino and     │
-- │ reference)                                              │
-- ╰─────────────────────────────────────────────────────────╯
-- map("n", "<leader>cL", "<cmd>LspLensToggle<CR>", { desc = "LspLensToggle" })

local lsplens_state = false -- Track state manually (assumes starts disabled)

local function toggle_lsplens()
  vim.cmd("LspLensToggle")

  -- Toggle our tracked state
  lsplens_state = not lsplens_state

  local message = lsplens_state and "LspLens enable !" or "LspLens disable !"

  vim.notify(message, vim.log.levels.INFO, {
    title = "🔍 LspLens",
    timeout = 2000,
  })
end

map("n", "<leader>cL", toggle_lsplens, { desc = "Toggle LspLens" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Terminal                                                │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>T", function()
  vim.cmd("tabnew | terminal")
end, { desc = "Open Terminal in New Tab" })
map("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
map("n", "<c-/>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), win = { height = 8 } })
end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), win = { height = 8 } })
end, { desc = "which_key_ignore" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

map("n", "<leader>fL", function()
  Snacks.terminal(nil, { win = { position = "left" } })
end, { desc = "Terminal left" })

map("n", "<leader>fR", function()
  Snacks.terminal(nil, { win = { position = "right" } })
end, { desc = "Terminal right" })

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

-- map("n", "<leader>gO", "<cmd>DiffviewOpen<cr>", { noremap = true, silent = true })
-- map("n", "gO", "<cmd>DiffviewOpen<cr>", { noremap = true, silent = true })
-- map("n", "<leader>gC", "<cmd>DiffviewClose<cr>", { noremap = true, silent = true })
-- map("n", "gC", "<cmd>DiffviewClose<cr>", { noremap = true, silent = true })

map("n", "<leader>gC", toggle_diffview, { noremap = true, silent = true, desc = "Toggle Diffview" })
map("n", "gC", toggle_diffview, { noremap = true, silent = true, desc = "Toggle Diffview" })
map("n", "<leader>gF", "<cmd>DiffviewFocusFiles<cr>", { noremap = true, silent = true })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { noremap = true, silent = true })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Telescope                                               │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>s?", function()
  require("telescope.builtin").current_buffer_fuzzy_find({
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.8, -- 80% of the screen width
      height = 0.9, -- 90% of the screen height
      -- preview_width = 0.5, -- 50% of the window for preview
    },
    winblend = 15, -- transparent 15%
    previewer = false,
  })
end, { desc = "Search in Current Buffer with Telescope" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ GitGraph                                                │
-- ╰─────────────────────────────────────────────────────────╯
map("n", "<leader>g|", function()
  require("gitgraph").draw({}, { all = true, max_count = 5000 })
end, { desc = "GitGraph" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Cord Nvim                                               │
-- ╰─────────────────────────────────────────────────────────╯
local function toggle_cord()
  -- Check if Cord is available
  if vim.fn.exists(":Cord") == 0 then
    vim.notify("Cord.nvim not loaded", vim.log.levels.WARN, { title = "Cord.nvim" })
    return
  end

  -- Alternative method: Check if Cord module is loaded and has timer running
  local cord_ok, cord = pcall(require, "cord")
  if not cord_ok then
    vim.notify("Could not access Cord module", vim.log.levels.ERROR, { title = "Cord.nvim" })
    return
  end

  vim.cmd("Cord toggle")

  -- Wait a bit for the toggle to take effect, then check status
  vim.defer_fn(function()
    -- Try to detect if cord is active by checking if timer exists
    -- This is a bit hacky but should work
    local success, result = pcall(function()
      return cord.timer ~= nil and cord.timer:is_active()
    end)

    if success and result then
      vim.notify("Discord Rich Presence Enabled", vim.log.levels.INFO, { title = "🎮 Cord.nvim" })
    else
      vim.notify("Discord Rich Presence Disabled", vim.log.levels.INFO, { title = "🎮 Cord.nvim" })
    end
  end, 100) -- Wait 100ms for toggle to complete
end

map("n", "<leader>dd", toggle_cord, { desc = "Toggle Discord Rich Presence" })

-- Dynamic search and replace with <leader>sR
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
-- │ Code Fold keymap                                        │
-- ╰─────────────────────────────────────────────────────────╯
-- za - Toggle the current fold
-- zc - Close the current fold
-- zo - Open the current fold
-- zM - Close all folds
-- zR - Open all folds
