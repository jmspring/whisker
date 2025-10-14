-- tests/test_all.lua
-- Master test runner for whisker engine
-- Runs all tests and reports results

local test_results = {
    passed = 0,
    failed = 0,
    skipped = 0,
    tests = {}
}

-- ANSI color codes (optional)
local colors = {
    reset = "\027[0m",
    red = "\027[31m",
    green = "\027[32m",
    yellow = "\027[33m",
    blue = "\027[34m",
    magenta = "\027[35m",
    cyan = "\027[36m",
    bold = "\027[1m"
}

-- Helper function to colorize text (disable if terminal doesn't support)
local function colorize(text, color)
    if os.getenv("NO_COLOR") then
        return text
    end
    return (colors[color] or "") .. text .. colors.reset
end

-- Helper function to run a test
local function run_test(name, test_file, description)
    print("\n" .. string.rep("=", 70))
    print(colorize("Running: " .. name, "cyan"))
    if description then
        print(colorize("  " .. description, "blue"))
    end
    print(string.rep("=", 70))

    -- Check if test file exists
    local file = io.open(test_file, "r")
    if not file then
        test_results.skipped = test_results.skipped + 1
        table.insert(test_results.tests, {
            name = name,
            status = "SKIPPED",
            error = "Test file not found: " .. test_file
        })
        print(colorize("⊘ " .. name .. " SKIPPED (file not found)", "yellow"))
        return
    end
    file:close()

    -- Run the test
    local start_time = os.clock()
    local success, err = pcall(function()
        dofile(test_file)
    end)
    local duration = os.clock() - start_time

    if success then
        test_results.passed = test_results.passed + 1
        table.insert(test_results.tests, {
            name = name,
            status = "PASSED",
            duration = duration,
            error = nil
        })
        print(colorize("✅ " .. name .. " PASSED", "green") ..
              string.format(" (%.3fs)", duration))
    else
        test_results.failed = test_results.failed + 1
        table.insert(test_results.tests, {
            name = name,
            status = "FAILED",
            duration = duration,
            error = tostring(err)
        })
        print(colorize("❌ " .. name .. " FAILED", "red"))
        print(colorize("Error: " .. tostring(err), "red"))
    end
end

-- Print header
print([[
╔════════════════════════════════════════════════════════════════════╗
║                 whisker Engine - Test Suite v1.0                  ║
║                  Interactive Fiction Engine Tests                   ║
╚════════════════════════════════════════════════════════════════════╝
]])

print(colorize("\nStarting test execution...", "bold"))
print("Test suite location: tests/")
print("Date: " .. os.date("%Y-%m-%d %H:%M:%S"))

local suite_start = os.clock()

-- Run all tests
print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 1: CORE ENGINE TESTS", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Basic Engine Test",
    "tests/test_story.lua",
    "Tests story creation, passages, choices, and basic navigation"
)

run_test(
    "Renderer Test",
    "tests/test_renderer.lua",
    "Tests text rendering, markdown formatting, and variable substitution"
)

run_test(
    "Metatable Preservation Test",
    "tests/test_metatable_preservation.lua",
    "Tests metatable preservation across save/load cycles"
)

run_test(
    "String Utils Test",
    "tests/test_string_utils.lua",
    "Tests string manipulation, formatting, and template functions"
)

run_test(
    "Event System Test",
    "tests/test_event_system.lua",
    "Tests event registration, emission, and listener management"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 2: VALIDATION & ANALYSIS", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Validator Test",
    "tests/test_validator.lua",
    "Tests story validation, dead link detection, and variable analysis"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 3: PERFORMANCE & DEBUGGING", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Profiler Test",
    "tests/test_profiler.lua",
    "Tests performance profiling and metrics collection"
)

run_test(
    "Debugger Test",
    "tests/test_debugger.lua",
    "Tests debugging features, breakpoints, and watches"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 4: FORMAT CONVERSION", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Twine Import Test",
    "tests/test_import.lua",
    "Tests importing stories from Twine HTML and Twee formats"
)

