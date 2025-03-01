return {
  -- ╭─────────────────────────────────────────────────────────╮
  -- │ Suggestion in cmp                                       │
  -- ╰─────────────────────────────────────────────────────────╯
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    build = ":Codeium Auth",
    opts = function()
      return {
        enable_cmp_source = vim.g.ai_cmp,
        virtual_text = {
          -- enabled = not vim.g.ai_cmp,
          enabled = true,
          key_bindings = {
            -- accept = false, -- handled by nvim-cmp / blink.cmp
            accept = "<C-j>",
            -- next = "<M-]>",
            -- prev = "<M-[>",
            next = "<C-h>",
            prev = "<C-l>",
          },
        },
        -- LazyVim AI accept action
        ai_accept = function()
          if require("codeium.virtual_text").get_current_completion_item() then
            LazyVim.create_undo()
            vim.api.nvim_input(require("codeium.virtual_text").accept())
            return true
          end
        end,
      }
    end,
  },

  -- ╭─────────────────────────────────────────────────────────╮
  -- │ Suggestion ai_accept action                             │
  -- ╰─────────────────────────────────────────────────────────╯
  -- {
  --   "Exafunction/codeium.vim",
  --   config = function()
  --     vim.keymap.set("i", "<C-g>", function()
  --       return vim.fn["codeium#Accept"]()
  --     end, { expr = true, silent = true })
  --     vim.keymap.set("i", "<C-\\>", function()
  --       return vim.fn["codeium#CycleCompletions"](1)
  --     end, { expr = true, silent = true })
  --     vim.keymap.set("i", "<C-]>", function()
  --       return vim.fn["codeium#CycleCompletions"](-1)
  --     end, { expr = true, silent = true })
  --     vim.keymap.set("i", "<C-x>", function()
  --       return vim.fn["codeium#Clear"]()
  --     end, { expr = true, silent = true })
  --   end,
  -- },
}
