---@mod pi-agent Pi Agent Neovim Integration
---@brief [[
--- A plugin for seamless integration between Pi Agent AI assistant and Neovim.
--- This plugin provides a terminal-based interface to Pi Agent within Neovim.
---
--- Requirements:
--- - Neovim 0.10.0 or later
--- - Pi Agent CLI tool installed and available in PATH
---
--- Usage:
--- ```lua
--- require('pi-agent').setup({
---   -- Configuration options (optional)
--- })
--- ```
---@brief ]]

-- Import modules
local config = require('pi-agent.config')
local commands = require('pi-agent.commands')
local keymaps = require('pi-agent.keymaps')
local file_refresh = require('pi-agent.file_refresh')
local terminal = require('pi-agent.terminal')
local git = require('pi-agent.git')
local version = require('pi-agent.version')

local M = {}

-- Make imported modules available
M.commands = commands

-- Store the current configuration
--- @type table
M.config = {}

-- Terminal buffer and window management
--- @type table
M.pi_agent = terminal.terminal

--- Force insert mode when entering the Pi Agent window
--- This is a public function used in keymaps
function M.force_insert_mode()
  terminal.force_insert_mode(M, M.config)
end

--- Get the current active buffer number
--- @return number|nil bufnr Current Pi Agent instance buffer number or nil
local function get_current_buffer_number()
  -- Get current instance from the instances table
  local current_instance = M.pi_agent.current_instance
  if current_instance and type(M.pi_agent.instances) == 'table' then
    return M.pi_agent.instances[current_instance]
  end
  return nil
end

--- Toggle the Pi Agent terminal window
--- This is a public function used by commands
function M.toggle()
  terminal.toggle(M, M.config, git)

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end
end

--- Toggle the Pi Agent terminal window with a specific command variant
--- @param variant_name string The name of the command variant to use
function M.toggle_with_variant(variant_name)
  if not variant_name or not M.config.command_variants[variant_name] then
    -- If variant doesn't exist, fall back to regular toggle
    return M.toggle()
  end

  -- Build the full command with variant args without mutating config
  local full_command = M.config.command .. ' ' .. M.config.command_variants[variant_name]

  -- Call the toggle function with the command override
  terminal.toggle(M, M.config, git, full_command)

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end
end

--- Get the current version of the plugin
--- @return string version Current version string
function M.get_version()
  return version.string()
end

--- Version information
M.version = version

--- Setup function for the plugin
--- @param user_config? table User configuration table (optional)
function M.setup(user_config)
  -- Parse and validate configuration
  -- Don't use silent mode for regular usage - users should see config errors
  M.config = config.parse_config(user_config, false)

  -- Set up autoread option
  vim.o.autoread = true

  -- Set up file refresh functionality
  file_refresh.setup(M, M.config)

  -- Register commands
  commands.register_commands(M)

  -- Register keymaps
  keymaps.register_keymaps(M, M.config)
end

return M
