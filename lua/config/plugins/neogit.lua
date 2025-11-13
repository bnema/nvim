-- Neogit configuration
-- Interactive Git interface for Neovim, inspired by Magit
-- Documentation: https://github.com/NeogitOrg/neogit

local neogit = require('neogit')

neogit.setup({
  -- Hides the hints at the top of the status buffer
  disable_hint = false,

  -- Disables changing the buffer highlights based on where the cursor is
  disable_context_highlighting = false,

  -- Disables signs for sections/items/hunks
  disable_signs = false,

  -- Changes what mode the Commit Editor starts in
  disable_insert_on_commit = true,

  -- When enabled, will watch the .git/ directory for changes and refresh the status buffer
  filewatcher = {
    interval = 1000,
    enabled = true,
  },

  -- Allows a different telescope sorter
  telescope_sorter = function()
    return require("telescope").extensions.fzf.native_fzf_sorter()
  end,

  -- Used to generate URL's for branch popup action "pull request"
  git_services = {
    ["github.com"] = {
      pull_request = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
      commit = "https://github.com/${owner}/${repository}/commit/${commit_hash}",
      tree = "https://github.com/${owner}/${repository}/tree/${branch_name}",
    },
    ["gitlab.com"] = {
      pull_request = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
      commit = "https://gitlab.com/${owner}/${repository}/commit/${commit_hash}",
      tree = "https://gitlab.com/${owner}/${repository}/tree/${branch_name}",
    },
    ["bitbucket.org"] = {
      pull_request = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
      commit = "https://bitbucket.org/${owner}/${repository}/commits/${commit_hash}",
      tree = "https://bitbucket.org/${owner}/${repository}/src/${branch_name}",
    },
  },

  -- Set to false if you want to be responsible for creating _ALL_ keybindings
  use_default_keymaps = true,

  -- Neogit refreshes its internal state after specific events
  auto_refresh = true,

  -- Value used for `--sort` option for `git branch` command
  sort_branches = "-committerdate",

  -- Change the default way of opening neogit
  kind = "tab",

  -- Disable line numbers and relative line numbers
  disable_line_numbers = true,

  -- The time after which an output console is shown for slow running commands
  console_timeout = 2000,

  -- Automatically show console if a command takes more than console_timeout milliseconds
  auto_show_console = true,

  -- Persist the values of switches/options within and across sessions
  remember_settings = true,

  -- Scope persisted settings on a per-project basis
  use_per_project_settings = true,

  -- Array-like table of settings to never persist
  ignored_settings = {},

  -- Enable highlighting for specific patterns
  highlight = {
    italic = true,
    bold = true,
    underline = true,
  },

  -- Set to false if you want to use your own git.credentials_callback
  use_default_git_credentials = true,

  -- Change default commit popup options
  commit_popup = {
    kind = "split",
  },

  -- Change default preview buffer kind
  preview_buffer = {
    kind = "split",
  },

  -- Change default popup kind
  popup = {
    kind = "split",
  },

  -- Customize displayed signs
  signs = {
    -- { CLOSED, OPENED }
    hunk = { "", "" },
    item = { ">", "v" },
    section = { ">", "v" },
  },

  -- Each Integration is auto-detected through plugin presence
  -- Set to `false` to disable
  integrations = {
    telescope = nil,
    diffview = true,
    fzf_lua = nil,
  },

  sections = {
    -- Reverting/Cherry Picking
    sequencer = {
      folded = false,
      hidden = false,
    },
    untracked = {
      folded = false,
      hidden = false,
    },
    unstaged = {
      folded = false,
      hidden = false,
    },
    staged = {
      folded = false,
      hidden = false,
    },
    stashes = {
      folded = true,
      hidden = false,
    },
    unpulled_upstream = {
      folded = true,
      hidden = false,
    },
    unmerged_upstream = {
      folded = false,
      hidden = false,
    },
    unpulled_pushRemote = {
      folded = true,
      hidden = false,
    },
    unmerged_pushRemote = {
      folded = false,
      hidden = false,
    },
    recent = {
      folded = true,
      hidden = false,
    },
    rebase = {
      folded = true,
      hidden = false,
    },
  },

  mappings = {
    commit_editor = {
      ["q"] = "Close",
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
    },
    rebase_editor = {
      ["p"] = "Pick",
      ["r"] = "Reword",
      ["e"] = "Edit",
      ["s"] = "Squash",
      ["f"] = "Fixup",
      ["x"] = "Execute",
      ["d"] = "Drop",
      ["b"] = "Break",
      ["q"] = "Close",
      ["<cr>"] = "OpenCommit",
      ["gk"] = "MoveUp",
      ["gj"] = "MoveDown",
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
    },
    finder = {
      ["<cr>"] = "Select",
      ["<c-c>"] = "Close",
      ["<esc>"] = "Close",
      ["<c-n>"] = "Next",
      ["<c-p>"] = "Previous",
      ["<down>"] = "Next",
      ["<up>"] = "Previous",
      ["<tab>"] = "MultiselectToggleNext",
      ["<s-tab>"] = "MultiselectTogglePrevious",
      ["<c-j>"] = "NOP",
    },
    popup = {
      ["?"] = "HelpPopup",
      ["A"] = "CherryPickPopup",
      ["D"] = "DiffPopup",
      ["M"] = "RemotePopup",
      ["P"] = "PushPopup",
      ["X"] = "ResetPopup",
      ["Z"] = "StashPopup",
      ["b"] = "BranchPopup",
      ["c"] = "CommitPopup",
      ["f"] = "FetchPopup",
      ["l"] = "LogPopup",
      ["m"] = "MergePopup",
      ["p"] = "PullPopup",
      ["r"] = "RebasePopup",
      ["v"] = "RevertPopup",
      ["w"] = "WorktreePopup",
    },
    status = {
      ["q"] = "Close",
      ["I"] = "InitRepo",
      ["1"] = "Depth1",
      ["2"] = "Depth2",
      ["3"] = "Depth3",
      ["4"] = "Depth4",
      ["<tab>"] = "Toggle",
      ["x"] = "Discard",
      ["s"] = "Stage",
      ["S"] = "StageUnstaged",
      ["<c-s>"] = "StageAll",
      ["u"] = "Unstage",
      ["U"] = "UnstageStaged",
      ["$"] = "CommandHistory",
      ["Y"] = "YankSelected",
      ["<c-r>"] = "RefreshBuffer",
      ["<enter>"] = "GoToFile",
      ["<c-v>"] = "VSplitOpen",
      ["<c-x>"] = "SplitOpen",
      ["<c-t>"] = "TabOpen",
      ["{"] = "GoToPreviousHunkHeader",
      ["}"] = "GoToNextHunkHeader",
      ["[c"] = "OpenOrScrollUp",
      ["]c"] = "OpenOrScrollDown",
    },
  },
})

-- Auto-enable diff overlay when opening files from Neogit
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NeogitStatus",
  callback = function()
    -- Set up autocmd to enable diff overlay when leaving neogit
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function(args)
        -- Only trigger for regular file buffers (not special buffers)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })

        if buftype == "" and filetype ~= "NeogitStatus" and filetype ~= "NeogitCommitMessage" then
          vim.schedule(function()
            local MiniDiff = require('mini.diff')
            -- Enable mini.diff if not already enabled
            MiniDiff.enable(args.buf)
            -- Show overlay if not already shown
            local buf_data = MiniDiff.get_buf_data(args.buf)
            if buf_data and not buf_data.overlay then
              MiniDiff.toggle_overlay(args.buf)
            end
          end)
        end
      end,
    })
  end,
})
