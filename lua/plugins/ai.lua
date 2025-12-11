-- AI assistants and Claude Summon
return {
  {
    "bnema/claude-summon.nvim",
    dependencies = {
      "bnema/claude-agent-sdk-lua",
    },
    event = "VeryLazy",
    config = function()
      require("claude-summon").setup({})
    end,
  },
}
