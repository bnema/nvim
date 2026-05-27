-- AI integrations: Sidekick NES and AI CLI terminal

local ai_model = vim.env.NVIM_AI_MODEL or "gpt-5.4-mini"
local ai_reasoning_effort = vim.env.NVIM_AI_REASONING_EFFORT or "medium"

return {
  {
    "folke/sidekick.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "folke/snacks.nvim",
    },
    opts = {
      nes = {
        -- Keep automatic Next Edit Suggestions quick while avoiding noisy requests
        -- on every insert-mode keystroke. Sidekick defaults trigger after leaving
        -- insert mode, normal-mode edits, and after applying a suggestion.
        debounce = 100,
        diff = {
          inline = "words",
          show = "cursor",
        },
      },
      cli = {
        picker = "snacks",
        watch = true,
        win = {
          layout = "left",
          split = {
            width = 80,
          },
        },
        mux = {
          enabled = true,
          backend = vim.env.ZELLIJ and "zellij" or "tmux",
          create = "terminal",
        },
        tools = {
          codex = {
            cmd = {
              "codex",
              "--model",
              ai_model,
              "-c",
              ('model_reasoning_effort="%s"'):format(ai_reasoning_effort),
            },
          },
          copilot = {
            cmd = {
              "copilot",
              "--banner",
              "--model",
              ai_model,
              "--effort",
              ai_reasoning_effort,
            },
          },
        },
      },
    },
    keys = {
      {
        "<Tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        mode = "n",
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        desc = "Sidekick Focus",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select({ filter = { installed = true } })
        end,
        desc = "Sidekick Select CLI",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Sidekick Detach CLI",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "codex", focus = true })
        end,
        desc = "Sidekick Toggle Codex",
      },
      {
        "<leader>aC",
        function()
          require("sidekick.cli").toggle({ name = "copilot", focus = true })
        end,
        desc = "Sidekick Toggle Copilot CLI",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").toggle({ name = "pi", focus = true })
        end,
        desc = "Sidekick Toggle Pi",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Sidekick Send This",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Sidekick Send File",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = "x",
        desc = "Sidekick Send Selection",
      },
      {
        "<leader>aP",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
