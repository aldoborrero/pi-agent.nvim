# Pi Agent development commands

# Configuration
lua_path := "lua/"
test_path := "test/"
doc_path := "doc/"

# Run all tests (using Plenary test framework)
test:
    @echo "Running Plenary tests..."
    @./scripts/test.sh

# Run tests in debug mode with verbose output
test-debug:
    @echo "Running tests in debug mode..."
    @echo "LUA_PATH: {{ lua_path }}"
    @which nvim
    @nvim --version
    @echo "Running Plenary tests with debug output..."
    @PLENARY_DEBUG=1 ./scripts/test.sh

# Lint Lua files
lint:
    @echo "Linting Lua files..."
    @luacheck {{ lua_path }}

# Format code
format:
    @nix fmt

# Check formatting (for CI)
format-check:
    @treefmt --fail-on-change

# Generate documentation
docs:
    @echo "Generating documentation..."
    @ldoc -c .ldoc.cfg .

# List available recipes
[private]
default:
    @just --list
