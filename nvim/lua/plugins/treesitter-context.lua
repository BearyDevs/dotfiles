return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "LazyFile",
  opts = function()
    local tsc = require("treesitter-context")
    Snacks.toggle({
      name = "Treesitter Context",
      get = tsc.enabled,
      set = function(state)
        if state then
          tsc.enable()
        else
          tsc.disable()
        end
      end,
    }):map("<leader>ut")

    -- Create a new highlight for transparent background
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "LineNr" })
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TreesitterContextBottom", { sp = "#3DBFFF", underline = false })

    -- Add a ColorScheme autocmd to ensure these highlights persist
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TreesitterContextBottom", { sp = "#3DBFFF", underline = false })
      end,
    })

    return {
      mode = "cursor",
      max_lines = 5,
      -- Custom separators instead of background color
      separator = "─", -- Use a nice separator line
    }
  end,
}
