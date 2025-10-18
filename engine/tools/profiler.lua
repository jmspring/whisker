-- whisker Performance Profiler
-- Tracks execution time, memory usage, instruction counts, and provides optimization recommendations
-- for story performance analysis and optimization

local Profiler = {}
Profiler.__index = Profiler

-- Profiling modes
Profiler.ProfileMode = {
    OFF = "off",
    BASIC = "basic",       -- Basic timing only
    DETAILED = "detailed", -- Detailed metrics
    MEMORY = "memory",     -- Memory profiling
    FULL = "full"          -- All metrics
}

-- Metric types
Profiler.MetricType = {
    TIME = "time",
    MEMORY = "memory",
    INSTRUCTIONS = "instructions",
    CALLS = "calls"
}

-- Create new profiler instance
function Profiler.new(engine, game_state)
    local self = setmetatable({}, Profiler)

    self.engine = engine
    self.game_state = game_state

    -- Profiling state
    self.mode = Profiler.ProfileMode.OFF
    self.active = false
    self.session_start = nil

    -- Metrics storage
    self.metrics = {
        passages = {},      -- Per-passage metrics
        choices = {},       -- Per-choice metrics
        lua_code = {},      -- Lua execution metrics
        overall = {}        -- Overall session metrics
    }

    -- Timing data
    self.timers = {}
    self.current_timer = nil

    -- Memory tracking
    self.memory_snapshots = {}
    self.memory_baseline = 0

    -- Instruction counting
    self.instruction_counts = {}

    -- Thresholds for warnings
    self.thresholds = {
        passage_time_ms = 100,     -- Warn if passage takes > 100ms
        memory_increase_kb = 100,  -- Warn if memory increases > 100KB
        instruction_count = 10000  -- Warn if > 10k instructions
    }

    -- Statistics
    self.stats = {
        total_time_ms = 0,
        total_passages = 0,
        total_choices = 0,
        total_lua_calls = 0,
        peak_memory_kb = 0,
        average_passage_time_ms = 0
    }

    return self
end

-- Start profiling session
function Profiler:start(mode)
    self.mode = mode or Profiler.ProfileMode.BASIC
    self.active = true
    self.session_start = self:get_time_ms()

    -- Take baseline memory snapshot
    self.memory_baseline = self:get_memory_kb()

    -- Setup hooks
    self:setup_hooks()

    self:log("Profiler started in " .. self.mode .. " mode")
end

-- Stop profiling session
function Profiler:stop()
    if not self.active then
        return
    end

    self.active = false

    -- Calculate final statistics
    self:calculate_final_stats()

    -- Remove hooks
    self:remove_hooks()

    self:log("Profiler stopped")
end

-- Setup engine hooks
function Profiler:setup_hooks()
    -- Store original methods
    self.original_navigate = self.engine.navigate_to_passage
    self.original_make_choice = self.engine.make_choice

    local profiler = self

    -- Hook passage navigation
    self.engine.navigate_to_passage = function(engine, passage_id)
        profiler:start_timer("passage_" .. passage_id)
        local result = profiler.original_navigate(engine, passage_id)
        profiler:stop_timer("passage_" .. passage_id)
        profiler:record_passage_metrics(passage_id)
        return result
    end

    -- Hook choice making
    self.engine.make_choice = function(engine, choice_index)
        profiler:start_timer("choice_" .. choice_index)
        local result = profiler.original_make_choice(engine, choice_index)
        profiler:stop_timer("choice_" .. choice_index)
        profiler:record_choice_metrics(choice_index)
        return result
    end

    -- Hook Lua execution if interpreter available
    if self.engine.interpreter and self.engine.interpreter.execute_code then
        self.original_execute_code = self.engine.interpreter.execute_code

        self.engine.interpreter.execute_code = function(interpreter, code, state)
            profiler:start_timer("lua_code")
            local success, result = profiler.original_execute_code(interpreter, code, state)
            profiler:stop_timer("lua_code")
            profiler:record_lua_metrics(code)
            return success, result
        end
    end
end

