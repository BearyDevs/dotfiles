return {
  "vyfor/cord.nvim",
  build = ":Cord update",
  event = "VeryLazy",
  enabled = false,
  -- Only load if Discord is running
  cond = function()
    -- Check if Discord process is running
    local handle = io.popen("pgrep -x Discord 2>/dev/null")
    if handle then
      local result = handle:read("*a")
      handle:close()
      return result ~= ""
    end
    return false
  end,
  opts = {
    usercmds = true, -- Enable user commands
    log_level = "error", -- One of 'trace', 'debug', 'info', 'warn', 'error', 'off'
    timer = {
      interval = 1500, -- Interval between presence updates in milliseconds (min 500)
      reset_on_idle = false, -- Reset start timestamp on idle
      reset_on_change = false, -- Reset start timestamp on presence change
    },
    editor = {
      -- image = nil, -- Image ID or URL in case a custom client id is provided
      client = "neovim", -- vim, neovim, lunarvim, nvchad, astronvim or your application's client id
      -- tooltip = "VSCode Suck!", -- Text to display when hovering over the editor's image
      tooltip = "Ultimate Superior Editor",
    },
    display = {
      show_time = true, -- Display start timestamp
      show_repository = true, -- Display 'View repository' button linked to repository url, if any
      show_cursor_position = true, -- Display line and column number of cursor's position
      -- swap_fields = false, -- If enabled, workspace is displayed first
      -- swap_icons = false, -- If enabled, editor is displayed on the main image
      swap_fields = true, -- If enabled, workspace is displayed first
      swap_icons = true, -- If enabled, editor is displayed on the main image
      workspace_blacklist = {}, -- List of workspace names that will hide rich presence
    },
    lsp = {
      -- show_problem_count = false, -- Display number of diagnostics problems
      show_problem_count = true, -- Display number of diagnostics problems
      severity = 1, -- 1 = Error, 2 = Warning, 3 = Info, 4 = Hint
      scope = "workspace", -- buffer or workspace
    },
    idle = {
      enable = false, -- Enable idle status
      show_status = false, -- Display idle status, disable to hide the rich presence on idle
      timeout = 300000, -- Timeout in milliseconds after which the idle status is set, 0 to display immediately
      disable_on_focus = false, -- Do not display idle status when neovim is focused
      text = "Idle", -- Text to display when idle
      tooltip = "💤", -- Text to display when hovering over the idle image
    },
    -- ╭─────────────────────────────────────────────────────────╮
    -- │ Manual config to display the current file being edited  │
    -- ╰─────────────────────────────────────────────────────────╯
    text = {
      --          ╭─────────────────────────────────────────────────────────╮
      --          │      Alternative: 3 Steps path + line info format       │
      --          ╰─────────────────────────────────────────────────────────╯
      editing = function()
        local full_path = vim.fn.expand("%:p")
        local path_parts = vim.split(full_path, "/")
        -- local line_num = vim.fn.line(".")
        -- local total_lines = vim.fn.line("$")

        local path_display = ""
        -- Show 3 levels: grandparent/parent/filename
        if #path_parts >= 3 then
          path_display =
            string.format("%s/%s/%s", path_parts[#path_parts - 2], path_parts[#path_parts - 1], path_parts[#path_parts])
        elseif #path_parts >= 2 then
          path_display = string.format("%s/%s", path_parts[#path_parts - 1], path_parts[#path_parts])
        else
          path_display = vim.fn.expand("%:t")
        end

        -- return string.format("✏️  Editing: %s - Line: %d of %d", path_display, line_num, total_lines)
        return string.format("Editing - %s", path_display)
      end,

      viewing = function()
        local full_path = vim.fn.expand("%:p")
        local path_parts = vim.split(full_path, "/")
        -- local line_num = vim.fn.line(".")
        -- local total_lines = vim.fn.line("$")

        local path_display = ""
        -- Show 3 levels: grandparent/parent/filename
        if #path_parts >= 3 then
          path_display =
            string.format("%s/%s/%s", path_parts[#path_parts - 2], path_parts[#path_parts - 1], path_parts[#path_parts])
        elseif #path_parts >= 2 then
          path_display = string.format("%s/%s", path_parts[#path_parts - 1], path_parts[#path_parts])
        else
          path_display = vim.fn.expand("%:t")
        end

        -- return string.format("Viewing %s\nLine %d of %d", path_display, line_num, total_lines)
        return string.format("Viewing %s", path_display)
      end,
    },
    buttons = {
      {
        label = "Motivated", -- Text displayed on the button
        url = "https://youtu.be/Yfu6G3f8Xxc?si=YKOHEK6WAwVAmug7", -- URL where the button leads to ('git' = automatically fetch Git repository URL)
      },
    },
    status_format = "Work %s", -- Hypothetical example
  },
}
