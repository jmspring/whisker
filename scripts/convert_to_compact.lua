#!/usr/bin/env lua
-- Convert whisker files from verbose 1.0 to compact 2.0 format

package.path = package.path .. ";./src/?.lua"

local json = require("whisker.utils.json")
local CompactConverter = require("whisker.format.compact_converter")

-- Check arguments
if #arg < 1 then
    print("Usage: lua convert_to_compact.lua <input.whisker> [output.whisker]")
    print("If output file not specified, will overwrite input file")
    os.exit(1)
end

local input_file = arg[1]
local output_file = arg[2] or input_file

-- Read input file
print("Reading: " .. input_file)
local file = io.open(input_file, "r")
if not file then
    print("ERROR: Cannot open file: " .. input_file)
    os.exit(1)
end

local json_text = file:read("*all")
file:close()

-- Parse JSON
print("Parsing JSON...")
local data, err = json.decode(json_text)
if not data then
    print("ERROR: Failed to parse JSON: " .. (err or "unknown error"))
    os.exit(1)
end

-- Check if already compact
local converter = CompactConverter.new()
if converter:is_compact(data) then
    print("File is already in compact format (2.0)")
    os.exit(0)
end

-- Convert to compact
print("Converting to compact format...")
local compact, err = converter:to_compact(data)
if err then
    print("ERROR: Conversion failed: " .. err)
    os.exit(1)
end

-- Calculate savings
local stats = converter:calculate_savings(data, compact, json)
print(string.format("Size reduction: %d bytes -> %d bytes (%d%% smaller)",
    stats.verbose_size, stats.compact_size, stats.savings_percent))

-- Write output
print("Writing: " .. output_file)
local compact_json = json.encode(compact)
local out_file = io.open(output_file, "w")
if not out_file then
    print("ERROR: Cannot write to file: " .. output_file)
    os.exit(1)
end

out_file:write(compact_json)
out_file:close()

print("✓ Conversion complete!")
