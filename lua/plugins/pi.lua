-- pi-nvim-bridge - Automatic context bridge between pi coding agent and Neovim
return {
  {
    "bnema/pi-nvim-bridge",
    event = { "BufReadPost", "BufNewFile" },
    cmd = {
      "PiNvimBridgeSync",
      "PiNvimBridgePrompt",
      "PiNvimBridgeSteer",
      "PiNvimBridgeFollowUp",
      "PiNvimBridgePing",
      "PiNvimBridgeSessions",
    },
    keys = {
      { "<leader>p",  "<cmd>PiNvimBridgePrompt<CR>",   mode = { "n", "v" }, desc = "Pi: prompt with editor context" },
      { "<leader>pp", "<cmd>PiNvimBridgePrompt<CR>",   mode = { "n", "v" }, desc = "Pi: prompt" },
      { "<leader>ps", "<cmd>PiNvimBridgeSteer<CR>",    mode = { "n", "v" }, desc = "Pi: steer" },
      { "<leader>pf", "<cmd>PiNvimBridgeFollowUp<CR>", mode = { "n", "v" }, desc = "Pi: follow-up" },
      { "<leader>pc", "<cmd>PiNvimBridgeSync<CR>",     mode = { "n", "v" }, desc = "Pi: sync editor context" },
      { "<leader>pi", "<cmd>PiNvimBridgePing<CR>",     desc = "Pi: ping bridge" },
      { "<leader>pS", "<cmd>PiNvimBridgeSessions<CR>", desc = "Pi: select session" },
    },
    config = function()
      require("pi-nvim-bridge").setup({
        default_streaming_behavior = "steer",
        default_keymaps = false,
      })
    end,
  },
}
