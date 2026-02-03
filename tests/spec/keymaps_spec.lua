-- Tests for keymaps in Pi Agent
local assert = require('luassert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

local keymaps = require('pi-agent.keymaps')

describe('keymaps', function()
  local mapped_keys = {}
  local augroup_id = 100
  local registered_autocmds = {}
  local pi_agent
  local config

  before_each(function()
    -- Reset tracking variables
    mapped_keys = {}
    registered_autocmds = {}

    -- Mock vim functions
    _G.vim = _G.vim or {}
    _G.vim.api = _G.vim.api or {}
    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.fn = _G.vim.fn or {}

    -- Mock vim.api.nvim_set_keymap - used in keymaps module
    _G.vim.api.nvim_set_keymap = function(mode, lhs, rhs, opts)
      table.insert(mapped_keys, {
        mode = mode,
        lhs = lhs,
        rhs = rhs,
        opts = opts,
      })
    end

    -- Mock vim.keymap.set for newer style mappings
    _G.vim.keymap.set = function(mode, lhs, rhs, opts)
      table.insert(mapped_keys, {
        mode = mode,
        lhs = lhs,
        rhs = rhs,
        opts = opts,
      })
    end

    -- Mock vim.api.nvim_create_augroup
    _G.vim.api.nvim_create_augroup = function(name, opts)
      return augroup_id
    end

    -- Mock vim.api.nvim_create_autocmd
    _G.vim.api.nvim_create_autocmd = function(events, opts)
      table.insert(registered_autocmds, {
        events = events,
        opts = opts,
      })
      return 1
    end

    -- Setup test objects
    pi_agent = {
      toggle = function() end,
    }

    config = {
      keymaps = {
        toggle = {
          normal = '<leader>ac',
          terminal = '<C-o>',
        },
        window_navigation = true,
      },
    }
  end)

  describe('register_keymaps', function()
    it('should register normal mode toggle keybinding', function()
      keymaps.register_keymaps(pi_agent, config)

      local normal_toggle_found = false
      for _, mapping in ipairs(mapped_keys) do
        if mapping.mode == 'n' and mapping.lhs == '<leader>ac' then
          normal_toggle_found = true
          break
        end
      end

      assert.is_true(normal_toggle_found, 'Normal mode toggle keybinding should be registered')
    end)

    it('should register terminal mode toggle keybinding', function()
      keymaps.register_keymaps(pi_agent, config)

      local terminal_toggle_found = false
      for _, mapping in ipairs(mapped_keys) do
        if mapping.mode == 't' and mapping.lhs == '<C-o>' then
          terminal_toggle_found = true
          break
        end
      end

      assert.is_true(terminal_toggle_found, 'Terminal mode toggle keybinding should be registered')
    end)

    it('should not register keybindings when disabled in config', function()
      -- Disable keybindings
      config.keymaps.toggle.normal = false
      config.keymaps.toggle.terminal = false

      keymaps.register_keymaps(pi_agent, config)

      local toggle_keybindings_found = false
      for _, mapping in ipairs(mapped_keys) do
        if
          (mapping.mode == 'n' and mapping.lhs == '<leader>ac')
          or (mapping.mode == 't' and mapping.lhs == '<C-o>')
        then
          toggle_keybindings_found = true
          break
        end
      end

      assert.is_false(toggle_keybindings_found, 'Toggle keybindings should not be registered when disabled')
    end)

    it('should register window navigation keybindings when enabled', function()
      -- Setup pi_agent table with correct instance structure
      pi_agent.pi_agent = {
        instances = { ['global'] = 42 },
        current_instance = 'global',
      }

      -- Enable window navigation
      config.keymaps.window_navigation = true
      config.keymaps.scrolling = false

      -- Mock buf_is_valid
      _G.vim.api.nvim_buf_is_valid = function(bufnr)
        return bufnr == 42
      end

      -- Mock vim.cmd for stopinsert/wincmd used in callbacks
      _G.vim.cmd = function() end

      -- Reset mapped_keys before this test
      mapped_keys = {}

      keymaps.setup_terminal_navigation(pi_agent, config)

      -- Check that window navigation keymaps were registered
      local nav_count = 0
      for _, mapping in ipairs(mapped_keys) do
        if mapping.opts and mapping.opts.desc and mapping.opts.desc:match('Window: move') then
          nav_count = nav_count + 1
        end
      end

      -- 4 directions x 2 modes (terminal + normal) = 8 keymaps
      assert.are.equal(8, nav_count, 'Should register 8 window navigation keymaps (4 directions x 2 modes)')
    end)

    it('should not register window navigation keybindings when disabled', function()
      -- Setup pi_agent table with correct instance structure
      pi_agent.pi_agent = {
        instances = { ['global'] = 42 },
        current_instance = 'global',
      }

      -- Disable window navigation
      config.keymaps.window_navigation = false
      config.keymaps.scrolling = false

      -- Mock buf_is_valid
      _G.vim.api.nvim_buf_is_valid = function(bufnr)
        return bufnr == 42
      end

      -- Reset mapped_keys
      mapped_keys = {}

      keymaps.setup_terminal_navigation(pi_agent, config)

      local window_navigation_found = false
      for _, mapping in ipairs(mapped_keys) do
        if mapping.opts and mapping.opts.desc and mapping.opts.desc:match('Window: move') then
          window_navigation_found = true
          break
        end
      end

      assert.is_false(window_navigation_found, 'Window navigation keybindings should not be registered when disabled')
    end)
  end)
end)