-- Remove engine hooks
function Profiler:remove_hooks()
    if self.original_navigate then
        self.engine.navigate_to_passage = self.original_navigate
    end

    if self.original_make_choice then
        self.engine.make_choice = self.original_make_choice
    end

    if self.original_execute_code then
        self.engine.interpreter.execute_code = self.original_execute_code
    end
end

-- Timing utilities
function Profiler:start_timer(name)
    self.timers[name] = {
        start_time = self:get_time_ms(),
        start_memory = self:get_memory_kb()
    }
    self.current_timer = name
end

function Profiler:stop_timer(name)
    local timer = self.timers[name]
    if not timer then
        return nil
    end

    local elapsed_ms = self:get_time_ms() - timer.start_time
    local memory_delta_kb = self:get_memory_kb() - timer.start_memory

    self.timers[name] = nil

    return {
        elapsed_ms = elapsed_ms,
        memory_delta_kb = memory_delta_kb
    }
end

function Profiler:get_timer_elapsed(name)
    local timer = self.timers[name]
    if not timer then
        return 0
    end

    return self:get_time_ms() - timer.start_time
end

-- Metric recording
function Profiler:record_passage_metrics(passage_id)
    local timing = self:stop_timer("passage_" .. passage_id)
    if not timing then
        return
    end

    -- Initialize passage metrics if needed
    if not self.metrics.passages[passage_id] then
        self.metrics.passages[passage_id] = {
            visit_count = 0,
            total_time_ms = 0,
            min_time_ms = math.huge,
            max_time_ms = 0,
            total_memory_delta_kb = 0,
            warnings = {}
        }
    end

    local metrics = self.metrics.passages[passage_id]
    metrics.visit_count = metrics.visit_count + 1
    metrics.total_time_ms = metrics.total_time_ms + timing.elapsed_ms
    metrics.min_time_ms = math.min(metrics.min_time_ms, timing.elapsed_ms)
    metrics.max_time_ms = math.max(metrics.max_time_ms, timing.elapsed_ms)
    metrics.total_memory_delta_kb = metrics.total_memory_delta_kb + timing.memory_delta_kb
    metrics.avg_time_ms = metrics.total_time_ms / metrics.visit_count

    -- Check thresholds
    if timing.elapsed_ms > self.thresholds.passage_time_ms then
        table.insert(metrics.warnings, {
            type = "slow_passage",
            message = "Passage took " .. string.format("%.2f", timing.elapsed_ms) .. "ms",
            timestamp = os.time()
        })
    end

    if timing.memory_delta_kb > self.thresholds.memory_increase_kb then
        table.insert(metrics.warnings, {
            type = "memory_increase",
            message = "Memory increased by " .. string.format("%.2f", timing.memory_delta_kb) .. "KB",
            timestamp = os.time()
        })
    end

    -- Update statistics
    self.stats.total_passages = self.stats.total_passages + 1
    self.stats.total_time_ms = self.stats.total_time_ms + timing.elapsed_ms
end

function Profiler:record_choice_metrics(choice_index)
    local timing = self:stop_timer("choice_" .. choice_index)
    if not timing then
        return
    end

    if not self.metrics.choices[choice_index] then
        self.metrics.choices[choice_index] = {
            selection_count = 0,
            total_time_ms = 0,
            avg_time_ms = 0
        }
    end

    local metrics = self.metrics.choices[choice_index]
    metrics.selection_count = metrics.selection_count + 1
    metrics.total_time_ms = metrics.total_time_ms + timing.elapsed_ms
    metrics.avg_time_ms = metrics.total_time_ms / metrics.selection_count

    self.stats.total_choices = self.stats.total_choices + 1
end

function Profiler:record_lua_metrics(code)
    local timing = self:stop_timer("lua_code")
    if not timing then
        return
    end

    -- Create hash of code for tracking
    local code_hash = self:hash_string(code)

    if not self.metrics.lua_code[code_hash] then
        self.metrics.lua_code[code_hash] = {
            code_snippet = code:sub(1, 50),
            execution_count = 0,
            total_time_ms = 0,
            avg_time_ms = 0
        }
    end

    local metrics = self.metrics.lua_code[code_hash]
    metrics.execution_count = metrics.execution_count + 1
    metrics.total_time_ms = metrics.total_time_ms + timing.elapsed_ms
    metrics.avg_time_ms = metrics.total_time_ms / metrics.execution_count

    self.stats.total_lua_calls = self.stats.total_lua_calls + 1
