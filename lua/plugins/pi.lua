-- pi-nvim - Bridge between pi coding agent and Neovim
-- Run pi in one terminal, Neovim in another — send context from editor
return {
  {
    "carderne/pi-nvim",
    cmd = { "Pi", "PiSend", "PiSendFile", "PiSendSelection", "PiSendBuffer", "PiPing", "PiSessions" },
    keys = {
      { "<leader>a",  "<cmd>Pi<CR>",              mode = { "n", "v" }, desc = "Pi: send to pi" },
      { "<leader>ap", "<cmd>PiSend<CR>",          desc = "Pi: prompt" },
      { "<leader>af", "<cmd>PiSendFile<CR>",      desc = "Pi: file + prompt" },
      { "<leader>as", "<cmd>PiSendSelection<CR>", mode = "v", desc = "Pi: selection + prompt" },
      { "<leader>ab", "<cmd>PiSendBuffer<CR>",    desc = "Pi: buffer + prompt" },
    },
    config = function()
      require("pi-nvim").setup()
    end,
  },
}
