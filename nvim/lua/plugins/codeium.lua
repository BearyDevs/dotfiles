return {
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- Any codeium specific configuration can go here
    end,
    keys = {
      -- Normal mode mapping
      -- { "<Leader>;", "<Cmd>CodeiumToggle<CR>", desc = "Toggle Codeium active" },
      { "<Leader>;", function()
          vim.cmd("CodeiumToggle")
          local is_active = vim.g.codeium_enabled -- Assuming this variable holds the state
          if is_active then
            require("noice").notify("Codeium Active", "info")
          else
            require("noice").notify("Codeium Not Active", "info")
          end
        end, desc = "Toggle Codeium active" },
      -- Insert mode mappings
      { "<C-g>", function() return vim.fn["codeium#Accept"]() end, mode = "i", expr = true },
      { "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, mode = "i", expr = true },
      { "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, mode = "i", expr = true },
      { "<C-x>", function() return vim.fn["codeium#Clear"]() end, mode = "i", expr = true },
    },
    cmd = {
      "Codeium",
      "CodeiumEnable",
      "CodeiumDisable",
      "CodeiumToggle",
      "CodeiumAuto",
      "CodeiumManual",
    },
  }
}
