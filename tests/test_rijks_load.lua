#!/usr/bin/env lua
-- Test loading the Rijksmuseum tour with whisker_loader

package.path = package.path .. ";./src/?.lua"

local whisker_loader = require("src.format.whisker_loader")
local json = require("src.utils.json")

print("Testing Rijksmuseum Tour Loading")
print("=" .. string.rep("=", 70))

-- Load the file
local filename = "examples/museum_tours/rijksmuseum/rijksmuseum_tour.whisker"
print("\nLoading: " .. filename)

local story, err = whisker_loader.load_from_file(filename)

if err then
    print("❌ ERROR: " .. err)
    os.exit(1)
end

if not story then
    print("❌ ERROR: Failed to load story (nil returned)")
    os.exit(1)
end

print("✅ Story loaded successfully!")
print()
print("Story Details:")
print("  Title: " .. (story.metadata.name or "N/A"))
print("  Author: " .. (story.metadata.author or "N/A"))
print("  IFID: " .. (story.metadata.ifid or "N/A"))
print("  Version: " .. (story.metadata.version or "N/A"))
print()

-- Also print full metadata for debugging
print("Full Metadata:")
for k, v in pairs(story.metadata or {}) do
    print("  " .. k .. ": " .. tostring(v))
end
print()

-- Count passages
local passage_count = 0
local passage_names = {}
for id, passage in pairs(story.passages or {}) do
    passage_count = passage_count + 1
    table.insert(passage_names, passage.id)
end

table.sort(passage_names)

print("Passages: " .. passage_count)
print("  Start passage: " .. (story.start_passage or "N/A"))
print()

-- Show first few passages
print("First 10 passages:")
for i = 1, math.min(10, #passage_names) do
    local passage = story.passages[passage_names[i]]
    local choice_count = 0
    if passage.choices then
        for _ in pairs(passage.choices) do
            choice_count = choice_count + 1
        end
    end
    print(string.format("  %2d. %-30s (%d choices)", i, passage.id, choice_count))
end

if #passage_names > 10 then
    print(string.format("  ... and %d more passages", #passage_names - 10))
end

print()
print("=" .. string.rep("=", 70))
print("✅ Rijksmuseum tour loaded successfully!")
print()
