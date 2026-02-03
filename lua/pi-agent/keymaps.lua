---@mod pi-agent.keymaps Keymap management for pi-agent.nvim
---@brief [[
--- This module provides keymap registration and handling for pi-agent.nvim.
--- It handles normal mode, terminal mode, and window navigation keymaps.
---@brief ]]

local M = {}

--- Register keymaps for pi-agent.nvim
--- @param _pi_agent table The main plugin module (unused)
--- @param config table The plugin configuration
function M.register_keymaps(_pi_agent, config)
  -- Normal mode toggle keymaps
  if config.keymaps.toggle.normal then
    vim.keymap.set('n', config.keymaps.toggle.normal, '<cmd>PiAgent<CR>', {
      desc = 'Pi Agent: Toggle',
    })
  end

  if config.keymaps.toggle.terminal then
    -- Terminal mode toggle keymap
    -- In terminal mode, special keys like Ctrl need different handling
    -- We use a direct escape sequence approach for more reliable terminal mappings
    vim.keymap.set('t', config.keymaps.toggle.terminal, [[<C-\><C-n>:PiAgent<CR>]], {
      desc = 'Pi Agent: Toggle',
    })
  end

  -- Register variant keymaps if configured
  if config.keymaps.toggle.variants then
    for variant_name, keymap in pairs(config.keymaps.toggle.variants) do
      if keymap then
        -- Convert variant name to PascalCase for command name (e.g., "continue" -> "Continue")
        local capitalized_name = variant_name:gsub('^%l', string.upper)
        local cmd_name = 'PiAgent' .. capitalized_name

        vim.keymap.set('n', keymap, string.format('<cmd>%s<CR>', cmd_name), {
          desc = 'Pi Agent: ' .. capitalized_name,
        })
      end
    end
  end

  -- Register with which-key if it's available
  vim.defer_fn(function()
    local status_ok, which_key = pcall(require, 'which-key')
    if status_ok then
      if config.keymaps.toggle.normal then
        which_key.add {
          mode = 'n',
          { config.keymaps.toggle.normal, desc = 'Pi Agent: Toggle', icon = '🤖' },
        }
      end
      if config.keymaps.toggle.terminal then
        which_key.add {
          mode = 't',
          { config.keymaps.toggle.terminal, desc = 'Pi Agent: Toggle', icon = '🤖' },
        }
      end

      -- Register variant keymaps with which-key
      if config.keymaps.toggle.variants then
        for variant_name, keymap in pairs(config.keymaps.toggle.variants) do
          if keymap then
            local capitalized_name = variant_name:gsub('^%l', string.upper)
            which_key.add {
              mode = 'n',
              { keymap, desc = 'Pi Agent: ' .. capitalized_name, icon = '🤖' },
            }
          end
        end
      end
    end
  end, 100)
end

--- Set up terminal-specific keymaps for window navigation
--- @param pi_agent table The main plugin module
--- @param config table The plugin configuration
function M.setup_terminal_navigation(pi_agent, config)
  -- Get current active Pi Agent instance buffer
  local current_instance = pi_agent.pi_agent.current_instance
  local buf = current_instance and pi_agent.pi_agent.instances[current_instance]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    -- Create autocommand to enter insert mode when the terminal window gets focus
    local augroup = vim.api.nvim_create_augroup('PiAgentTerminalFocus_' .. buf, { clear = true })

    -- Set up multiple events for more reliable focus detection
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'WinLeave', 'FocusGained', 'CmdLineLeave' }, {
      group = augroup,
      callback = function()
        vim.schedule(pi_agent.force_insert_mode)
      end,
      desc = 'Auto-enter insert mode when focusing Pi Agent terminal',
    })

    -- Window navigation keymaps
    if config.keymaps.window_navigation then
      local nav_maps = {
        { 'h', 'left' },
        { 'j', 'down' },
        { 'k', 'up' },
        { 'l', 'right' },
      }

      for _, map in ipairs(nav_maps) do
        local key, direction = map[1], map[2]

        -- Terminal mode: escape terminal first, then navigate
        vim.keymap.set('t', '<C-' .. key .. '>', function()
          vim.cmd([[stopinsert]])
          vim.cmd('wincmd ' .. key)
          require('pi-agent').force_insert_mode()
        end, { buffer = buf, desc = 'Window: move ' .. direction })

        -- Normal mode: navigate directly
        vim.keymap.set('n', '<C-' .. key .. '>', function()
          vim.cmd('wincmd ' .. key)
          require('pi-agent').force_insert_mode()
        end, { buffer = buf, desc = 'Window: move ' .. direction })
      end
    end

    -- Add scrolling keymaps
    if config.keymaps.scrolling then
      vim.keymap.set('t', '<C-f>', [[<C-\><C-n><C-f>i]], {
        buffer = buf,
        desc = 'Scroll full page down',
      })
      vim.keymap.set('t', '<C-b>', [[<C-\><C-n><C-b>i]], {
        buffer = buf,
        desc = 'Scroll full page up',
      })
    end
  end
end

return M
