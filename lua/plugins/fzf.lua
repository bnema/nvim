-- fzf-lua - Fuzzy finder with viewport-aware preview windows
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  init = function()
    -- If started as `nvim .`, open the files picker immediately
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        if vim.fn.argc() ~= 1 then return end
        local target = vim.fn.argv(0)
        if not target or vim.fn.isdirectory(target) == 0 then return end

        local cwd = vim.fn.fnamemodify(target, ":p")
        vim.schedule(function()
          local lazy = require("lazy")
          lazy.load({ plugins = { "fzf-lua" } })
          local ok, fzf = pcall(require, "fzf-lua")
          if not ok then return end

          pcall(vim.fn.chdir, cwd)
          local git_status = vim.fn.system({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" })
          local use_git = vim.v.shell_error == 0 and git_status:match("true")

          if use_git and fzf.git_files then
            fzf.git_files({ cwd = cwd })
          else
            fzf.files({ cwd = cwd })
          end
        end)
      end,
    })
  end,
  keys = {
    -- File finding (leader + f)
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
    { "<leader>ft", "<cmd>FzfLua treesitter<cr>", desc = "Treesitter symbols" },
    { "<leader>fl", "<cmd>FzfLua blines<cr>", desc = "Buffer lines" },
    { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    { "<leader>fH", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
    { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },

    -- Search (leader + s)
    { "<leader>ss", "<cmd>FzfLua live_grep<cr>", desc = "Search in files (grep live)" },
    { "<leader>sf", "<cmd>FzfLua grep<cr>", desc = "Search pattern in files" },
    { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Search word under cursor" },
    { "<leader>sW", "<cmd>FzfLua grep_cWORD<cr>", desc = "Search WORD under cursor" },

    -- LSP (leader + l)
    { "<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    { "<leader>ld", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },

    -- Diagnostics (leader + d) - additional bindings
    { "<leader>db", "<cmd>FzfLua diagnostics_document<cr>", desc = "Buffer diagnostics" },
    { "<leader>dB", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },

    -- Git (leader + g)
    { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
    { "<leader>gB", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
  },
  opts = {
    -- Global options
    global_resume = true,
    global_resume_query = true,

    -- Window options
    winopts = {
      height = 0.85,
      width = 0.80,
      row = 0.35,
      col = 0.50,
      border = "single",     -- Clean single-line border
      backdrop = 60,         -- Semi-transparent backdrop

      -- Preview configuration with viewport-aware layout
      preview = {
        border = "single",         -- Preview border
        wrap = false,
        hidden = false,
        -- Viewport-aware layout
        layout = "flex",           -- auto-switch based on viewport
        flip_columns = 100,        -- switch to vertical when width < 100 columns
        horizontal = "right:55%",  -- preview on right (reduced to create gap)
        vertical = "down:40%",     -- preview on bottom when narrow
        -- Builtin previewer options
        title = true,
        title_pos = "center",
        scrollbar = "float",
        scrolloff = -1,
        delay = 20,
        winopts = {
          number = true,
          relativenumber = false,
          cursorline = true,
          cursorlineopt = "both",
          cursorcolumn = false,
          signcolumn = "no",
          list = false,
          foldenable = false,
          foldmethod = "manual",
        },
      },
    },

    -- Keymap customization
    keymap = {
      builtin = {
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
      },
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },

    -- File options
    files = {
      prompt = "Files> ",
      cwd_prompt = false,
      git_icons = true,
      file_icons = true,
      color_icons = true,
    },

    -- Grep options
    grep = {
      prompt = "Rg> ",
      input_prompt = "Search> ",
      git_icons = false,
      file_icons = false,      -- keep output tighter: path:line:col message
      color_icons = false,
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --max-columns=4096 --glob !.git/* -e",
      winopts = {
        preview = {
          layout = "vertical",
          vertical = "down:70%", -- give more height to the preview for context
        },
      },
    },

    -- Buffer options
    buffers = {
      prompt = "Buffers> ",
      file_icons = true,
      color_icons = true,
      sort_lastused = true,
    },

    -- LSP options
    lsp = {
      prompt_postfix = "> ",
      cwd_only = false,
      async_or_timeout = 5000,
      file_icons = true,
      git_icons = false,
      symbols = {
        prompt = "Symbols> ",
        symbol_style = 1,
      },
    },

    -- Diagnostics options
    diagnostics = {
      prompt = "Diagnostics> ",
      cwd_only = false,
      file_icons = false,      -- keep list compact; path + line is enough
      git_icons = false,
      color_headings = true,   -- severity headings colored
      diag_icons = true,       -- show severity icons
      diag_source = true,      -- show source (LSP/linters)
      diag_code = true,        -- show diagnostic code if available
      icon_padding = " ",
      multiline = 2,           -- show message on new line for readability
    },
  },
}
