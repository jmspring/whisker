#!/usr/bin/env lua
--[[
Whisker Parser CLI Tool
Comprehensive command-line tool for parsing, validating, and converting Whisker story files

Usage:
  lua scripts/whisker_parse.lua <command> <file> [options]

Commands:
  validate <file>              - Validate a Whisker JSON file
  load <file>                  - Load and display story information
  convert <file> <output>      - Convert between formats (1.0 ↔ 2.0)
  compact <file> <output>      - Convert to compact 2.0 format
  verbose <file> <output>      - Convert to verbose 1.0 format
  stats <file>                 - Show story statistics
  check-links <file>           - Check for broken passage links
  info <file>                  - Show detailed story information

Examples:
  lua scripts/whisker_parse.lua validate story.whisker
  lua scripts/whisker_parse.lua compact story_v1.whisker story_v2.whisker
  lua scripts/whisker_parse.lua stats examples/museum_tours/rijksmuseum/rijksmuseum_tour.whisker
]]

package.path = package.path .. ";./src/?.lua"

local json = require("src.utils.json")
local whisker_loader = require("src.format.whisker_loader")
local CompactConverter = require("src.format.compact_converter")

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

local function print_header(text)
    print("\n" .. string.rep("=", 72))
    print(text)
    print(string.rep("=", 72))
end

local function print_section(text)
    print("\n" .. text)
    print(string.rep("-", 72))
end

local function print_error(text)
    io.stderr:write("❌ ERROR: " .. text .. "\n")
end

local function print_success(text)
    print("✅ " .. text)
end

local function print_warning(text)
    print("⚠️  " .. text)
end

