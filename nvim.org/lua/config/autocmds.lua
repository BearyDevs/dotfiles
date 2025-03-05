-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Performance optimization autocmds
local perf_group = vim.api.nvim_create_augroup("performance_optimizations", { clear = true })

-- Optimize search performance
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = perf_group,
  pattern = "/,\\?",
  callback = function()
    vim.opt_local.hlsearch = false
    vim.opt_local.redrawtime = 500
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = perf_group,
  pattern = "/,\\?",
  callback = function()
    vim.opt_local.hlsearch = true
    vim.opt_local.redrawtime = 1500
  end,
})

-- Only highlight line when in active window 
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  group = perf_group,
  callback = function()
    if vim.bo.filetype ~= "neo-tree" then
      vim.opt_local.cursorline = false
    end
  end,
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
  group = perf_group,
  callback = function()
    if vim.bo.filetype ~= "neo-tree" then
      vim.opt_local.cursorline = true
    end
  end,
})

-- Disable syntax highlighting in very large files
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  group = perf_group,
  callback = function(ev)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and (stats.size > 5 * 1024 * 1024) then -- 5MB
      vim.cmd("syntax off")
      vim.opt_local.foldmethod = "manual"
      vim.notify("Very large file detected. Syntax highlighting disabled.", vim.log.levels.WARN)
    end
  end,
})

-- Disable certain features in large files
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  group = perf_group,
  callback = function(ev)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and (stats.size > 2 * 1024 * 1024) then -- 2MB
      -- Disable features that can be slow on large files
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      if vim.fn.has("nvim-0.9") == 1 then
        vim.opt_local.statuscolumn = ""
      end
    end
  end,
})

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})
