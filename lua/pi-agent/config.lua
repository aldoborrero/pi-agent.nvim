---@mod pi-agent.config Configuration management for pi-agent.nvim
---@brief [[
--- This module handles configuration management and validation for pi-agent.nvim.
--- It provides the default configuration, validation, and merging of user config.
---@brief ]]

local M = {}

--- PiAgentWindow class for window configuration
-- @table PiAgentWindow
-- @field split_ratio number Percentage of screen for the terminal window (height for horizontal, width for vertical)
-- @field position string Position of the window: "botright", "topleft", "vertical", "float" etc.
-- @field enter_insert boolean Whether to enter insert mode when opening Pi Agent
-- @field start_in_normal_mode boolean Whether to start in normal mode instead of insert mode when opening Pi Agent
-- @field hide_numbers boolean Hide line numbers in the terminal window
-- @field hide_signcolumn boolean Hide the sign column in the terminal window
-- @field float table|nil Floating window configuration (only used when position is "float")
-- @field float.width number|string Width of floating window (number: columns, string: percentage like "80%")
-- @field float.height number|string Height of floating window (number: rows, string: percentage like "80%")
-- @field float.row number|string|nil Row position (number: absolute, string: "center" or percentage)
-- @field float.col number|string|nil Column position (number: absolute, string: "center" or percentage)
-- @field float.border string Border style: "none", "single", "double", "rounded", "solid", "shadow", or array
-- @field float.relative string Relative positioning: "editor" or "cursor"

--- PiAgentRefresh class for file refresh configuration
-- @table PiAgentRefresh
-- @field enable boolean Enable file change detection
-- @field updatetime number updatetime when Pi Agent is active (milliseconds)
-- @field timer_interval number How often to check for file changes (milliseconds)
-- @field show_notifications boolean Show notification when files are reloaded

--- PiAgentGit class for git integration configuration
-- @table PiAgentGit
-- @field use_git_root boolean Set CWD to git root when opening Pi Agent (if in git project)
-- @field multi_instance boolean Use multiple Pi Agent instances (one per git root)

--- PiAgentKeymapsToggle class for toggle keymap configuration
-- @table PiAgentKeymapsToggle
-- @field normal string|boolean Normal mode keymap for toggling Pi Agent, false to disable
-- @field terminal string|boolean Terminal mode keymap for toggling Pi Agent, false to disable

--- PiAgentKeymaps class for keymap configuration
-- @table PiAgentKeymaps
-- @field toggle PiAgentKeymapsToggle Keymaps for toggling Pi Agent
-- @field window_navigation boolean Enable window navigation keymaps
-- @field scrolling boolean Enable scrolling keymaps

--- PiAgentCommandVariants class for command variant configuration
-- @table PiAgentCommandVariants
-- Conversation management:
-- @field continue string|boolean Resume the most recent conversation
-- @field resume string|boolean Display an interactive conversation picker
-- Output options:
-- @field verbose string|boolean Enable verbose logging with full turn-by-turn output
-- Additional options can be added as needed

--- PiAgentConfig class for main configuration
-- @table PiAgentConfig
-- @field window PiAgentWindow Terminal window settings
-- @field refresh PiAgentRefresh File refresh settings
-- @field git PiAgentGit Git integration settings
-- @field command string Command used to launch Pi Agent
-- @field command_variants PiAgentCommandVariants Command variants configuration
-- @field keymaps PiAgentKeymaps Keymaps configuration

--- Default configuration options
--- @type PiAgentConfig
M.default_config = {
  -- Terminal window settings
  window = {
    split_ratio = 0.3, -- Percentage of screen for the terminal window (height or width)
    position = 'botright', -- Position of the window: "botright", "topleft", "vertical", "float", etc.
    enter_insert = true, -- Whether to enter insert mode when opening Pi Agent
    start_in_normal_mode = false, -- Whether to start in normal mode instead of insert mode
    hide_numbers = true, -- Hide line numbers in the terminal window
    hide_signcolumn = true, -- Hide the sign column in the terminal window
    -- Default floating window configuration
    float = {
      width = '80%', -- Width as percentage of editor
      height = '80%', -- Height as percentage of editor
      row = 'center', -- Center vertically
      col = 'center', -- Center horizontally
      relative = 'editor', -- Position relative to editor
      border = 'rounded', -- Border style
    },
  },
  -- File refresh settings
  refresh = {
    enable = true, -- Enable file change detection
    updatetime = 100, -- updatetime to use when Pi Agent is active (milliseconds)
    timer_interval = 1000, -- How often to check for file changes (milliseconds)
    show_notifications = true, -- Show notification when files are reloaded
  },
  -- Git integration settings
  git = {
    use_git_root = true, -- Set CWD to git root when opening Pi Agent (if in git project)
    multi_instance = true, -- Use multiple Pi Agent instances (one per git root)
  },
  -- Command settings
  command = 'pi', -- Command used to launch Pi Agent
  -- Command variants
  command_variants = {
    -- Conversation management
    continue = '--continue', -- Resume the most recent conversation
    resume = '--resume', -- Display an interactive conversation picker

    -- Output options
    verbose = '--verbose', -- Enable verbose logging with full turn-by-turn output
  },
  -- Keymaps
  keymaps = {
    toggle = {
      normal = '<C-,>', -- Normal mode keymap for toggling Pi Agent
      terminal = '<C-,>', -- Terminal mode keymap for toggling Pi Agent
      variants = {
        continue = '<leader>cC', -- Normal mode keymap for Pi Agent with continue flag
        verbose = '<leader>cV', -- Normal mode keymap for Pi Agent with verbose flag
      },
    },
    window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
    scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
  },
}

