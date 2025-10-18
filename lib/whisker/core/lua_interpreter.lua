-- src/runtime/interpreter.lua
-- Secure Lua sandbox with instruction counting

local LuaInterpreter = {}
LuaInterpreter.__index = LuaInterpreter

function LuaInterpreter.new(config)
    config = config or {}
    local instance = {
        config = config,
        sandbox_env = nil,
        instruction_count = 0,
        max_instructions = config.max_instructions or 10000,
        start_time = 0,
        timeout = config.timeout or 5000 -- milliseconds
    }

    setmetatable(instance, LuaInterpreter)
    instance:create_sandbox()
    return instance
end

function LuaInterpreter:create_sandbox()
    -- Start with empty environment
    self.sandbox_env = {}

    -- Add safe global functions
    self.sandbox_env._G = self.sandbox_env
    self.sandbox_env._VERSION = _VERSION

    -- Safe basic functions
    self.sandbox_env.assert = assert
    self.sandbox_env.error = error
    self.sandbox_env.ipairs = ipairs
    self.sandbox_env.next = next
    self.sandbox_env.pairs = pairs
    self.sandbox_env.pcall = pcall
    self.sandbox_env.select = select
    self.sandbox_env.tonumber = tonumber
    self.sandbox_env.tostring = tostring
    self.sandbox_env.type = type
    self.sandbox_env.unpack = unpack or table.unpack

    -- Safe string library
    self.sandbox_env.string = {
        byte = string.byte,
        char = string.char,
        find = string.find,
        format = string.format,
        gmatch = string.gmatch,
        gsub = string.gsub,
        len = string.len,
        lower = string.lower,
        match = string.match,
        rep = function(s, n)
            if n > 1000 then error("String repetition limit exceeded") end
            return string.rep(s, n)
        end,
        reverse = string.reverse,
        sub = string.sub,
        upper = string.upper
    }

    -- Safe table library
    self.sandbox_env.table = {
        concat = table.concat,
        insert = table.insert,
        remove = table.remove,
        sort = table.sort
    }

    -- Safe math library
    self.sandbox_env.math = {
        abs = math.abs,
        acos = math.acos,
        asin = math.asin,
        atan = math.atan,
        ceil = math.ceil,
        cos = math.cos,
        deg = math.deg,
        exp = math.exp,
        floor = math.floor,
        huge = math.huge,
        log = math.log,
        max = math.max,
        min = math.min,
        pi = math.pi,
        rad = math.rad,
        random = math.random,
        sin = math.sin,
        sqrt = math.sqrt,
        tan = math.tan
    }

    -- Block dangerous functions
    self.sandbox_env.dofile = nil
    self.sandbox_env.loadfile = nil
    self.sandbox_env.require = nil
    self.sandbox_env.load = nil
    self.sandbox_env.loadstring = nil
    self.sandbox_env.io = nil
    self.sandbox_env.os = {time = os.time, clock = os.clock}
    self.sandbox_env.package = nil
    self.sandbox_env.debug = nil
end

function LuaInterpreter:create_story_api(game_state, context)
    return {
        get = function(key, default)
            return game_state:get(key, default)
        end,

        set = function(key, value)
            return game_state:set(key, value)
        end,

        inc = function(key, amount)
            return game_state:increment(key, amount)
        end,

        dec = function(key, amount)
            return game_state:decrement(key, amount)
        end,

        del = function(key)
            return game_state:delete(key)
        end,

        has = function(key)
            return game_state:has(key)
        end,

        visited = function(passage_id)
            return game_state:has_visited(passage_id)
        end,

        visit_count = function(passage_id)
            return game_state:get_visit_count(passage_id)
        end,

        -- Story context access (if provided)
        story = context and context.story or nil
    }
end

function LuaInterpreter:setup_instruction_counting(chunk)
    self.instruction_count = 0
    self.start_time = os.clock()

    -- Set debug hook for instruction counting
    debug.sethook(function()
        self.instruction_count = self.instruction_count + 1

        -- Check instruction limit
        if self.instruction_count > self.max_instructions then
            error("Instruction limit exceeded")
        end

        -- Check timeout
        local elapsed = (os.clock() - self.start_time) * 1000
        if elapsed > self.timeout then
            error("Execution timeout")
        end
    end, "", 100) -- Check every 100 instructions

    return chunk
end

function LuaInterpreter:teardown_instruction_counting()
    debug.sethook() -- Remove hook
end

function LuaInterpreter:execute_code(code, game_state, context)
    if not code or code == "" then
        return true, nil, nil
    end

    -- Compile the code
    local chunk, compile_error = load(code, "story_code", "t", self.sandbox_env)

    if not chunk then
        return false, "Compilation error: " .. tostring(compile_error), {
            type = "compilation",
            code = code
        }
    end

    -- Add story API to sandbox environment
    local story_api = self:create_story_api(game_state, context)
    for k, v in pairs(story_api) do
        self.sandbox_env[k] = v
    end

    -- Set up instruction counting
    chunk = self:setup_instruction_counting(chunk)

    -- Execute the code
    local success, result = pcall(chunk)

    -- Clean up
    self:teardown_instruction_counting()

    if not success then
        return false, "Execution error: " .. tostring(result), {
            type = "execution",
            code = code,
            instruction_count = self.instruction_count
        }
    end

    return true, result, {
        instruction_count = self.instruction_count,
        execution_time = (os.clock() - self.start_time) * 1000
    }
end

function LuaInterpreter:evaluate_condition(condition_code, game_state, context)
    -- Wrap condition in return statement
    local code = "return (" .. condition_code .. ")"

    local success, result, details = self:execute_code(code, game_state, context)

    if not success then
        return false, result, details
    end

    -- Ensure result is boolean
    return true, result and true or false, details
end

function LuaInterpreter:evaluate_expression(expression_code, game_state, context)
    -- Make game state variables directly accessible in sandbox
    if game_state then
        for k, v in pairs(game_state.variables or {}) do
            self.sandbox_env[k] = v
        end
    end

    -- Wrap expression in return statement
    local code = "return (" .. expression_code .. ")"

    local success, result, details = self:execute_code(code, game_state, context)

    -- Clean up direct variable access
    if game_state then
        for k, _ in pairs(game_state.variables or {}) do
            self.sandbox_env[k] = nil
        end
    end

    return success, result, details
end

function LuaInterpreter:get_instruction_count()
    return self.instruction_count
end

function LuaInterpreter:reset_counters()
    self.instruction_count = 0
    self.start_time = 0
end

return LuaInterpreter
