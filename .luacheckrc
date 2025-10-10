-- Luacheck configuration for Whisker
std = "lua54"

-- Ignore warnings about line length
codes = true

-- Global variables that are okay to use
globals = {
    "love",  -- LÖVE framework
}

-- Read-only globals
read_globals = {
    "love",
}

-- Exclude certain warnings
ignore = {
    "212",  -- Unused argument
    "213",  -- Unused loop variable
}

-- Exclude build and vendor directories
exclude_files = {
    "build/",
    "dist/",
    "vendor/",
    ".luarocks/",
}
