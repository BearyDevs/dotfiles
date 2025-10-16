return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  cmd = {
    "CopilotChat",
    "CopilotChatOpen",
    "CopilotChatToggle",
    "CopilotChatCommit",
  },
  keys = {
    { "<leader>gcc", "<cmd>CopilotChat<cr>", desc = "CopilotChat" },
    { "<leader>gct", "<cmd>CopilotChatToggle<cr>", desc = "Toggle CopilotChat" },
    { "<leader>gcm", "<cmd>CopilotChat /Commit<cr>", desc = "Generate Commit Message" },
    { "<leader>gce", "<cmd>CopilotChat /Explain<cr>", mode = { "n", "v" }, desc = "Explain Code" },
    { "<leader>gcr", "<cmd>CopilotChat /Review<cr>", mode = { "n", "v" }, desc = "Review Code" },
    { "<leader>gcf", "<cmd>CopilotChat /Fix<cr>", mode = { "n", "v" }, desc = "Fix Code" },
    { "<leader>gco", "<cmd>CopilotChat /Optimize<cr>", mode = { "n", "v" }, desc = "Optimize Code" },
    { "<leader>gcd", "<cmd>CopilotChat /Docs<cr>", mode = { "n", "v" }, desc = "Add Documentation" },
    { "<leader>gcs", "<cmd>CopilotChatStop<cr>", desc = "Stop CopilotChat" },
  },
  opts = {
    model = "gpt-4o",
    temperature = 0.1,
    window = {
      layout = "vertical",
      width = 0.4,
    },
    auto_insert_mode = true,
  },
}
