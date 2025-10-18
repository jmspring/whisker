local helper = require("tests.test_helper")
local EventSystem = require("src.core.event_system")

describe("Event System", function()

  describe("Basic Event System", function()
    it("should create event system instance", function()
      local events = EventSystem.new()
      assert.is_not_nil(events)
      assert.equals("function", type(events.emit))
    end)

    it("should register event listener", function()
      local events = EventSystem.new()
      local called = false

      events:on("test_event", function(event)
        called = true
      end)

      events:emit("test_event")
      assert.is_true(called, "Listener was not called")
    end)

    it("should pass event data to listener", function()
      local events = EventSystem.new()
      local received_data = nil

      events:on("test_event", function(event)
        received_data = event.data
      end)

      events:emit("test_event", {message = "hello"})
      assert.equals("hello", received_data.message)
    end)

    it("should call multiple listeners for same event", function()
      local events = EventSystem.new()
      local count = 0

      events:on("test_event", function() count = count + 1 end)
      events:on("test_event", function() count = count + 1 end)
      events:on("test_event", function() count = count + 1 end)

      events:emit("test_event")
      assert.equals(3, count, "Expected 3 listeners to be called")
    end)
  end)

  describe("Listener Management", function()
    it("should remove listener by ID with off", function()
      local events = EventSystem.new()
      local count = 0

      local id = events:on("test_event", function() count = count + 1 end)
      events:emit("test_event")
      assert.equals(1, count)

      events:off("test_event", id)
      events:emit("test_event")
      assert.equals(1, count, "Listener should not be called after removal")
    end)

    it("should fire once listener only once", function()
      local events = EventSystem.new()
      local count = 0

      events:once("test_event", function() count = count + 1 end)
      events:emit("test_event")
      events:emit("test_event")
      events:emit("test_event")

      assert.equals(1, count, "Once listener should only fire once")
    end)

    it("should remove all listeners for event type with off_all", function()
      local events = EventSystem.new()
      local count = 0

      events:on("test_event", function() count = count + 1 end)
      events:on("test_event", function() count = count + 1 end)

      events:off_all("test_event")
      events:emit("test_event")

      assert.equals(0, count, "No listeners should be called")
    end)

    it("should remove all listeners with off_all and no argument", function()
      local events = EventSystem.new()
      local count1, count2 = 0, 0

      events:on("event1", function() count1 = count1 + 1 end)
      events:on("event2", function() count2 = count2 + 1 end)

      events:off_all()
      events:emit("event1")
      events:emit("event2")

      assert.equals(0, count1)
      assert.equals(0, count2)
    end)
  end)

  describe("Event Context", function()
    it("should pass context to listener", function()
      local events = EventSystem.new()
      local context = {name = "test_context"}
      local received_context = nil

      events:on("test_event", function(ctx, event)
        received_context = ctx
      end, context)

      events:emit("test_event")
      assert.equals("test_context", received_context.name)
    end)
  end)

  describe("Event Propagation", function()
    it("should stop propagation to prevent further listeners", function()
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
      assert.equals(1, count, "Only first listener should be called")
    end)
  end)

  describe("Event Queue", function()
    it("should defer event processing with queue", function()
      local events = EventSystem.new()
      local called = false

      events:on("test_event", function() called = true end)
      events:queue("test_event")

      assert.is_false(called, "Event should not be processed yet")

      events:process_queue()
      assert.is_true(called, "Event should be processed after queue processing")
    end)

    it("should limit number of events in process_queue", function()
      local events = EventSystem.new()
      local count = 0

      events:on("test_event", function() count = count + 1 end)

      for i = 1, 10 do
        events:queue("test_event")
      end

      events:process_queue(3)
      assert.equals(3, count, "Only 3 events should be processed")

      events:process_queue()
      assert.equals(10, count, "All events should be processed now")
    end)

    it("should remove pending events with clear_queue", function()
      local events = EventSystem.new()
      local count = 0

      events:on("test_event", function() count = count + 1 end)

      events:queue("test_event")
      events:queue("test_event")
      events:clear_queue()
      events:process_queue()

      assert.equals(0, count, "No events should be processed")
    end)
  end)

  describe("Event History", function()
    it("should track emitted events", function()
      local events = EventSystem.new()

      events:emit("event1", {data = 1})
      events:emit("event2", {data = 2})

      local history = events:get_history()
      assert.equals(2, #history)
    end)

    it("should filter history by event type", function()
      local events = EventSystem.new()

      events:emit("event1")
      events:emit("event2")
      events:emit("event1")

      local history = events:get_history("event1")
      assert.equals(2, #history, "Should have 2 event1 entries")
    end)

    it("should respect limit in get_history", function()
      local events = EventSystem.new()

      for i = 1, 10 do
        events:emit("test_event")
      end

      local history = events:get_history(nil, 5)
      assert.equals(5, #history, "Should limit to 5 events")
    end)

    it("should remove event history with clear_history", function()
      local events = EventSystem.new()

      events:emit("test_event")
      events:emit("test_event")
      events:clear_history()

      local history = events:get_history()
      assert.equals(0, #history)
    end)
  end)

  describe("Statistics", function()
    it("should return correct statistics", function()
      local events = EventSystem.new()

      events:on("test_event", function() end)
      events:on("test_event", function() end)
      events:emit("test_event")
      events:queue("test_event")

      local stats = events:get_stats()
      assert.equals(1, stats.events_fired)
      assert.equals(1, stats.events_queued)
      assert.equals(2, stats.active_listeners)
    end)

    it("should return listener count for event type", function()
      local events = EventSystem.new()

      events:on("event1", function() end)
      events:on("event1", function() end)
      events:on("event2", function() end)

      assert.equals(2, events:get_listener_count("event1"))
      assert.equals(1, events:get_listener_count("event2"))
      assert.equals(3, events:get_listener_count()) -- Total
    end)
  end)

  describe("Error Handling", function()
    it("should not crash system when listener errors", function()
      local events = EventSystem.new()
      local called_after_error = false

      events:on("test_event", function()
        error("Intentional error")
      end)

      events:on("test_event", function()
        called_after_error = true
      end)

      events:emit("test_event")
      assert.is_true(called_after_error, "Second listener should still be called")
    end)

    it("should count errors in statistics", function()
      local events = EventSystem.new()

      events:on("test_event", function()
        error("Error")
      end)

      events:emit("test_event")

      local stats = events:get_stats()
      assert.equals(1, stats.errors)
    end)
  end)

  describe("Helper Functions", function()
    it("should create passage event data", function()
      local events = EventSystem.new()
      local passage = {name = "start", content = "Hello"}

      local event_data = events:create_passage_event_data(passage, nil)
      assert.equals(passage, event_data.passage)
      assert.equals("start", event_data.passage_name)
    end)

    it("should create choice event data", function()
      local events = EventSystem.new()
      local choice = {text = "Go north", target = "north"}

      local event_data = events:create_choice_event_data(choice, 1, nil)
      assert.equals(choice, event_data.choice)
      assert.equals(1, event_data.choice_index)
      assert.equals("Go north", event_data.choice_text)
    end)

    it("should create variable event data", function()
      local events = EventSystem.new()

      local event_data = events:create_variable_event_data("health", 100, 90)
      assert.equals("health", event_data.variable)
      assert.equals(100, event_data.old_value)
      assert.equals(90, event_data.new_value)
    end)
  end)

  describe("Event Types", function()
    it("should provide EventType enum", function()
      assert.is_not_nil(EventSystem.EventType.PASSAGE_ENTERED)
      assert.is_not_nil(EventSystem.EventType.CHOICE_SELECTED)
      assert.is_not_nil(EventSystem.EventType.VARIABLE_CHANGED)
      assert.is_not_nil(EventSystem.EventType.GAME_STARTED)
    end)
  end)
end)
