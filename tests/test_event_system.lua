-- tests/test_event_system.lua
-- Comprehensive tests for event system

local EventSystem = require("src.core.event_system")

print("=== Event System Test Suite ===\n")

local tests_passed = 0
local tests_failed = 0

local function test(name, fn)
    local success, err = pcall(fn)
    if success then
        print("✅ " .. name)
        tests_passed = tests_passed + 1
    else
        print("❌ " .. name)
        print("   Error: " .. tostring(err))
        tests_failed = tests_failed + 1
    end
end

-- Basic event registration and emission
print("--- Basic Event System ---")

test("creates event system instance", function()
    local events = EventSystem.new()
    assert(events ~= nil)
    assert(type(events.emit) == "function")
end)

test("registers event listener", function()
    local events = EventSystem.new()
    local called = false

    events:on("test_event", function(event)
        called = true
    end)

    events:emit("test_event")
    assert(called == true, "Listener was not called")
end)

test("listener receives event data", function()
    local events = EventSystem.new()
    local received_data = nil

    events:on("test_event", function(event)
        received_data = event.data
    end)

    events:emit("test_event", {message = "hello"})
    assert(received_data.message == "hello")
end)

test("multiple listeners receive same event", function()
    local events = EventSystem.new()
    local count = 0

    events:on("test_event", function() count = count + 1 end)
    events:on("test_event", function() count = count + 1 end)
    events:on("test_event", function() count = count + 1 end)

    events:emit("test_event")
    assert(count == 3, "Expected 3 listeners to be called")
end)

-- Listener management
print("\n--- Listener Management ---")

test("off removes listener by ID", function()
    local events = EventSystem.new()
    local count = 0

    local id = events:on("test_event", function() count = count + 1 end)
    events:emit("test_event")
    assert(count == 1)

    events:off("test_event", id)
    events:emit("test_event")
    assert(count == 1, "Listener should not be called after removal")
end)

test("once listener fires only once", function()
    local events = EventSystem.new()
    local count = 0

    events:once("test_event", function() count = count + 1 end)
    events:emit("test_event")
    events:emit("test_event")
    events:emit("test_event")

    assert(count == 1, "Once listener should only fire once")
end)

test("off_all removes all listeners for event type", function()
    local events = EventSystem.new()
    local count = 0

    events:on("test_event", function() count = count + 1 end)
    events:on("test_event", function() count = count + 1 end)

    events:off_all("test_event")
    events:emit("test_event")

    assert(count == 0, "No listeners should be called")
end)

test("off_all with no argument removes all listeners", function()
    local events = EventSystem.new()
    local count1, count2 = 0, 0

    events:on("event1", function() count1 = count1 + 1 end)
    events:on("event2", function() count2 = count2 + 1 end)

    events:off_all()
    events:emit("event1")
    events:emit("event2")

    assert(count1 == 0 and count2 == 0)
end)

-- Event context
print("\n--- Event Context ---")

test("listener receives context", function()
    local events = EventSystem.new()
    local context = {name = "test_context"}
    local received_context = nil

    events:on("test_event", function(ctx, event)
        received_context = ctx
    end, context)

    events:emit("test_event")
    assert(received_context.name == "test_context")
end)

-- Event propagation
print("\n--- Event Propagation ---")

test("stop_propagation prevents further listeners", function()
    local events = EventSystem.new()
    local count = 0

    events:on("test_event", function(event)
        count = count + 1
        events:stop_propagation(event)
    end)

    events:on("test_event", function()
        count = count + 1
    end)

    events:emit("test_event")
    assert(count == 1, "Only first listener should be called")
end)

-- Event queue
print("\n--- Event Queue ---")

test("queue defers event processing", function()
    local events = EventSystem.new()
    local called = false

    events:on("test_event", function() called = true end)
    events:queue("test_event")

    assert(called == false, "Event should not be processed yet")

    events:process_queue()
    assert(called == true, "Event should be processed after queue processing")
end)

test("process_queue limits number of events", function()
    local events = EventSystem.new()
    local count = 0

    events:on("test_event", function() count = count + 1 end)

    for i = 1, 10 do
        events:queue("test_event")
    end

    events:process_queue(3)
    assert(count == 3, "Only 3 events should be processed")

    events:process_queue()
    assert(count == 10, "All events should be processed now")
end)

