return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true },
        panel = { enabled = true },
      })
    end,
  },
  {
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
      -- { "<leader>gcm", "<cmd>CopilotChat /Commit<cr>", desc = "Generate Commit Message" },
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
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      prompts = {
        CommitStaged = {
          prompt = "Analyze the staged changes and write a commit message following commitizen convention. Title must be maximum 50 characters. Message body must be wrapped at 72 characters. For large changesets: (1) Focus on WHY the changes were made, not WHAT was changed. (2) Summarize the primary goal and impact. (3) Group related changes into logical sections. (4) Omit trivial details unless critical. Wrap the whole message in code block with language gitcommit.",
          system_prompt = "You are an expert Software Engineer who writes clear, purposeful git commit messages following conventional commits. Focus on the intent and impact of changes, not implementation details.",
        },
      },
    },
    keys = {
      { "<leader>gcm", "<cmd>CopilotChatCommitStaged<cr>", desc = "Generate commit message" },
    },
  },
}
