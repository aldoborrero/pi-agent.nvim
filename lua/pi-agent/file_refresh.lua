---@mod pi-agent.file_refresh File refresh functionality for pi-agent.nvim
---@brief [[
--- This module provides file refresh functionality to detect and reload files
--- that have been modified by Pi Agent or other external processes.
---@brief ]]

local M = {}

--- Timer for checking file changes
--- @type userdata|nil
local refresh_timer = nil

--- Setup autocommands for file change detection
--- @param pi_agent table The main plugin module
--- @param config table The plugin configuration
function M.setup(pi_agent, config)
  if not config.refresh.enable then
    return
  end

  local augroup = vim.api.nvim_create_augroup('PiAgentFileRefresh', { clear = true })

  -- Create an autocommand that checks for file changes more frequently
  vim.api.nvim_create_autocmd({
    'CursorHold',
    'CursorHoldI',
    'FocusGained',
    'BufEnter',
    'InsertLeave',
    'TextChanged',
    'TermLeave',
    'TermEnter',
    'BufWinEnter',
  }, {
    group = augroup,
    pattern = '*',
    callback = function()
      if vim.fn.filereadable(vim.fn.expand '%') == 1 then
        vim.cmd 'checktime'
      end
    end,
    desc = 'Check for file changes on disk',
  })

  -- Clean up any existing timer
  if refresh_timer then
    refresh_timer:stop()
    refresh_timer:close()
    refresh_timer = nil
  end

  -- Create a timer to check for file changes periodically
  refresh_timer = vim.uv.new_timer()
  if refresh_timer then
    refresh_timer:start(
      0,
      config.refresh.timer_interval,
      vim.schedule_wrap(function()
        -- Only check time if there's an active Pi Agent terminal
        local current_instance = pi_agent.pi_agent.current_instance
        local bufnr = current_instance and pi_agent.pi_agent.instances[current_instance]
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) and #vim.fn.win_findbuf(bufnr) > 0 then
          vim.cmd 'silent! checktime'
        end
      end)
    )
  end

  -- Create an autocommand that notifies when a file has been changed externally
  if config.refresh.show_notifications then
    vim.api.nvim_create_autocmd('FileChangedShellPost', {
      group = augroup,
      pattern = '*',
      callback = function()
        vim.notify('File changed on disk. Buffer reloaded.', vim.log.levels.INFO)
      end,
      desc = 'Notify when a file is changed externally',
    })
  end

  -- Set a shorter updatetime while Pi Agent is open
  pi_agent.pi_agent.saved_updatetime = vim.o.updatetime

  -- When Pi Agent opens, set a shorter updatetime
  vim.api.nvim_create_autocmd('TermOpen', {
    group = augroup,
    pattern = '*',
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match('pi%-agent') then
        pi_agent.pi_agent.saved_updatetime = vim.o.updatetime
        vim.o.updatetime = config.refresh.updatetime
      end
    end,
    desc = 'Set shorter updatetime when Pi Agent is open',
  })

  -- When Pi Agent closes, restore normal updatetime and clean up if no instances remain
  vim.api.nvim_create_autocmd('TermClose', {
    group = augroup,
    pattern = '*',
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      if buf_name:match('pi%-agent') then
        -- Remove the closed instance
        for id, bufnr in pairs(pi_agent.pi_agent.instances) do
          if not vim.api.nvim_buf_is_valid(bufnr) then
            pi_agent.pi_agent.instances[id] = nil
          end
        end

        -- Restore updatetime
        if pi_agent.pi_agent.saved_updatetime then
          vim.o.updatetime = pi_agent.pi_agent.saved_updatetime
        end

        -- If no instances remain, stop the refresh timer
        if next(pi_agent.pi_agent.instances) == nil then
          M.cleanup()
        end
      end
    end,
    desc = 'Restore normal updatetime when Pi Agent is closed',
  })
end

--- Clean up the file refresh functionality (stop the timer)
function M.cleanup()
  if refresh_timer then
    refresh_timer:stop()
    refresh_timer:close()
    refresh_timer = nil
  end
end

return M