--- Validate the configuration
--- Validate window configuration
--- @param window table Window configuration
--- @return boolean valid
--- @return string? error_message
local function validate_window_config(window)
  if type(window) ~= 'table' then
    return false, 'window config must be a table'
  end

  if type(window.split_ratio) ~= 'number' or window.split_ratio <= 0 or window.split_ratio > 1 then
    return false, 'window.split_ratio must be a number between 0 and 1'
  end

  if type(window.position) ~= 'string' then
    return false, 'window.position must be a string'
  end

  if type(window.enter_insert) ~= 'boolean' then
    return false, 'window.enter_insert must be a boolean'
  end

  if type(window.start_in_normal_mode) ~= 'boolean' then
    return false, 'window.start_in_normal_mode must be a boolean'
  end

  if type(window.hide_numbers) ~= 'boolean' then
    return false, 'window.hide_numbers must be a boolean'
  end

  if type(window.hide_signcolumn) ~= 'boolean' then
    return false, 'window.hide_signcolumn must be a boolean'
  end

  return true, nil
end

--- Validate floating window configuration
--- @param float table Float configuration
--- @return boolean valid
--- @return string? error_message
local function validate_float_config(float)
  if type(float) ~= 'table' then
    return false, 'window.float must be a table when position is "float"'
  end

  -- Validate width (can be number or percentage string)
  if type(float.width) == 'string' then
    if not float.width:match('^%d+%%$') then
      return false, 'window.float.width must be a number or percentage (e.g., "80%")'
    end
  elseif type(float.width) ~= 'number' or float.width <= 0 then
    return false, 'window.float.width must be a positive number or percentage string'
  end

  -- Validate height (can be number or percentage string)
  if type(float.height) == 'string' then
    if not float.height:match('^%d+%%$') then
      return false, 'window.float.height must be a number or percentage (e.g., "80%")'
    end
  elseif type(float.height) ~= 'number' or float.height <= 0 then
    return false, 'window.float.height must be a positive number or percentage string'
  end

  -- Validate relative (must be "editor" or "cursor")
  if float.relative ~= 'editor' and float.relative ~= 'cursor' then
    return false, 'window.float.relative must be "editor" or "cursor"'
  end

  -- Validate border (must be valid border style)
  local valid_borders = { 'none', 'single', 'double', 'rounded', 'solid', 'shadow' }
  local is_valid_border = false
  for _, border in ipairs(valid_borders) do
    if float.border == border then
      is_valid_border = true
      break
    end
  end
  -- Also allow array borders
  if not is_valid_border and type(float.border) ~= 'table' then
    return false, 'window.float.border must be one of: none, single, double, rounded, solid, shadow, or an array'
  end

  -- Validate row and col if they exist
  if float.row ~= nil then
    if type(float.row) == 'string' and float.row ~= 'center' then
      if not float.row:match('^%d+%%$') then
        return false, 'window.float.row must be a number, "center", or percentage string'
      end
    elseif type(float.row) ~= 'number' and float.row ~= 'center' then
      return false, 'window.float.row must be a number, "center", or percentage string'
    end
  end

  if float.col ~= nil then
    if type(float.col) == 'string' and float.col ~= 'center' then
      if not float.col:match('^%d+%%$') then
        return false, 'window.float.col must be a number, "center", or percentage string'
      end
    elseif type(float.col) ~= 'number' and float.col ~= 'center' then
      return false, 'window.float.col must be a number, "center", or percentage string'
    end
  end

  return true, nil
end

--- Validate refresh configuration
--- @param refresh table Refresh configuration
--- @return boolean valid
--- @return string? error_message
local function validate_refresh_config(refresh)
  if type(refresh) ~= 'table' then
    return false, 'refresh config must be a table'
  end

  if type(refresh.enable) ~= 'boolean' then
    return false, 'refresh.enable must be a boolean'
  end

  if type(refresh.updatetime) ~= 'number' or refresh.updatetime <= 0 then
    return false, 'refresh.updatetime must be a positive number'
  end

  if type(refresh.timer_interval) ~= 'number' or refresh.timer_interval <= 0 then
    return false, 'refresh.timer_interval must be a positive number'
  end

  if type(refresh.show_notifications) ~= 'boolean' then
    return false, 'refresh.show_notifications must be a boolean'
  end

  return true, nil