local function read_file(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil, "Failed to open file: " .. filename
    end

    local content = file:read("*all")
    file:close()
    return content
end

local function write_file(filename, content)
    local file = io.open(filename, "w")
    if not file then
        return nil, "Failed to create file: " .. filename
    end

    file:write(content)
    file:close()
    return true
end

local function format_size(bytes)
    if bytes < 1024 then
        return string.format("%d B", bytes)
    elseif bytes < 1024 * 1024 then
        return string.format("%.1f KB", bytes / 1024)
    else
        return string.format("%.1f MB", bytes / (1024 * 1024))
    end
end

--------------------------------------------------------------------------------
-- COMMAND IMPLEMENTATIONS
--------------------------------------------------------------------------------

local function cmd_validate(filename)
    print_header("VALIDATE: " .. filename)

    -- Read file
    local content, err = read_file(filename)
    if not content then
        print_error(err)
        return false
    end

    -- Parse JSON
    local data, err = json.decode(content)
    if not data then
        print_error("JSON parse error: " .. (err or "unknown error"))
        return false
    end

    print_success("Valid JSON")

    -- Validate Whisker format
    local valid, errors = whisker_loader.validate(data)

    if valid then
        print_success("Valid Whisker format")
        print("\nFormat version: " .. (data.formatVersion or "1.0"))
        print("Story title: " .. (data.metadata and data.metadata.title or "N/A"))
        print("Passages: " .. (#data.passages or 0))
        return true
    else
        print_error("Validation failed:")
        for _, error in ipairs(errors) do
            print("  • " .. error)
        end
        return false
    end
end

local function cmd_load(filename)
    print_header("LOAD: " .. filename)

    -- Load story
    local story, err = whisker_loader.load_from_file(filename)
    if not story then
        print_error(err)
        return false
    end

    print_success("Story loaded successfully")

    -- Display information
    print_section("Story Metadata")
    print("  Title:       " .. (story.metadata.name or "N/A"))
    print("  Author:      " .. (story.metadata.author or "N/A"))
    print("  IFID:        " .. (story.metadata.ifid or "N/A"))
    print("  Version:     " .. (story.metadata.version or "N/A"))
    print("  Format:      " .. (story.metadata.format or "N/A"))

    -- Count passages
    local passage_count = 0
    for _ in pairs(story.passages) do
        passage_count = passage_count + 1
    end

    print_section("Story Structure")
    print("  Passages:    " .. passage_count)
    print("  Start:       " .. (story.start_passage or "N/A"))

    -- Count choices
    local total_choices = 0
    for _, passage in pairs(story.passages) do
        if passage.choices then
            for _ in pairs(passage.choices) do
                total_choices = total_choices + 1
            end
        end
    end
    print("  Choices:     " .. total_choices)

    return true
end

local function cmd_convert(input_file, output_file)
    print_header("CONVERT: " .. input_file .. " → " .. output_file)

    -- Read input file
    local content, err = read_file(input_file)
    if not content then
        print_error(err)
        return false
    end

    -- Parse JSON
    local data, err = json.decode(content)
    if not data then
        print_error("JSON parse error: " .. (err or "unknown error"))
        return false
    end

    local converter = CompactConverter.new()
    local input_version = converter:get_format_version(data)
    local output_data, err

    print("Input format:  " .. input_version)

    -- Auto-detect conversion direction
    if input_version == "2.0" then
        print("Output format: 1.0 (verbose)")
        output_data, err = converter:to_verbose(data)
    else
        print("Output format: 2.0 (compact)")
        output_data, err = converter:to_compact(data)
    end

    if err then
        print_error("Conversion failed: " .. err)
        return false
    end

    -- Write output
    local output_json = json.encode(output_data)
    local success, err = write_file(output_file, output_json)

    if not success then
        print_error(err)
        return false
    end

    -- Show savings
    local input_size = #content
    local output_size = #output_json
    local savings = input_size - output_size
    local percent = math.floor((savings / input_size) * 100)

    print_section("Conversion Complete")
    print("  Input size:  " .. format_size(input_size))
    print("  Output size: " .. format_size(output_size))

    if savings > 0 then
        print("  Savings:     " .. format_size(savings) .. " (" .. percent .. "%)")
        print_success("Smaller file created!")
    elseif savings < 0 then
        print("  Increase:    " .. format_size(-savings) .. " (" .. math.abs(percent) .. "%)")
        print_warning("File is larger (added default values)")
    else
        print("  No change in size")
    end

    print_success("Converted successfully: " .. output_file)
    return true
end

local function cmd_compact(input_file, output_file)
    print_header("COMPACT: " .. input_file .. " → " .. output_file)

    -- Read input
    local content, err = read_file(input_file)
    if not content then
        print_error(err)
        return false
    end

    -- Parse JSON
    local data, err = json.decode(content)
    if not data then
        print_error("JSON parse error: " .. (err or "unknown error"))
        return false
    end

    -- Convert to compact
    local converter = CompactConverter.new()
    local compact_data, err = converter:to_compact(data)

    if err then
        print_error("Compact conversion failed: " .. err)
        return false
    end

    -- Write output
    local output_json = json.encode(compact_data)
    local success, err = write_file(output_file, output_json)

    if not success then
        print_error(err)
        return false
    end

    -- Show statistics
    local input_size = #content
    local output_size = #output_json
    local savings = input_size - output_size
    local percent = math.floor((savings / input_size) * 100)

    print_section("Compact Conversion Complete")
    print("  Input size:  " .. format_size(input_size))
    print("  Output size: " .. format_size(output_size))
    print("  Savings:     " .. format_size(savings) .. " (" .. percent .. "%)")
    print_success("Compacted successfully: " .. output_file)
    return true
end

local function cmd_verbose(input_file, output_file)
    print_header("VERBOSE: " .. input_file .. " → " .. output_file)

    -- Read input
    local content, err = read_file(input_file)
    if not content then
        print_error(err)
        return false
    end

    -- Parse JSON
    local data, err = json.decode(content)
    if not data then
        print_error("JSON parse error: " .. (err or "unknown error"))
        return false
    end

    -- Convert to verbose
    local converter = CompactConverter.new()
    local verbose_data, err = converter:to_verbose(data)

    if err then
        print_error("Verbose conversion failed: " .. err)
        return false
    end

    -- Write output
    local output_json = json.encode(verbose_data)
    local success, err = write_file(output_file, output_json)

    if not success then
        print_error(err)
        return false
    end

    print_success("Converted to verbose format: " .. output_file)
    return true
end

local function cmd_stats(filename)
    print_header("STATISTICS: " .. filename)

    -- Read file
    local content, err = read_file(filename)
    if not content then
        print_error(err)
        return false
    end

    -- Parse JSON
    local data, err = json.decode(content)
    if not data then
        print_error("JSON parse error: " .. (err or "unknown error"))
        return false
    end

    -- Load as story
    local story, err = whisker_loader.load_from_string(content)
    if not story then
        print_error("Failed to load story: " .. err)
        return false
    end

    -- Calculate statistics
    local passage_count = 0
    local choice_count = 0
    local total_text_length = 0
    local total_words = 0
    local passages_with_choices = 0
    local max_choices = 0

    for _, passage in pairs(story.passages) do
        passage_count = passage_count + 1

        local content = passage.content or ""
        total_text_length = total_text_length + #content

        -- Count words (simple word count)
        for _ in content:gmatch("%S+") do
            total_words = total_words + 1
        end

        -- Count choices
        local passage_choice_count = 0
        if passage.choices then
            for _ in pairs(passage.choices) do
                choice_count = choice_count + 1
                passage_choice_count = passage_choice_count + 1
            end
        end

        if passage_choice_count > 0 then
            passages_with_choices = passages_with_choices + 1
        end

        max_choices = math.max(max_choices, passage_choice_count)
    end

    -- Display statistics
    print_section("File Statistics")
    print("  File size:   " .. format_size(#content))
    print("  Format:      Whisker " .. (data.formatVersion or "1.0"))

    print_section("Story Statistics")
    print("  Passages:    " .. passage_count)
    print("  Total words: " .. total_words)
    print("  Avg words/passage: " .. math.floor(total_words / math.max(passage_count, 1)))
    print("  Total characters:  " .. total_text_length)

    print_section("Choice Statistics")
    print("  Total choices:     " .. choice_count)
    print("  Passages w/choices: " .. passages_with_choices .. " (" ..
          math.floor(passages_with_choices / math.max(passage_count, 1) * 100) .. "%)")
    print("  Avg choices/passage: " .. string.format("%.1f", choice_count / math.max(passage_count, 1)))
    print("  Max choices: " .. max_choices)

    return true
end

local function cmd_check_links(filename)
    print_header("CHECK LINKS: " .. filename)

    -- Load story
    local story, err = whisker_loader.load_from_file(filename)
    if not story then
        print_error(err)
        return false
    end

    -- Build passage index
    local passage_ids = {}
    for id in pairs(story.passages) do
        passage_ids[id] = true
    end

    -- Check all choice targets
    local broken_links = {}
    local total_links = 0

    for passage_id, passage in pairs(story.passages) do
        if passage.choices then
            for _, choice in pairs(passage.choices) do
                total_links = total_links + 1
                -- Choice class stores target as target_passage
                local target = choice.target_passage or choice.target

                if target and not passage_ids[target] then
                    table.insert(broken_links, {
                        source = passage_id,
                        target = target,
                        text = choice.text
                    })
                elseif not target then
                    table.insert(broken_links, {
                        source = passage_id,
                        target = "(nil)",
                        text = choice.text
                    })
                end
            end
        end
    end

    -- Display results
    print_section("Link Check Results")
    print("  Total links checked: " .. total_links)
    print("  Broken links found:  " .. #broken_links)

    if #broken_links > 0 then
        print_warning("Found " .. #broken_links .. " broken link(s):")
        for _, link in ipairs(broken_links) do
            print(string.format('  • "%s" → "%s" (in passage "%s")',
                link.text, link.target, link.source))
        end
        return false
    else
        print_success("All links are valid!")
        return true
    end
end

local function cmd_info(filename)
    print_header("INFO: " .. filename)

    -- Read file
    local content, err = read_file(filename)
    if not content then
        print_error(err)
        return false
    end

    -- Parse JSON
    local data, err = json.decode(content)
    if not data then
        print_error("JSON parse error: " .. (err or "unknown error"))
        return false
    end

    -- Load as story
    local story, err = whisker_loader.load_from_string(content)
    if not story then
        print_error("Failed to load story: " .. err)
        return false
    end

    -- Display detailed information
    print_section("File Information")
    print("  Filename:    " .. filename)
    print("  Size:        " .. format_size(#content))
    print("  Format:      Whisker " .. (data.formatVersion or "1.0"))

    print_section("Metadata")
    for key, value in pairs(story.metadata or {}) do
        print(string.format("  %-14s %s", key .. ":", tostring(value)))
    end

    -- List all passages
    print_section("Passages (" .. (#data.passages or 0) .. " total)")

    local passage_list = {}
    for id, passage in pairs(story.passages) do
        table.insert(passage_list, {
            id = id,
            passage = passage
        })
    end

    -- Sort by ID
    table.sort(passage_list, function(a, b) return a.id < b.id end)

    for i, item in ipairs(passage_list) do
        local passage = item.passage
        local choice_count = 0
        if passage.choices then
            for _ in pairs(passage.choices) do
                choice_count = choice_count + 1
            end
        end

        local word_count = 0
        local content = passage.content or ""
        for _ in content:gmatch("%S+") do
            word_count = word_count + 1
        end

        local marker = (item.id == story.start_passage) and " [START]" or ""
        print(string.format("  %2d. %-30s (%d choices, %d words)%s",
            i, item.id, choice_count, word_count, marker))
    end

    return true
end

--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

local function show_usage()
    print([[
Whisker Parser CLI Tool

Usage:
  lua scripts/whisker_parse.lua <command> <file> [options]

Commands:
  validate <file>              - Validate a Whisker JSON file
  load <file>                  - Load and display story information
  convert <file> <output>      - Convert between formats (1.0 ↔ 2.0)
  compact <file> <output>      - Convert to compact 2.0 format
  verbose <file> <output>      - Convert to verbose 1.0 format
  stats <file>                 - Show story statistics
  check-links <file>           - Check for broken passage links
  info <file>                  - Show detailed story information

Examples:
  lua scripts/whisker_parse.lua validate story.whisker
  lua scripts/whisker_parse.lua compact story_v1.whisker story_v2.whisker
  lua scripts/whisker_parse.lua stats examples/museum_tours/rijksmuseum/rijksmuseum_tour.whisker
]])
end

local function main(args)
    if #args < 2 then
        show_usage()
        os.exit(1)
    end

    local command = args[1]
    local file = args[2]
    local output = args[3]

    local commands = {
        validate = function() return cmd_validate(file) end,
        load = function() return cmd_load(file) end,
        convert = function()
            if not output then
                print_error("Output file required for convert command")
                return false
            end
            return cmd_convert(file, output)
        end,
        compact = function()
            if not output then
                print_error("Output file required for compact command")
                return false
            end
            return cmd_compact(file, output)
        end,
        verbose = function()
            if not output then
                print_error("Output file required for verbose command")
                return false
            end
            return cmd_verbose(file, output)
        end,
        stats = function() return cmd_stats(file) end,
        ["check-links"] = function() return cmd_check_links(file) end,
        info = function() return cmd_info(file) end
    }

    local cmd_func = commands[command]
    if not cmd_func then
        print_error("Unknown command: " .. command)
        show_usage()
        os.exit(1)
    end

    local success = cmd_func()
    os.exit(success and 0 or 1)
end

main(arg)
