---@mod pi-agent.commands Command registration for pi-agent.nvim
---@brief [[
--- This module provides command registration and handling for pi-agent.nvim.
--- It defines user commands and command handlers.
---@brief ]]

local M = {}

--- @type table<string, function> List of available commands and their handlers
M.commands = {}

--- Register commands for the pi-agent plugin
--- @param pi_agent table The main plugin module
function M.register_commands(pi_agent)
  -- Create the user command for toggling Pi Agent
  vim.api.nvim_create_user_command('PiAgent', function()
    pi_agent.toggle()
  end, { desc = 'Toggle Pi Agent terminal' })

  -- Create commands for each command variant
  for variant_name, variant_args in pairs(pi_agent.config.command_variants) do
    if variant_args ~= false then
      -- Convert variant name to PascalCase for command name (e.g., "continue" -> "Continue")
      local capitalized_name = variant_name:gsub('^%l', string.upper)
      local cmd_name = 'PiAgent' .. capitalized_name

      vim.api.nvim_create_user_command(cmd_name, function()
        pi_agent.toggle_with_variant(variant_name)
      end, { desc = 'Toggle Pi Agent terminal with ' .. variant_name .. ' option' })
    end
  end

  -- Add version command
  vim.api.nvim_create_user_command('PiAgentVersion', function()
    vim.notify('Pi Agent version: ' .. pi_agent.get_version(), vim.log.levels.INFO)
  end, { desc = 'Display Pi Agent version' })
end

return M
