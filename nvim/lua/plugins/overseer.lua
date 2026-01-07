return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerSaveBundle",
    "OverseerLoadBundle",
    "OverseerDeleteBundle",
    "OverseerRunCmd",
    "OverseerRun",
    "OverseerInfo",
    "OverseerBuild",
    "OverseerQuickAction",
    "OverseerTaskAction",
    "OverseerClearCache",
  },
  opts = {
    templates = { "builtin", "user.yarn", "user.bun" },
    dap = false,
    task_list = {
      bindings = {
        ["<C-h>"] = false,
        ["<C-j>"] = false,
        ["<C-k>"] = false,
        ["<C-l>"] = false,
      },
    },
    form = {
      win_opts = {
        winblend = 0,
      },
    },
    confirm = {
      win_opts = {
        winblend = 0,
      },
    },
    task_win = {
      win_opts = {
        winblend = 0,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>ow", "<cmd>OverseerToggle<cr>",      desc = "Task list" },
    { "<leader>or", "<cmd>OverseerRun<cr>",         desc = "Run task" },
    { "<leader>oo", "<cmd>OverseerToggle<cr>",      desc = "Overseer Toggle" },
    { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
    { "<leader>oi", "<cmd>OverseerInfo<cr>",        desc = "Overseer Info" },
    { "<leader>ob", "<cmd>OverseerBuild<cr>",       desc = "Task builder" },
    { "<leader>ot", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },
    { "<leader>oC", "<cmd>OverseerClearCache<cr>",  desc = "Clear cache" },
    { "<leader>od", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "stop")
      end
    end, desc = "Stop recent task" },
    { "<leader>oD", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({ status = "RUNNING" })
      if vim.tbl_isempty(tasks) then
        vim.notify("No running tasks", vim.log.levels.WARN)
      else
        for _, task in ipairs(tasks) do
          task:stop()
        end
        vim.notify(string.format("Stopped %d task(s)", #tasks), vim.log.levels.INFO)
      end
    end, desc = "Stop all tasks" },
  },
}