run_test(
    "Harlowe Converter Test",
    "tests/test_harlowe_converter.lua",
    "Tests Harlowe format conversion to/from other formats"
)

run_test(
    "SugarCube Converter Test",
    "tests/test_sugarcube_converter.lua",
    "Tests SugarCube format conversion to/from other formats"
)

run_test(
    "Chapbook Converter Test",
    "tests/test_chapbook_converter.lua",
    "Tests Chapbook format conversion to/from other formats"
)

run_test(
    "Snowman Converter Test",
    "tests/test_snoman_converter.lua",
    "Tests Snowman format conversion to/from other formats"
)

run_test(
    "Converter Roundtrip Test",
    "tests/test_converter_roundtrip.lua",
    "Tests round-trip conversion between different formats"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 5: PERSISTENCE", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Save System Test",
    "tests/test_save_system.lua",
    "Tests save/load functionality, autosave, and quick save"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 6: HARLOWE FORMAT TESTS", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Harlowe Combat Test",
    "tests/harlowe/test_combat.lua",
    "Tests Harlowe combat system implementation"
)

run_test(
    "Harlowe Data Structures Test",
    "tests/harlowe/test_datastructures.lua",
    "Tests Harlowe data structure handling"
)

run_test(
    "Harlowe Inventory Test",
    "tests/harlowe/test_inventory.lua",
    "Tests Harlowe inventory system"
)

run_test(
    "Harlowe Storylets Test",
    "tests/harlowe/test_storylets.lua",
    "Tests Harlowe storylet system"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 7: SUGARCUBE FORMAT TESTS", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "SugarCube Combat Test",
    "tests/sugarcube/test_combat.lua",
    "Tests SugarCube combat system implementation"
)

run_test(
    "SugarCube Inventory Test",
    "tests/sugarcube/test_inventory.lua",
    "Tests SugarCube inventory system"
)

run_test(
    "SugarCube Save Test",
    "tests/sugarcube/test_save.lua",
    "Tests SugarCube save functionality"
)

run_test(
    "SugarCube Shop Test",
    "tests/sugarcube/test_shop.lua",
    "Tests SugarCube shop system"
)

run_test(
    "SugarCube Time Test",
    "tests/sugarcube/test_time.lua",
    "Tests SugarCube time tracking system"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 8: SNOWMAN FORMAT TESTS", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Snowman Basic Test",
    "tests/snowman/test_basic.lua",
    "Tests basic Snowman format features"
)

run_test(
    "Snowman Combat Test",
    "tests/snowman/test_combat.lua",
    "Tests Snowman combat system implementation"
)

run_test(
    "Snowman Quest Test",
    "tests/snowman/test_quest.lua",
    "Tests Snowman quest system"
)

run_test(
    "Snowman Shop Test",
    "tests/snowman/test_shop.lua",
    "Tests Snowman shop system"
)

print(colorize("\n" .. string.rep("━", 70), "bold"))
print(colorize("PHASE 9: CHAPBOOK FORMAT TESTS", "bold"))
print(colorize(string.rep("━", 70), "bold"))

run_test(
    "Chapbook Conditionals Test",
    "tests/chapbook/test_confitionals.lua",
    "Tests Chapbook conditional logic"
)

run_test(
    "Chapbook Inserts Test",
    "tests/chapbook/test_inserts.lua",
    "Tests Chapbook insert functionality"
)

run_test(
    "Chapbook Modifiers Test",
    "tests/chapbook/test_modifiers.lua",
    "Tests Chapbook modifier system"
)

run_test(
    "Chapbook Variables Test",
    "tests/chapbook/test_variables.lua",
    "Tests Chapbook variable handling"
)

local suite_duration = os.clock() - suite_start

-- Print summary
print("\n" .. string.rep("═", 70))
print(colorize("TEST SUITE SUMMARY", "bold"))
print(string.rep("═", 70))

local total_tests = test_results.passed + test_results.failed + test_results.skipped
print(string.format("Total Tests:     %d", total_tests))
print(colorize(string.format("Passed:          %d ✅", test_results.passed), "green"))

