# Pi Agent Neovim Plugin

[![License](https://img.shields.io/github/license/aldoborrero/pi-agent.nvim?style=flat-square)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/aldoborrero/pi-agent.nvim/ci.yml?branch=main&style=flat-square)](https://github.com/aldoborrero/pi-agent.nvim/actions/workflows/ci.yml)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-blueviolet?style=flat-square&logo=neovim)](https://neovim.io)

Neovim plugin for [Pi Agent](https://github.com/badlogic/pi-agent) AI assistant.

## Features

- Toggle Pi Agent terminal with a single keypress
- Floating window and split support
- Auto-reload buffers when Pi Agent modifies files
- Git-aware working directory
- Command variants (`--continue`, `--resume`, `--verbose`)

## Requirements

- Neovim 0.10+
- [Pi Agent CLI](https://github.com/badlogic/pi-agent) in your PATH

## Installation

### lazy.nvim

```lua
{
  "aldoborrero/pi-agent.nvim",
  opts = {},
}
```

## Configuration

```lua
require("pi-agent").setup({
  -- Terminal window
  window = {
    split_ratio = 0.3,
    position = "botright",  -- "botright", "topleft", "vertical", "float"
    enter_insert = true,
    hide_numbers = true,
    hide_signcolumn = true,
    -- Floating window (when position = "float")
    float = {
      width = "80%",
      height = "80%",
      row = "center",
      col = "center",
      relative = "editor",
      border = "rounded",
    },
  },
  -- File refresh
  refresh = {
    enable = true,
    updatetime = 100,
    timer_interval = 1000,
    show_notifications = true,
  },
  -- Git
  git = {
    use_git_root = true,
  },
  -- Command
  command = "pi",
  command_variants = {
    continue = "--continue",
    resume = "--resume",
    verbose = "--verbose",
  },
  -- Keymaps
  keymaps = {
    toggle = {
      normal = "<C-,>",
      terminal = "<C-,>",
      variants = {
        continue = "<leader>cC",
        verbose = "<leader>cV",
      },
    },
    window_navigation = true,
    scrolling = true,
  },
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:PiAgent` | Toggle terminal |
| `:PiAgentContinue` | Resume last conversation |
| `:PiAgentResume` | Interactive conversation picker |
| `:PiAgentVerbose` | Verbose logging mode |

### Keymaps

| Key | Mode | Description |
|-----|------|-------------|
| `<C-,>` | Normal/Terminal | Toggle Pi Agent |
| `<leader>cC` | Normal | Toggle with `--continue` |
| `<leader>cV` | Normal | Toggle with `--verbose` |
| `<C-h/j/k/l>` | Terminal | Window navigation |
| `<C-f/b>` | Terminal | Page up/down |

### Floating Window

```lua
require("pi-agent").setup({
  window = {
    position = "float",
    float = {
      width = "90%",
      height = "90%",
      border = "double",
    },
  },
})
```

## Development

### With Nix (recommended)

The project uses [Nix](https://nixos.org/) with [direnv](https://direnv.net/) for development:

```bash
# Allow direnv (first time only)
direnv allow

# Run commands
just test
just lint
just format
```

### Without Nix

Ensure you have installed:

- Neovim 0.10+
- [luacheck](https://github.com/lunarmodules/luacheck)
- [stylua](https://github.com/JohnnyMorganz/StyLua)

```bash
# Run tests
./scripts/test.sh

# Lint
luacheck lua/
```

## Acknowledgements

Based on [claude-code.nvim](https://github.com/greggh/claude-code.nvim) by [@greggh](https://github.com/greggh).

## License

[MIT](LICENSE)
