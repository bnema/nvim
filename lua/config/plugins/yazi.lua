-- Yazi.nvim - Terminal file manager integration
-- https://github.com/mikavilpas/yazi.nvim

---@type YaziConfig
return {
  -- Enable this to open yazi instead of netrw when opening directories
  open_for_directories = true,

  -- Open visible splits and quickfix items as yazi tabs for easy navigation
  open_multiple_tabs = false,

  -- When yazi is closed with no file chosen, change the Neovim working
  -- directory to the directory that yazi was in before it was closed
  change_neovim_cwd_on_close = false,

  highlight_groups = {
    hovered_buffer = nil,
    hovered_buffer_in_same_directory = nil,
  },

  -- The floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
  floating_window_scaling_factor = 1.0,

  -- The transparency of the yazi floating window (0-100). See :h winblend
  yazi_floating_window_winblend = 0,

  -- The type of border to use for the floating window.
  -- Options: 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
  yazi_floating_window_border = "none",

  -- The zindex of the yazi floating window. Can be used to make yazi fullscreen
  yazi_floating_window_zindex = nil,

  -- The log level to use. Off by default, can be used to diagnose issues.
  -- Find log location with `:checkhealth yazi`
  log_level = vim.log.levels.OFF,

  -- What Neovim should do when a file was opened (selected) in yazi
  -- Remove this option to use the default implementation which opens the file
  -- open_file_function = function(chosen_file, config, state)
  --   -- Custom implementation if needed
  -- end,

  -- Customize keymaps that are active when yazi is open and focused
  -- Note: these hijack input and are never sent to yazi
  keymaps = {
    show_help = "<f1>",
    open_file_in_vertical_split = "<c-v>",
    open_file_in_horizontal_split = "<c-x>",
    open_file_in_tab = "<c-t>",
    grep_in_directory = "<c-s>",
    replace_in_directory = "<c-g>",
    cycle_open_buffers = "<tab>",
    copy_relative_path_to_selected_files = "<c-y>",
    send_to_quickfix_list = "<c-q>",
    change_working_directory = "<c-\\>",
    open_and_pick_window = "<c-o>",
  },

  -- Completely override the keymappings for yazi (optional)
  -- This function will be called in the context of the yazi terminal buffer
  -- set_keymappings_function = function(yazi_buffer_id, config, context)
  --   -- Custom keymappings can be defined here
  -- end,

  -- Clipboard register for yazi.nvim commands that copy text
  -- Defaults to "*", the system clipboard
  clipboard_register = "*",

  hooks = {
    -- Called when yazi has been opened (optional)
    -- yazi_opened = function(preselected_path, yazi_buffer_id, config)
    --   -- You can optionally modify the config for this specific yazi invocation
    -- end,

    -- Called when yazi was successfully closed (optional)
    -- yazi_closed_successfully = function(chosen_file, config, state)
    -- end,

    -- Called when yazi opened multiple files (optional)
    -- Default is to send them to the quickfix list
    -- yazi_opened_multiple_files = function(chosen_files, config, state)
    -- end,

    -- Called when yazi is ready to process events (optional)
    -- on_yazi_ready = function(buffer, config, process_api)
    -- end,
  },

  -- Highlight buffers in the same directory as the hovered buffer
  highlight_hovered_buffers_in_same_directory = true,

  integrations = {
    -- What should be done when the user wants to grep in a directory
    grep_in_directory = function(directory)
      -- Default uses telescope if available
      -- Integration with mini.pick
      local ok, mini_pick = pcall(require, 'mini.pick')
      if ok then
        mini_pick.builtin.grep_live({ tool = 'git' }, { source = { cwd = directory } })
      end
    end,

    grep_in_selected_files = function(selected_files)
      -- Similar to grep_in_directory, but for selected files
    end,

    -- Search and replace in the files in the directory (optional)
    -- replace_in_directory = function(directory)
    --   -- Default: grug-far.nvim
    -- end,

    -- replace_in_selected_files = function(selected_files)
    --   -- Default: grug-far.nvim
    -- end,

    -- `grealpath` on OSX, (GNU) `realpath` otherwise
    resolve_relative_path_application = "",

    -- The way to resolve relative paths (optional)
    -- resolve_relative_path_implementation = function(args, get_relative_path)
    -- end,

    -- How to delete (close) a buffer
    -- Options: "bundled-snacks" (default) maintains window layout
    bufdelete_implementation = "bundled-snacks",

    -- Add an action to a file picker to copy the relative path
    -- Options: nil (default), "snacks.picker"
    picker_add_copy_relative_path_action = nil,
  },

  future_features = {
    -- Use a file to store the last directory yazi was in before closing
    use_cwd_file = true,

    -- Use new shell escaping implementation (more robust, works on more platforms)
    new_shell_escaping = true,
  },
}
