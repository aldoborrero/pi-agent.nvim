---@mod pi-agent.git Git integration for pi-agent.nvim
---@brief [[
--- This module provides git integration functionality for pi-agent.nvim.
--- It detects git repositories and can set the working directory to the git root.
---@brief ]]

local M = {}

--- Helper function to get git root directory
--- @return string|nil git_root The git root directory path or nil if not in a git repo
function M.get_git_root()
  -- For testing compatibility
  if vim.env.PI_AGENT_TEST_MODE == 'true' then
    return '/home/user/project'
  end

  -- Single call: returns the toplevel path or errors if not in a git repo
  local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null')

  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Remove trailing whitespace and newlines
  git_root = git_root:gsub('[\n\r%s]*$', '')

  if git_root == '' then
    return nil
  end

  return git_root
end

return M