end

--- Validate git configuration
--- @param git table Git configuration
--- @return boolean valid
--- @return string? error_message
local function validate_git_config(git)
  if type(git) ~= 'table' then
    return false, 'git config must be a table'
  end

  if type(git.use_git_root) ~= 'boolean' then
    return false, 'git.use_git_root must be a boolean'
  end

  if type(git.multi_instance) ~= 'boolean' then
    return false, 'git.multi_instance must be a boolean'
  end

  return true, nil
end

--- Validate keymaps configuration
--- @param keymaps table Keymaps configuration
--- @return boolean valid
--- @return string? error_message
local function validate_keymaps_config(keymaps)
  if type(keymaps) ~= 'table' then
    return false, 'keymaps config must be a table'
  end

  if type(keymaps.toggle) ~= 'table' then
    return false, 'keymaps.toggle must be a table'
  end

  if not (keymaps.toggle.normal == false or type(keymaps.toggle.normal) == 'string') then
    return false, 'keymaps.toggle.normal must be a string or false'
  end

  if not (keymaps.toggle.terminal == false or type(keymaps.toggle.terminal) == 'string') then
    return false, 'keymaps.toggle.terminal must be a string or false'
  end

  -- Validate variant keymaps if they exist
  if keymaps.toggle.variants then
    if type(keymaps.toggle.variants) ~= 'table' then
      return false, 'keymaps.toggle.variants must be a table'
    end

    -- Check each variant keymap
    for variant_name, keymap in pairs(keymaps.toggle.variants) do
      if not (keymap == false or type(keymap) == 'string') then
        return false, 'keymaps.toggle.variants.' .. variant_name .. ' must be a string or false'
      end
    end
  end

  if type(keymaps.window_navigation) ~= 'boolean' then
    return false, 'keymaps.window_navigation must be a boolean'
  end

  if type(keymaps.scrolling) ~= 'boolean' then
    return false, 'keymaps.scrolling must be a boolean'
  end

  return true, nil
end

--- Validate command variants configuration
--- @param command_variants table Command variants configuration
--- @return boolean valid
--- @return string? error_message
local function validate_command_variants_config(command_variants)
  if type(command_variants) ~= 'table' then
    return false, 'command_variants config must be a table'
  end

  -- Check each command variant
  for variant_name, variant_args in pairs(command_variants) do
    if not (variant_args == false or type(variant_args) == 'string') then
      return false, 'command_variants.' .. variant_name .. ' must be a string or false'
    end
  end

  return true, nil
end

--- Validate configuration options
--- @param config PiAgentConfig
--- @return boolean valid
--- @return string? error_message
local function validate_config(config)
  -- Validate window settings
  local valid, err = validate_window_config(config.window)
  if not valid then
    return false, err
  end

  -- Validate float configuration if position is "float"
  if config.window.position == 'float' then
    valid, err = validate_float_config(config.window.float)
    if not valid then
      return false, err
    end
  end

  -- Validate refresh settings
  valid, err = validate_refresh_config(config.refresh)
  if not valid then
    return false, err
  end

  -- Validate git settings
  valid, err = validate_git_config(config.git)
  if not valid then
    return false, err
  end

  -- Validate command settings
  if type(config.command) ~= 'string' then
    return false, 'command must be a string'
  end

  -- Validate command variants settings
  valid, err = validate_command_variants_config(config.command_variants)
  if not valid then
    return false, err
  end

  -- Validate keymaps settings
  valid, err = validate_keymaps_config(config.keymaps)
  if not valid then
    return false, err
  end

  -- Cross-validate keymaps with command variants
  if config.keymaps.toggle.variants then
    for variant_name, keymap in pairs(config.keymaps.toggle.variants) do
      -- Ensure variant exists in command_variants
      if keymap ~= false and not config.command_variants[variant_name] then
        return false, 'keymaps.toggle.variants.' .. variant_name .. ' has no corresponding command variant'
      end
    end
  end

  return true, nil
end

--- Parse user configuration and merge with defaults
--- @param user_config? table
--- @param silent? boolean Set to true to suppress error notifications (for tests)
--- @return PiAgentConfig
function M.parse_config(user_config, silent)
  local config = vim.tbl_deep_extend('force', {}, M.default_config, user_config or {})

  -- If position is float and no float config provided, use default float config
  if config.window.position == 'float' and not (user_config and user_config.window and user_config.window.float) then
    config.window.float = vim.deepcopy(M.default_config.window.float)
  end

  local valid, err = validate_config(config)
  if not valid then
    -- Only notify if not in silent mode
    if not silent then
      vim.notify('Pi Agent: ' .. err, vim.log.levels.ERROR)
    end
    -- Fall back to default config in case of error
    return vim.deepcopy(M.default_config)
  end

  return config
end

return M
