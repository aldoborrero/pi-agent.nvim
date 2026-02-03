-- Tests for the git module
local assert = require('luassert')
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it

local git = require('pi-agent.git')

describe('git', function()
  -- Keep track of the original environment
  local original_env_test_mode = vim.env.PI_AGENT_TEST_MODE
  local original_system
  local original_vim_v

  before_each(function()
    original_system = vim.fn.system
    original_vim_v = vim.v
  end)

  after_each(function()
    vim.fn.system = original_system
    vim.v = original_vim_v
    vim.env.PI_AGENT_TEST_MODE = original_env_test_mode
  end)

  describe('get_git_root', function()
    it('should return nil when git command fails', function()
      vim.env.PI_AGENT_TEST_MODE = nil

      vim.fn.system = function(cmd)
        return ''
      end
      vim.v = { shell_error = 128 }

      local result = git.get_git_root()
      assert.is_nil(result)
    end)

    it('should return nil for non-git directories', function()
      vim.env.PI_AGENT_TEST_MODE = nil

      vim.fn.system = function(cmd)
        return ''
      end
      vim.v = { shell_error = 128 }

      local result = git.get_git_root()
      assert.is_nil(result)
    end)

    it('should return git root in a git directory', function()
      vim.env.PI_AGENT_TEST_MODE = nil

      vim.fn.system = function(cmd)
        return '/home/user/project\n'
      end
      vim.v = { shell_error = 0 }

      local result = git.get_git_root()
      assert.are.equal('/home/user/project', result)
    end)

    it('should return hardcoded path in test mode', function()
      vim.env.PI_AGENT_TEST_MODE = 'true'

      local system_called = false
      vim.fn.system = function(cmd)
        system_called = true
        return ''
      end

      local result = git.get_git_root()
      assert.are.equal('/home/user/project', result)
      assert.is_false(system_called, 'vim.fn.system should not be called in test mode')
    end)
  end)
end)
