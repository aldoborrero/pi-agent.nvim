#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PLUGIN_DIR"
echo "Running tests from: $(pwd)"

# Find nvim - ignore NVIM env var if it points to a socket
if [ -n "$NVIM" ] && [ -x "$NVIM" ] && [ ! -S "$NVIM" ]; then
  echo "Using NVIM from environment: $NVIM"
else
  if ! NVIM=$(command -v nvim); then
    echo "Error: nvim not found in PATH"
    exit 1
  fi
fi

echo "Running tests with $NVIM"

$NVIM --headless --noplugin -u tests/minimal-init.lua -c "luafile tests/run_tests.lua"
