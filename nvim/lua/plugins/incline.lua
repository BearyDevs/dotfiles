-- ╭─────────────────────────────────────────────────────────╮
-- │ Show current filename at righttop                       │
-- ╰─────────────────────────────────────────────────────────╯
return {
  "b0o/incline.nvim",
  dependencies = { "craftzdog/solarized-osaka.nvim" },
  event = "BufReadPre",
  priority = 1200,
  config = function()
    local colors = require("solarized-osaka.colors").setup()

    -- Global toggle variable
    if _G.InclineShowFullPath == nil then
      _G.InclineShowFullPath = false
    end

    -- Function to count buffers with the same filename
    local function count_buffers_with_filename(target_name)
      local count = 0
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
          if name == target_name then
            count = count + 1
          end
        end
      end
      return count
    end

    require("incline").setup({
      highlight = {
        groups = {
          InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
          InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
        },
      },
      window = { margin = { vertical = 0, horizontal = 1 } },
      hide = { cursorline = true },
      render = function(props)
        local full_path = vim.api.nvim_buf_get_name(props.buf)
        local filename = vim.fn.fnamemodify(full_path, ":t")
        local parent = vim.fn.fnamemodify(full_path, ":h:t")
        local grandparent = vim.fn.fnamemodify(full_path, ":h:h:t")

        -- Toggle between full path and short path
        if _G.InclineShowFullPath then
          filename = full_path
        else
          local buffer_count = count_buffers_with_filename(filename)

          -- Show "parent/filename" if duplicate names exist
          if buffer_count > 1 then
            filename = parent .. "/" .. filename
          end

          -- Show "grandparent/parent/filename" if deeply nested
          if parent ~= "" and grandparent ~= "" then
            filename = grandparent .. "/" .. parent .. "/" .. filename
          end
        end

        if vim.bo[props.buf].modified then
          filename = "[+] " .. filename
        end

        local icon, color = require("nvim-web-devicons").get_icon_color(filename)
        return { { icon, guifg = color }, { " " }, { filename } }
      end,
    })

    -- Keymap to toggle between short path and full path
    vim.keymap.set("n", "<leader>i", function()
      _G.InclineShowFullPath = not _G.InclineShowFullPath
      vim.cmd("redrawstatus") -- Refresh UI
    end, { desc = "Toggle Incline full-path and short-path" })
  end,
}