test("clear_queue removes pending events", function()
    local events = EventSystem.new()
    local count = 0

    events:on("test_event", function() count = count + 1 end)

    events:queue("test_event")
    events:queue("test_event")
    events:clear_queue()
    events:process_queue()

    assert(count == 0, "No events should be processed")
end)

-- Event history
print("\n--- Event History ---")

test("event history tracks emitted events", function()
    local events = EventSystem.new()

    events:emit("event1", {data = 1})
    events:emit("event2", {data = 2})

    local history = events:get_history()
    assert(#history == 2)
end)

test("get_history filters by event type", function()
    local events = EventSystem.new()

    events:emit("event1")
    events:emit("event2")
    events:emit("event1")

    local history = events:get_history("event1")
    assert(#history == 2, "Should have 2 event1 entries")
end)

test("get_history respects limit", function()
    local events = EventSystem.new()

    for i = 1, 10 do
        events:emit("test_event")
    end

    local history = events:get_history(nil, 5)
    assert(#history == 5, "Should limit to 5 events")
end)

test("clear_history removes event history", function()
    local events = EventSystem.new()

    events:emit("test_event")
    events:emit("test_event")
    events:clear_history()

    local history = events:get_history()
    assert(#history == 0)
end)

-- Statistics
print("\n--- Statistics ---")

test("get_stats returns correct statistics", function()
    local events = EventSystem.new()

    events:on("test_event", function() end)
    events:on("test_event", function() end)
    events:emit("test_event")
    events:queue("test_event")

    local stats = events:get_stats()
    assert(stats.events_fired == 1)
    assert(stats.events_queued == 1)
    assert(stats.active_listeners == 2)
end)

test("get_listener_count returns count for event type", function()
    local events = EventSystem.new()

    events:on("event1", function() end)
    events:on("event1", function() end)
    events:on("event2", function() end)

    assert(events:get_listener_count("event1") == 2)
    assert(events:get_listener_count("event2") == 1)
    assert(events:get_listener_count() == 3) -- Total
end)

-- Error handling
print("\n--- Error Handling ---")

test("errors in listeners don't crash system", function()
    local events = EventSystem.new()
    local called_after_error = false

    events:on("test_event", function()
        error("Intentional error")
    end)

    events:on("test_event", function()
        called_after_error = true
    end)

    events:emit("test_event")
    assert(called_after_error == true, "Second listener should still be called")
end)

test("errors are counted in statistics", function()
    local events = EventSystem.new()

    events:on("test_event", function()
        error("Error")
    end)

    events:emit("test_event")

    local stats = events:get_stats()
    assert(stats.errors == 1)
end)

-- Helper functions
print("\n--- Helper Functions ---")

test("create_passage_event_data creates correct structure", function()
    local events = EventSystem.new()
    local passage = {name = "start", content = "Hello"}

    local event_data = events:create_passage_event_data(passage, nil)
    assert(event_data.passage == passage)
    assert(event_data.passage_name == "start")
end)

test("create_choice_event_data creates correct structure", function()
    local events = EventSystem.new()
    local choice = {text = "Go north", target = "north"}

    local event_data = events:create_choice_event_data(choice, 1, nil)
    assert(event_data.choice == choice)
    assert(event_data.choice_index == 1)
    assert(event_data.choice_text == "Go north")
end)

test("create_variable_event_data creates correct structure", function()
    local events = EventSystem.new()

    local event_data = events:create_variable_event_data("health", 100, 90)
    assert(event_data.variable == "health")
    assert(event_data.old_value == 100)
    assert(event_data.new_value == 90)
end)

-- Event types enumeration
print("\n--- Event Types ---")

test("EventType enum is available", function()
    assert(EventSystem.EventType.PASSAGE_ENTERED ~= nil)
    assert(EventSystem.EventType.CHOICE_SELECTED ~= nil)
    assert(EventSystem.EventType.VARIABLE_CHANGED ~= nil)
    assert(EventSystem.EventType.GAME_STARTED ~= nil)
end)

-- Summary
print("\n" .. string.rep("=", 60))
print(string.format("Tests Passed: %d ✅", tests_passed))
print(string.format("Tests Failed: %d %s", tests_failed, tests_failed > 0 and "❌" or ""))
print(string.rep("=", 60))

if tests_failed > 0 then
    os.exit(1)
end