end

-- Memory profiling
function Profiler:take_memory_snapshot(label)
    if self.mode == Profiler.ProfileMode.MEMORY or self.mode == Profiler.ProfileMode.FULL then
        local snapshot = {
            label = label,
            timestamp = os.time(),
            memory_kb = self:get_memory_kb(),
            memory_delta_kb = self:get_memory_kb() - self.memory_baseline
        }

        table.insert(self.memory_snapshots, snapshot)

        -- Update peak memory
        self.stats.peak_memory_kb = math.max(self.stats.peak_memory_kb, snapshot.memory_kb)

        return snapshot
    end

    return nil
end

function Profiler:get_memory_snapshots()
    return self.memory_snapshots
end

function Profiler:get_memory_trend()
    if #self.memory_snapshots < 2 then
        return "insufficient_data"
    end

    local first = self.memory_snapshots[1].memory_kb
    local last = self.memory_snapshots[#self.memory_snapshots].memory_kb
    local delta = last - first

    if delta > 100 then
        return "increasing"
    elseif delta < -100 then
        return "decreasing"
    else
        return "stable"
    end
end

-- Analysis and reporting
function Profiler:analyze()
    local analysis = {
        summary = self:get_summary(),
        slow_passages = self:find_slow_passages(),
        memory_issues = self:find_memory_issues(),
        hotspots = self:find_hotspots(),
        recommendations = self:generate_recommendations()
    }

    return analysis
end

function Profiler:find_slow_passages()
    local slow = {}

    for passage_id, metrics in pairs(self.metrics.passages) do
        if metrics.avg_time_ms > self.thresholds.passage_time_ms then
            table.insert(slow, {
                passage_id = passage_id,
                avg_time_ms = metrics.avg_time_ms,
                max_time_ms = metrics.max_time_ms,
                visit_count = metrics.visit_count
            })
        end
    end

    -- Sort by average time (slowest first)
    table.sort(slow, function(a, b)
        return a.avg_time_ms > b.avg_time_ms
    end)

    return slow
end

function Profiler:find_memory_issues()
    local issues = {}

    for passage_id, metrics in pairs(self.metrics.passages) do
        if metrics.total_memory_delta_kb > self.thresholds.memory_increase_kb then
            table.insert(issues, {
                passage_id = passage_id,
                total_memory_delta_kb = metrics.total_memory_delta_kb,
                avg_memory_delta_kb = metrics.total_memory_delta_kb / metrics.visit_count
            })
        end
    end

    return issues
end

function Profiler:find_hotspots()
    local hotspots = {}

    -- Find passages with most time spent
    for passage_id, metrics in pairs(self.metrics.passages) do
        table.insert(hotspots, {
            passage_id = passage_id,
            total_time_ms = metrics.total_time_ms,
            visit_count = metrics.visit_count,
            percentage = (metrics.total_time_ms / self.stats.total_time_ms) * 100
        })
    end

    -- Sort by total time
    table.sort(hotspots, function(a, b)
        return a.total_time_ms > b.total_time_ms
    end)

    return hotspots
end

function Profiler:generate_recommendations()
    local recommendations = {}

    -- Check for slow passages
    local slow = self:find_slow_passages()
    if #slow > 0 then
        table.insert(recommendations, {
            type = "performance",
            severity = "warning",
            message = string.format("%d passage(s) exceed time threshold", #slow),
            suggestion = "Consider optimizing Lua code or simplifying passage logic"
        })
    end

    -- Check memory trend
    local trend = self:get_memory_trend()
    if trend == "increasing" then
        table.insert(recommendations, {
            type = "memory",
            severity = "warning",
            message = "Memory usage is increasing over time",
            suggestion = "Check for memory leaks or excessive data retention"
        })
    end

    -- Check for frequently executed Lua code
    for hash, metrics in pairs(self.metrics.lua_code) do
        if metrics.execution_count > 100 and metrics.avg_time_ms > 10 then
            table.insert(recommendations, {
                type = "optimization",
                severity = "info",
                message = "Frequently executed code could be optimized",
                code_snippet = metrics.code_snippet,
                suggestion = "Consider caching results or simplifying logic"
            })
        end
    end

    return recommendations
end

-- Statistics and reporting
function Profiler:calculate_final_stats()
    if self.session_start then
        local total_session_time = self:get_time_ms() - self.session_start
        self.stats.session_time_ms = total_session_time
    end

    if self.stats.total_passages > 0 then
        self.stats.average_passage_time_ms = self.stats.total_time_ms / self.stats.total_passages
    end
end

function Profiler:get_summary()
    return {
        mode = self.mode,
        session_time_ms = self.stats.session_time_ms or 0,
        total_passages = self.stats.total_passages,
        total_choices = self.stats.total_choices,
        total_lua_calls = self.stats.total_lua_calls,
        average_passage_time_ms = self.stats.average_passage_time_ms,
        peak_memory_kb = self.stats.peak_memory_kb,
        memory_trend = self:get_memory_trend()
    }
end

function Profiler:get_passage_metrics(passage_id)
    return self.metrics.passages[passage_id]
end

function Profiler:get_all_passage_metrics()
    return self.metrics.passages
end

function Profiler:generate_report(format)
    format = format or "text"

    if format == "text" then
        return self:generate_text_report()
    elseif format == "json" then
        return self:generate_json_report()
    end

    return nil
end

function Profiler:generate_text_report()
    local lines = {
        "=== Performance Profile Report ===",
        "",
        "Session Summary:",
        "  Mode: " .. self.mode,
        "  Session Time: " .. string.format("%.2f", self.stats.session_time_ms or 0) .. "ms",
        "  Total Passages: " .. self.stats.total_passages,
        "  Total Choices: " .. self.stats.total_choices,
        "  Total Lua Calls: " .. self.stats.total_lua_calls,
        "  Average Passage Time: " .. string.format("%.2f", self.stats.average_passage_time_ms) .. "ms",
        "  Peak Memory: " .. string.format("%.2f", self.stats.peak_memory_kb) .. "KB",
        ""
    }

    -- Add slow passages
    local slow = self:find_slow_passages()
    if #slow > 0 then
        table.insert(lines, "Slow Passages:")
        for i, passage in ipairs(slow) do
            if i <= 5 then -- Top 5
                table.insert(lines, string.format("  %s: %.2fms avg (%.2fms max, %d visits)",
                    passage.passage_id, passage.avg_time_ms, passage.max_time_ms, passage.visit_count))
            end
        end
        table.insert(lines, "")
    end

    -- Add recommendations
    local recommendations = self:generate_recommendations()
    if #recommendations > 0 then
        table.insert(lines, "Recommendations:")
        for _, rec in ipairs(recommendations) do
            table.insert(lines, "  [" .. rec.severity .. "] " .. rec.message)
            table.insert(lines, "    → " .. rec.suggestion)
        end
    end

    return table.concat(lines, "\n")
end

function Profiler:generate_json_report()
    -- In a real implementation, this would use a JSON library
    -- For now, return a Lua table
    return {
        summary = self:get_summary(),
        passages = self.metrics.passages,
        choices = self.metrics.choices,
        lua_code = self.metrics.lua_code,
        analysis = self:analyze()
    }
end

-- Utilities
function Profiler:get_time_ms()
    return (os.clock() or os.time()) * 1000
end

function Profiler:get_memory_kb()
    -- Use collectgarbage to get memory usage
    return collectgarbage("count")
end

function Profiler:hash_string(str)
    -- Simple hash function
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2^32
    end
    return tostring(hash)
end

function Profiler:log(message)
    if self.active then
        print("[PROFILER] " .. message)
    end
end

-- Reset profiler data
function Profiler:reset()
    self.metrics = {
        passages = {},
        choices = {},
        lua_code = {},
        overall = {}
    }

    self.memory_snapshots = {}
    self.timers = {}

    self.stats = {
        total_time_ms = 0,
        total_passages = 0,
        total_choices = 0,
        total_lua_calls = 0,
        peak_memory_kb = 0,
        average_passage_time_ms = 0
    }
end

return Profiler