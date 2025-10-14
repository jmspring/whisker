#!/usr/bin/env lua
-- Museum Tour Client (CLI)
-- Cross-platform service-oriented client for running Whisker museum tours
-- Foundation for iOS/Android native app implementations

local json = require("src.utils.json")

-- Museum Client Class
local MuseumClient = {}
MuseumClient.__index = MuseumClient

-- Create new museum client instance
function MuseumClient.new()
    local self = setmetatable({}, MuseumClient)
    self.story = nil
    self.current_passage = nil
    self.visited = {}
    self.variables = {}
    self.session_start = os.time()
    self.audio_played_count = 0
    self.language = "en"
    return self
end

--------------------------------------------------------------------------------
-- STORY LOADING
--------------------------------------------------------------------------------

-- Load a museum tour story from file
function MuseumClient:load_story(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil, "Could not open story file: " .. filepath
    end

    local content = file:read("*all")
    file:close()

    local story, err = json.decode(content)
    if not story then
        return nil, "Failed to parse JSON: " .. tostring(err)
    end

    -- Validate story structure
    if not story.passages or #story.passages == 0 then
        return nil, "Story has no passages"
    end

    self.story = story

    -- Initialize variables
    if story.variables then
        for _, var in ipairs(story.variables) do
            self.variables[var.name] = var.initial
        end
    end

    -- Find start passage
    local start_id = "welcome"
    if story.settings and story.settings.startPassage then
        start_id = story.settings.startPassage
    end

    self.current_passage = self:find_passage(start_id)
    if not self.current_passage then
        return nil, "Could not find start passage: " .. start_id
    end

    return true, nil
end

-- Find a passage by ID or name
function MuseumClient:find_passage(identifier)
    if not self.story then
        return nil
    end

    for _, passage in ipairs(self.story.passages) do
        if passage.id == identifier or passage.name == identifier then
            return passage
        end
    end

    return nil
end

--------------------------------------------------------------------------------
-- NAVIGATION
--------------------------------------------------------------------------------

-- Navigate to a passage
function MuseumClient:goto_passage(identifier)
    local passage = self:find_passage(identifier)
    if not passage then
        return false, "Passage not found: " .. identifier
    end

    self.current_passage = passage

    -- Track visit
    if not self.visited[passage.id] then
        self.visited[passage.id] = {
            first_visit = os.time(),
            visit_count = 0
        }
    end

    self.visited[passage.id].visit_count = self.visited[passage.id].visit_count + 1
    self.visited[passage.id].last_visit = os.time()

    -- Update variables
    if self.variables.visited_count then
        self.variables.visited_count = self:get_visited_count()
    end

    return true, nil
end

-- Scan QR code (simulate by entering exhibit ID)
function MuseumClient:scan_qr(qr_code)
    -- Find passage with matching QR code in metadata
    for _, passage in ipairs(self.story.passages) do
        if passage.metadata and passage.metadata.qrCode == qr_code then
            return self:goto_passage(passage.id)
        end
    end

    return false, "No exhibit found for QR code: " .. qr_code
end

-- Get available choices for current passage
function MuseumClient:get_choices()
    if not self.current_passage then
        return {}
    end

    return self.current_passage.choices or {}
end

-- Choose an option
function MuseumClient:choose(choice_index)
    local choices = self:get_choices()

    if choice_index < 1 or choice_index > #choices then
        return false, "Invalid choice: " .. choice_index
    end

    local choice = choices[choice_index]
    return self:goto_passage(choice.target)
end

--------------------------------------------------------------------------------
-- DISPLAY
--------------------------------------------------------------------------------

-- Render current passage to terminal
function MuseumClient:render()
    if not self.current_passage then
        print("No passage loaded")
        return
    end

    -- Clear screen (cross-platform)
    os.execute("clear") or os.execute("cls")

    -- Header
    self:print_header()

    -- Passage content
    print("\n" .. string.rep("=", 80))
    self:print_content(self.current_passage.text)
    print(string.rep("=", 80))

    -- Metadata (audio, QR code, etc.)
    if self.current_passage.metadata then
        self:print_metadata(self.current_passage.metadata)
    end

    -- Choices
    local choices = self:get_choices()
    if #choices > 0 then
        print("\n📍 Choose your next destination:")
        for i, choice in ipairs(choices) do
            print(string.format("  [%d] %s", i, choice.text))
        end
    end

    -- Commands
    print("\n" .. string.rep("-", 80))
    print("Commands: [number] Navigate | [m]ap | [q]r scan | [s]tats | [h]elp | [x] Exit")
    print(string.rep("-", 80))
end

-- Print header with tour info
function MuseumClient:print_header()
    if not self.story or not self.story.metadata then
        return
    end

    local meta = self.story.metadata
    print("\n🏛️  " .. (meta.title or "Museum Tour"))

    if meta.museum then
        print("📍 " .. meta.museum)
    end

    if meta.estimatedTime then
        print("⏱️  Estimated time: " .. meta.estimatedTime)
    end

    -- Progress
    local visited_count = self:get_visited_count()
    local total = #self.story.passages
    local percent = math.floor((visited_count / total) * 100)
    print(string.format("📊 Progress: %d/%d exhibits (%d%%)", visited_count, total, percent))
end

-- Print formatted content (handle markdown-style formatting)
function MuseumClient:print_content(text)
    if not text then
        return
    end

    -- Simple markdown-style rendering for terminal
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        -- Headers
        if line:match("^# ") then
            line = "\n" .. line:gsub("^# ", ""):upper()
        elseif line:match("^## ") then
            line = "\n" .. line:gsub("^## ", "")
        elseif line:match("^### ") then
            line = "  " .. line:gsub("^### ", "")
        end

        -- Bullet points
        if line:match("^%- ") then
            line = "  • " .. line:gsub("^%- ", "")
        end

        -- Audio/image references
        line = line:gsub("%[audio%]%((.-)%)", "🎧 Audio available: %1")
        line = line:gsub("%[image%]%((.-)%)", "🖼️  Image: %1")

        table.insert(lines, line)
    end

    print(table.concat(lines, "\n"))
end

-- Print passage metadata
function MuseumClient:print_metadata(metadata)
    local info = {}

    if metadata.hasAudio and metadata.audioLength then
        table.insert(info, "🎧 Audio guide: " .. metadata.audioLength)
    end

    if metadata.floor then
        table.insert(info, "📍 Floor " .. metadata.floor)
    end

    if metadata.qrCode then
        table.insert(info, "🔲 QR Code: " .. metadata.qrCode)
    end

    if metadata.popularity then
        local stars = string.rep("⭐", metadata.popularity)
        table.insert(info, "Popularity: " .. stars)
    end

    if #info > 0 then
        print("\n" .. table.concat(info, " | "))
    end
end

--------------------------------------------------------------------------------
-- FEATURES
--------------------------------------------------------------------------------

-- Show museum map (list all exhibits)
function MuseumClient:show_map()
    os.execute("clear") or os.execute("cls")
    print("\n🗺️  MUSEUM MAP\n")
    print(string.rep("=", 80))

    local exhibits = {}
    for _, passage in ipairs(self.story.passages) do
        if passage.metadata and passage.metadata.exhibitId then
            local status = self.visited[passage.id] and "✓" or " "
            local floor = passage.metadata.floor or "?"
            local audio = passage.metadata.hasAudio and "🎧" or "  "

            table.insert(exhibits, {
                name = passage.name,
                floor = floor,
                audio = audio,
                status = status,
                qr = passage.metadata.qrCode
            })
        end
    end

    -- Sort by floor
    table.sort(exhibits, function(a, b)
        if a.floor == b.floor then
            return a.name < b.name
        end
        return a.floor < b.floor
    end)

    -- Display
    for _, exhibit in ipairs(exhibits) do
        print(string.format("[%s] Floor %s %s  %s  (QR: %s)",
            exhibit.status, exhibit.floor, exhibit.audio, exhibit.name, exhibit.qr or "N/A"))
    end

    print(string.rep("=", 80))
    print("\nPress Enter to continue...")
    io.read()
end

-- Show visitor statistics
function MuseumClient:show_stats()
    os.execute("clear") or os.execute("cls")
    print("\n📊 VISIT STATISTICS\n")
    print(string.rep("=", 80))

    -- Duration
    local duration_seconds = os.time() - self.session_start
    local minutes = math.floor(duration_seconds / 60)
    print(string.format("⏱️  Tour duration: %d minutes", minutes))

    -- Exhibits visited
    local visited_count = self:get_visited_count()
    local total = #self.story.passages
    local percent = math.floor((visited_count / total) * 100)
    print(string.format("📍 Exhibits visited: %d/%d (%d%%)", visited_count, total, percent))

    -- Audio guides
    print(string.format("🎧 Audio guides played: %d", self.audio_played_count))

    -- Most popular passage
    local most_visited = nil
    local max_visits = 0
    for passage_id, info in pairs(self.visited) do
        if info.visit_count > max_visits then
            max_visits = info.visit_count
            most_visited = self:find_passage(passage_id)
        end
    end

    if most_visited then
        print(string.format("⭐ Most revisited: %s (%d times)", most_visited.name, max_visits))
    end

    -- Variables
    if self.variables and next(self.variables) then
        print("\n📝 Tour Variables:")
        for name, value in pairs(self.variables) do
            print(string.format("  • %s = %s", name, tostring(value)))
        end
    end

    print(string.rep("=", 80))
    print("\nPress Enter to continue...")
    io.read()
end

-- Play audio (simulated - would trigger native audio player on mobile)
function MuseumClient:play_audio(audio_path)
    print(string.format("\n🎧 Playing audio: %s", audio_path))
    print("   (Audio playback would be handled by native player on mobile)")
    self.audio_played_count = self.audio_played_count + 1

    -- Update variables
    if self.variables.audio_count then
        self.variables.audio_count = self.audio_played_count
    end
end

-- Get count of unique passages visited
function MuseumClient:get_visited_count()
    local count = 0
    for _ in pairs(self.visited) do
        count = count + 1
    end
    return count
end

-- Export session data (for analytics or resume)
function MuseumClient:export_session()
    return {
        story_ifid = self.story.metadata and self.story.metadata.ifid,
        session_start = self.session_start,
        duration_seconds = os.time() - self.session_start,
        visited = self.visited,
        variables = self.variables,
        audio_played_count = self.audio_played_count,
        language = self.language
    }
end

--------------------------------------------------------------------------------
-- COMMAND LOOP
--------------------------------------------------------------------------------

-- Show help
function MuseumClient:show_help()
    os.execute("clear") or os.execute("cls")
    print([[

🏛️  MUSEUM TOUR CLIENT - HELP

NAVIGATION:
  [1-9]     Choose a numbered option to navigate to that exhibit
  [m]ap     View museum floor plan and all exhibits
  [q]r      Scan a QR code (enter exhibit QR code)

INFORMATION:
  [s]tats   View your visit statistics
  [h]elp    Show this help screen

ACTIONS:
  [x]       Exit tour and save progress

TIPS:
  • Visit exhibits in any order you prefer
  • Use QR codes on exhibit labels for quick access
  • Check the map to see your progress
  • Audio guides enhance your experience

Press Enter to continue...
]])
    io.read()
end

-- Main command loop
function MuseumClient:run()
    if not self.story then
        print("Error: No story loaded")
        return
    end

    print("\n🏛️  Welcome to the Museum Tour Client")
    print("Type 'h' for help, 'x' to exit\n")
    print("Press Enter to begin...")
    io.read()

    while true do
        self:render()

        -- Get user input
        io.write("\n> ")
        local input = io.read()

        if not input or input == "x" or input == "X" then
            -- Exit
            self:show_stats()
            print("\n👋 Thank you for visiting! Your progress has been saved.\n")
            break

        elseif input == "h" or input == "H" then
            -- Help
            self:show_help()

        elseif input == "m" or input == "M" then
            -- Map
            self:show_map()

        elseif input == "s" or input == "S" then
            -- Stats
            self:show_stats()

        elseif input == "q" or input == "Q" then
            -- QR scan
            print("Enter QR code (e.g., MUSEUM-DINO-001):")
            io.write("> ")
            local qr_code = io.read()
            local success, err = self:scan_qr(qr_code)
            if not success then
                print("❌ " .. err)
                print("Press Enter to continue...")
                io.read()
            end

        elseif tonumber(input) then
            -- Numeric choice
            local choice_num = tonumber(input)
            local success, err = self:choose(choice_num)
            if not success then
                print("❌ " .. err)
                print("Press Enter to continue...")
                io.read()
            end

        else
            print("❌ Unknown command. Type 'h' for help.")
            print("Press Enter to continue...")
            io.read()
        end
    end
end

--------------------------------------------------------------------------------
-- MAIN ENTRY POINT
--------------------------------------------------------------------------------

local function main(args)
    if #args < 1 then
        print([[
Usage: lua museum_client.lua <story_file.whisker>

Example:
  lua museum_client.lua natural_history/story.whisker

This is a cross-platform CLI client for running Whisker museum tours.
It serves as a reference implementation and foundation for native mobile apps.
]])
        return 1
    end

    local story_path = args[1]

    -- Create client
    local client = MuseumClient.new()

    -- Load story
    local success, err = client:load_story(story_path)
    if not success then
        print("Error loading story: " .. err)
        return 1
    end

    -- Run tour
    client:run()

    return 0
end

-- Run if executed directly
if arg and arg[0]:match("museum_client%.lua$") then
    os.exit(main(arg))
end

-- Export for use as module
return MuseumClient