if test_results.failed > 0 then
    print(colorize(string.format("Failed:          %d ❌", test_results.failed), "red"))
else
    print(string.format("Failed:          %d", test_results.failed))
end

if test_results.skipped > 0 then
    print(colorize(string.format("Skipped:         %d ⊘", test_results.skipped), "yellow"))
end

print(string.format("Total Duration:  %.3f seconds", suite_duration))
print(string.rep("═", 70))

-- Calculate pass rate
local pass_rate = 0
if total_tests > 0 then
    pass_rate = (test_results.passed / total_tests) * 100
end
print(string.format("Pass Rate:       %.1f%%", pass_rate))

-- Print detailed results if there were failures
if test_results.failed > 0 then
    print(colorize("\n" .. string.rep("═", 70), "red"))
    print(colorize("FAILED TESTS DETAILS", "red"))
    print(colorize(string.rep("═", 70), "red"))

    for _, test in ipairs(test_results.tests) do
        if test.status == "FAILED" then
            print(colorize("\n❌ " .. test.name, "red"))
            print(colorize("   Duration: " .. string.format("%.3fs", test.duration), "yellow"))
            print(colorize("   Error:", "red"))
            -- Print error with indentation
            for line in test.error:gmatch("[^\n]+") do
                print(colorize("     " .. line, "red"))
            end
        end
    end
end

-- Print skipped tests if any
if test_results.skipped > 0 then
    print(colorize("\n" .. string.rep("═", 70), "yellow"))
    print(colorize("SKIPPED TESTS", "yellow"))
    print(colorize(string.rep("═", 70), "yellow"))

    for _, test in ipairs(test_results.tests) do
        if test.status == "SKIPPED" then
            print(colorize("⊘ " .. test.name, "yellow"))
            print(colorize("  Reason: " .. test.error, "yellow"))
        end
    end

    print(colorize("\nNote: Create missing test files to run skipped tests", "yellow"))
end

-- Print final status
print("\n" .. string.rep("═", 70))
if test_results.failed == 0 and test_results.skipped == 0 then
    print(colorize("🎉 ALL TESTS PASSED! 🎉", "green"))
    print(colorize("The whisker engine is working correctly.", "green"))
elseif test_results.failed == 0 and test_results.skipped > 0 then
    print(colorize("✅ All available tests passed", "green"))
    print(colorize("⚠️  Some tests were skipped - create missing test files", "yellow"))
else
    print(colorize("⚠️  SOME TESTS FAILED ⚠️", "red"))
    print(colorize("Please review the errors above and fix the issues.", "red"))
end
print(string.rep("═", 70) .. "\n")

-- Generate test report file
local report_file = io.open("tests/test_report.txt", "w")
if report_file then
    report_file:write("whisker Test Suite Report\n")
    report_file:write(string.rep("=", 70) .. "\n")
    report_file:write("Date: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    report_file:write(string.format("Total Tests: %d\n", total_tests))
    report_file:write(string.format("Passed: %d\n", test_results.passed))
    report_file:write(string.format("Failed: %d\n", test_results.failed))
    report_file:write(string.format("Skipped: %d\n", test_results.skipped))
    report_file:write(string.format("Duration: %.3fs\n", suite_duration))
    report_file:write(string.format("Pass Rate: %.1f%%\n", pass_rate))
    report_file:write("\nDetailed Results:\n")
    report_file:write(string.rep("-", 70) .. "\n")

    for _, test in ipairs(test_results.tests) do
        report_file:write(string.format("\n%s: %s\n", test.name, test.status))
        if test.duration then
            report_file:write(string.format("  Duration: %.3fs\n", test.duration))
        end
        if test.error then
            report_file:write("  Error: " .. test.error .. "\n")
        end
    end

    report_file:close()
    print("Test report saved to: tests/test_report.txt")
end

-- Exit with appropriate code
local exit_code = 0
if test_results.failed > 0 then
    exit_code = 1
elseif test_results.skipped > 0 then
    exit_code = 2  -- Different code for skipped tests
end

os.exit(exit_code)
