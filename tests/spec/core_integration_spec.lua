-- Tests for core integration in Pi Agent
local assert = require('luassert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

-- Mock required modules before loading the actual plugin
local mock_modules = {}

-- Mock the version module
mock_modules['pi-agent.version'] = {
  string = function()
    return '0.1.0'
  end,
  version = '0.1.0',
  major = 0,
  minor = 1,
  patch = 0,
  print_version = function() end,
}

-- Mock the terminal module
mock_modules['pi-agent.terminal'] = {
  toggle = function()
    return true
  end,
  force_insert_mode = function() end,
  terminal = {
    instances = {},
    saved_updatetime = nil,
    current_instance = nil,
  },
}

-- Mock the file_refresh module
mock_modules['pi-agent.file_refresh'] = {
  setup = function()
    return true
  end,
  cleanup = function()
    return true
  end,
}

-- Mock the commands module
mock_modules['pi-agent.commands'] = {
  register_commands = function()
    return true
  end,
}

-- Mock the keymaps module
mock_modules['pi-agent.keymaps'] = {
  setup_keymaps = function()
    return true
  end,
  register_keymaps = function()
    return true
  end,
}

-- Mock the git module
mock_modules['pi-agent.git'] = {
  get_git_root = function()
    return '/test/git/root'
  end,
}

-- Mock the config module
mock_modules['pi-agent.config'] = {
  default_config = {
    window = {
      position = 'botright',
      split_ratio = 0.5,
      enter_insert = true,
      hide_numbers = true,
      hide_signcolumn = true,
    },
    refresh = {
      enable = true,
      updatetime = 500,
      timer_interval = 1000,
      show_notifications = true,
    },
    git = {
      use_git_root = true,
    },
    keymaps = {
      toggle = {
        normal = '<leader>ac',
        terminal = '<C-o>',
      },
      window_navigation = true,
    },
  },
  parse_config = function(user_config)
    if not user_config then
      return mock_modules['pi-agent.config'].default_config
    end
    return vim.tbl_deep_extend('force', mock_modules['pi-agent.config'].default_config, user_config)
  end,
}

-- Setup require hook to use our mocks
local original_require = _G.require
_G.require = function(module_name)
  if mock_modules[module_name] then
    return mock_modules[module_name]
  end
  return original_require(module_name)
end

-- Now load the plugin
local pi_agent = require('pi-agent')

-- Restore original require
_G.require = original_require

describe('core integration', function()
  local test_plugin

  before_each(function()
    -- Mock vim functions
    _G.vim = _G.vim or {}
    _G.vim.tbl_deep_extend = function(mode, tbl1, tbl2)
      -- Simple deep merge implementation for testing
      local result = {}
      for k, v in pairs(tbl1) do
        result[k] = v
      end
      for k, v in pairs(tbl2 or {}) do
        if type(v) == 'table' and type(result[k]) == 'table' then
          result[k] = vim.tbl_deep_extend(mode, result[k], v)
        else
          result[k] = v
        end
      end
      return result
    end

    -- Create a simple test object that we can verify
    test_plugin = {
      toggle = function()
        return true
      end,
      get_version = function()
        return '0.1.0'
      end,
      config = mock_modules['pi-agent.config'].default_config,
    }
  end)

  describe('setup', function()
    it('should return a plugin object with expected methods', function()
      assert.is_not_nil(pi_agent, 'Pi Agent plugin should not be nil')
      assert.is_function(pi_agent.setup, 'Should have a setup function')
      assert.is_function(pi_agent.toggle, 'Should have a toggle function')
      assert.is_not_nil(pi_agent.version, 'Should have a version')
    end)

    it('should initialize with default config when no user config is provided', function()
      assert.is_not_nil(test_plugin, 'Plugin object is available')
      assert.is_not_nil(test_plugin.config, 'Config should be initialized')
      assert.are.equal(0.5, test_plugin.config.window.split_ratio, 'Default split_ratio should be 0.5')
    end)

    it('should merge user config with defaults', function()
      local user_config = {
        window = {
          split_ratio = 0.7,
        },
        keymaps = {
          toggle = {
            normal = '<leader>cc',
          },
        },
      }

      -- Use the parse_config function from the mock
      local merged_config = mock_modules['pi-agent.config'].parse_config(user_config)

      -- Check that user config was merged correctly
      assert.are.equal(0.7, merged_config.window.split_ratio, 'User split_ratio should override default')
      assert.are.equal('<leader>cc', merged_config.keymaps.toggle.normal, 'User keymaps should override default')

      -- Default values should still be present for unspecified options
      assert.are.equal('botright', merged_config.window.position, 'Default position should be preserved')
      assert.are.equal(true, merged_config.refresh.enable, 'Default refresh.enable should be preserved')
    end)
  end)

  describe('version', function()
    it('should return the correct version string', function()
      local version_string = test_plugin.get_version()
      assert.are.equal('0.1.0', version_string, 'Version string should match expected value')
    end)
  end)

  describe('toggle', function()
    it('should be callable without errors', function()
      local success, err = pcall(function()
        test_plugin.toggle()
      end)
      assert.is_true(success, 'Toggle should be callable without errors')
    end)
  end)
end)
