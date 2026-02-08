-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ╭─────────────────────────────────────────────────────────╮
-- │ Turn off paste mode when leaving insert                 │
-- ╰─────────────────────────────────────────────────────────╯
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Add this to your init.lua or in a separate file like lua/config/filetypes.lua
-- Override filetype detection for .env files
vim.filetype.add({
  pattern = {
    [".*%.env.*"] = "dotenv",
  },
  filename = {
    [".env"] = "dotenv",
    [".env.local"] = "dotenv",
    [".env.development"] = "dotenv",
    [".env.production"] = "dotenv",
    [".env.test"] = "dotenv",
    [".env.sit"] = "dotenv",
    [".env.uat"] = "dotenv",
    [".env.dev"] = "dotenv",
    [".env.example"] = "dotenv",
  },
})

-- Add this to your LSP configuration to completely disable LSP for dotenv files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dotenv",
  callback = function(args)
    -- Disable all LSP clients for dotenv files
    local clients = vim.lsp.get_clients({ bufnr = args.buf })
    for _, client in ipairs(clients) do
      vim.lsp.buf_detach_client(args.buf, client.id)
    end
  end,
})
-- Add this to your init.lua or create lua/after/ftplugin/dotenv.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dotenv",
  callback = function()
    -- Set commentstring for mini.comment to work properly
    vim.bo.commentstring = "# %s"

    -- Basic syntax highlighting for .env files
    vim.cmd([[
      syntax clear
      syntax match envComment "^#.*$"
      syntax match envKey "^[A-Za-z_][A-Za-z0-9_]*" nextgroup=envEquals
      syntax match envEquals "=" contained nextgroup=envValue
      syntax match envValue ".*$" contained
      syntax region envString start='"' end='"' contained
      syntax region envString start="'" end="'" contained
      
      highlight default link envComment Comment
      highlight default link envKey Identifier
      highlight default link envEquals Operator
      highlight default link envValue String
      highlight default link envString String
    ]])
  end,
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ Enhanced Recent Files Tracking                          │
-- ╰─────────────────────────────────────────────────────────╯
-- Automatically add files to recent list when opened
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*",
  callback = function(args)
    local file_path = vim.fn.expand("%:p")
    -- Only track real files (not empty buffers, terminals, etc.)
    if file_path and file_path ~= "" and vim.fn.filereadable(file_path) == 1 then
      -- Add to Neovim's oldfiles list
      vim.cmd("call histadd(':', 'edit ' . expand('%:p'))")
    end
  end,
  desc = "Track recently opened files",
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})
