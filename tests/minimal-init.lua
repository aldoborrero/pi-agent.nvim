-- Minimal configuration for testing Pi Agent plugin

local function get_plugin_path()
  local source = debug.getinfo(1, 'S').source
  if source:sub(1, 1) == '@' then
    source = source:sub(2)
    if source:find('/tests/minimal%-init%.lua$') then
      return source:gsub('/tests/minimal%-init%.lua$', '')
    end
  end
  return vim.fn.getcwd()
end

local plugin_dir = get_plugin_path()

-- Basic settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false
vim.opt.hidden = true
vim.opt.termguicolors = true

-- Add the plugin directory to runtimepath
vim.opt.runtimepath:append(plugin_dir)

-- Verify plenary is available (provided by Nix)
local ok, _ = pcall(require, 'plenary')
if not ok then
  print('Error: plenary.nvim not found. Run tests via: nix develop -c just test')
  vim.cmd('cq 1')
end

-- Load plenary test libraries
require('plenary.async')
require('plenary.busted')

-- Print runtime path for debugging
print('Runtime path: ' .. vim.o.runtimepath)

-- Load the plugin
local status_ok, pi_agent = pcall(require, 'pi-agent')
if status_ok then
  print('✓ Successfully loaded Pi Agent plugin')
  print('')
  print('Available Commands:')
  print('  :PiAgent          - Toggle the Pi Agent terminal')
  print('  :PiAgentContinue  - Toggle with --continue option')
  print('  :PiAgentResume    - Toggle with --resume option')
  print('  :PiAgentVerbose   - Toggle with --verbose option')
  print('  :PiAgentVersion   - Display Pi Agent version')
else
  print('✗ Failed to load Pi Agent plugin: ' .. tostring(pi_agent))
end

print('')
print('Pi Agent minimal test environment loaded.')
print('- Type :messages to see any error messages')
print("- Try ':PiAgent' to start a new session")
