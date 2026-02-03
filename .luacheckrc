std = "luajit"
globals = { "vim" }

max_line_length = 120
max_cyclomatic_complexity = 20

-- Allow unused self in methods
self = false

files["lua/pi-agent/config.lua"] = {
  max_cyclomatic_complexity = 30,
}

files["scripts/**/*.lua"] = {
  globals = { "print", "arg" },
}

files["tests/**/*.lua"] = {
  globals = { "describe", "it", "before_each", "after_each", "print", "dofile", "_G" },
}
