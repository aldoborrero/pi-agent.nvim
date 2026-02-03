# Project: Pi Agent Plugin

## Overview

Pi Agent Plugin provides seamless integration between the Pi Agent CLI and Neovim. It enables direct communication with the `pi` CLI from within the editor, context-aware interactions, and various utilities to enhance AI-assisted development within Neovim.

## Essential Commands

- Run Tests: `./scripts/test.sh`
- Check Formatting: `stylua lua/ -c`
- Format Code: `stylua lua/`
- Run Linter: `luacheck lua/`

## Project Structure

- `/lua/pi-agent`: Main plugin code
- `/after/plugin`: Plugin setup and initialization
- `/tests`: Test files for plugin functionality
- `/doc`: Vim help documentation

## Multi-Instance Support

The plugin supports running multiple Pi Agent instances, one per git repository root:

- Each git repository maintains its own instance
- Works across multiple Neovim tabs with different projects
- Allows working on multiple projects in parallel
- Configurable via `git.multi_instance` option (defaults to `true`)
- Instances remain in their own directory context when switching between tabs
- Buffer names include the git root path for easy identification

Example configuration to disable multi-instance mode:

```lua
require('pi-agent').setup({
  git = {
    multi_instance = false  -- Use a single global instance
  }
})
```
