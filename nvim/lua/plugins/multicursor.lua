return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      local set = vim.keymap.set
      local prefix = "<leader>m"

      set({ "n", "x" }, prefix, "", { desc = "Multicursor" })

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, prefix .. "<up>", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add Cursor Above" })

      set({ "n", "x" }, prefix .. "<down>", function()
        mc.lineAddCursor(1)
      end, { desc = "Add Cursor Below" })

      set({ "n", "x" }, prefix .. "<up>", function()
        mc.lineSkipCursor(-1)
      end, { desc = "Skip Cursor Above" })

      set({ "n", "x" }, prefix .. "<down>", function()
        mc.lineSkipCursor(1)
      end, { desc = "Skip Cursor Below" })

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, prefix .. "n", function()
        mc.matchAddCursor(1)
      end, { desc = "Add Cursor Matching Below" })

      set({ "n", "x" }, prefix .. "d", function()
        mc.clearCursors()
      end, { desc = "Clear All Cursors" })

      set({ "n", "x" }, prefix .. "s", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip Cursor Matching Below" })

      set({ "n", "x" }, prefix .. "N", function()
        mc.matchAddCursor(-1)
      end, { desc = "Add Cursor Matching Above" })

      set({ "n", "x" }, prefix .. "S", function()
        mc.matchSkipCursor(-1)
      end, { desc = "Skip Cursor Matching Above" })

      -- In normal/visual mode, press `mwap` will create a cursor in every match of
      -- the word captured by `iw` (or visually selected range) inside the bigger
      -- range specified by `ap`. Useful to replace a word inside a function, e.g. mwif.
      set({ "n", "x" }, "mw", function()
        mc.operator({ motion = "iw", visual = true })
        -- Or you can pass a pattern, press `mwi{` will select every \w,
        -- basically every char in a `{ a, b, c, d }`.
        -- mc.operator({ pattern = [[\<\w]] })
      end)

      -- Press `mWi"ap` will create a cursor in every match of string captured by `i"` inside range `ap`.
      set("n", "mW", mc.operator)

      -- Add all matches in the document
      set({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "matchAllAddCursors" })

      -- You can also add cursors with any motion you prefer:
      -- set("n", "<right>", function()
      --     mc.addCursor("w")
      -- end)
      -- set("n", "<leader><right>", function()
      --     mc.skipCursor("w")
      -- end)

      -- Rotate the main cursor.
      set({ "n", "x" }, "<left>", mc.nextCursor)
      set({ "n", "x" }, "<right>", mc.prevCursor)

      -- Delete the main cursor.
      set({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "deleteCursor" })

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse)
      set("n", "<c-leftdrag>", mc.handleMouseDrag)
      set("n", "<c-leftrelease>", mc.handleMouseRelease)

      -- Easy way to add and remove cursors using the main cursor.
      set({ "n", "x" }, "<c-q>", mc.toggleCursor)

      -- Clone every cursor and disable the originals.
      set({ "n", "x" }, "<leader><c-q>", mc.duplicateCursors)

      set("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          -- Default <esc> handler.
        end
      end)

      -- bring back cursors if you accidentally clear them
      set("n", "<leader>mgv", mc.restoreCursors, { desc = "restoreCursors" })

      -- Align cursor columns.
      set("n", "<leader>ma", mc.alignCursors, { desc = "alignCursors" })

      -- Split visual selections by regex.
      set("x", "S", mc.splitCursors)

      -- Append/insert for each line of visual selections.
      set("x", "I", mc.insertVisual)
      set("x", "A", mc.appendVisual)

      -- match new cursors within visual selections by regex.
      set("x", "M", mc.matchCursors)

      -- Rotate visual selection contents.
      set("x", "<leader>mt", function()
        mc.transposeCursors(1)
      end, { desc = "transposeCursors" })
      set("x", "<leader>mT", function()
        mc.transposeCursors(-1)
      end, { desc = "transposeCursors" })

      -- Jumplist support
      set({ "x", "n" }, "<c-i>", mc.jumpForward)
      set({ "x", "n" }, "<c-o>", mc.jumpBackward)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      -- Use a different highlight group than Search to avoid performance issues
      hl(0, "MultiCursorMatchPreview", { bg = "#3b4261", fg = "#abb2bf" })
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>mm",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
  },
}
