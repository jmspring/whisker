-- src/runtime/advanced_instruction_counter.lua
-- Advanced instruction counting with CPU-accurate weighting and performance monitoring

local AdvancedInstructionCounter = {}
AdvancedInstructionCounter.__index = AdvancedInstructionCounter

function AdvancedInstructionCounter.new(config)
    config = config or {}

    local instance = {
        -- Instruction weighting (based on CPU cost)
        INSTRUCTION_WEIGHTS = {
            -- Basic operations
            ["arithmetic"] = 1,
            ["comparison"] = 1,
            ["logical"] = 1,
            ["assignment"] = 1,

            -- Control flow
            ["branch"] = 2,
            ["function_call"] = 5,
            ["return"] = 2,
            ["loop_iteration"] = 3,

            -- Data structures
            ["table_access"] = 2,
            ["table_creation"] = 10,
            ["table_insert"] = 3,
            ["table_concat"] = 5,

            -- String operations
            ["string_concat"] = 3,
            ["string_match"] = 10,
            ["string_gsub"] = 15,
            ["string_find"] = 8,

            -- Memory operations
            ["memory_allocation"] = 5,
            ["garbage_collection"] = 50,

            -- Advanced
            ["coroutine_yield"] = 10,
            ["coroutine_resume"] = 10,
            ["metamethod"] = 8
        },

        -- Context multipliers for nested/complex scenarios
        CONTEXT_MULTIPLIERS = {
            ["in_loop"] = 1.2,
            ["deep_recursion"] = 1.5,
            ["nested_function"] = 1.3,
            ["callback_intensive"] = 1.6
        },

        -- Runtime tracking
        current_instructions = 0,
        weighted_instructions = 0,
        operation_counts = {},
        context_stack = {},

        execution_profile = {
            hot_spots = {},
            expensive_operations = {},
            execution_time = 0,
            samples = 0
        },

        -- Performance thresholds
        limits = {
            max_weighted_instructions = config.max_weighted_instructions or 1000000,
            max_raw_instructions = config.max_raw_instructions or 5000000,
            profiling_sample_rate = config.profiling_sample_rate or 100,
            hot_spot_threshold = config.hot_spot_threshold or 1000
        },

        -- Statistics
        stats = {
            total_operations = 0,
            operations_by_category = {},
            average_weight_per_operation = 0,
            execution_efficiency = 1.0
        }
    }

    -- Initialize operation counting tables
    for op_name, _ in pairs(instance.INSTRUCTION_WEIGHTS) do
        instance.operation_counts[op_name] = 0
    end

    setmetatable(instance, AdvancedInstructionCounter)
    return instance
end

function AdvancedInstructionCounter:count_instruction(operation, context)
    context = context or {}

    -- Get base weight for operation
    local base_weight = self.INSTRUCTION_WEIGHTS[operation] or 1

    -- Apply context multipliers
    local final_weight = base_weight
    for context_type, multiplier in pairs(self.CONTEXT_MULTIPLIERS) do
        if context[context_type] then
            final_weight = final_weight * multiplier
        end
    end

    -- Update counters
    self.current_instructions = self.current_instructions + 1
    self.weighted_instructions = self.weighted_instructions + final_weight

    -- Track operation frequency
    self.operation_counts[operation] = (self.operation_counts[operation] or 0) + 1

    -- Performance profiling (sampled)
    if self.current_instructions % self.limits.profiling_sample_rate == 0 then
        self:record_profiling_sample(operation, final_weight, context)
    end

    -- Check limits
    if self.weighted_instructions > self.limits.max_weighted_instructions then
        error("Weighted instruction limit exceeded")
    end

    if self.current_instructions > self.limits.max_raw_instructions then
        error("Raw instruction limit exceeded")
    end

    return final_weight
end

function AdvancedInstructionCounter:record_profiling_sample(operation, weight, context)
    self.execution_profile.samples = self.execution_profile.samples + 1

    -- Track hot spots
    local location = context.location or "unknown"
    if not self.execution_profile.hot_spots[location] then
        self.execution_profile.hot_spots[location] = {
            count = 0,
            total_weight = 0
        }
    end

    local hot_spot = self.execution_profile.hot_spots[location]
    hot_spot.count = hot_spot.count + 1
    hot_spot.total_weight = hot_spot.total_weight + weight

    -- Track expensive operations
    if weight > 10 then
        if not self.execution_profile.expensive_operations[operation] then
            self.execution_profile.expensive_operations[operation] = {
                count = 0,
                total_weight = 0
            }
        end

        local expensive = self.execution_profile.expensive_operations[operation]
        expensive.count = expensive.count + 1
        expensive.total_weight = expensive.total_weight + weight
    end
end

function AdvancedInstructionCounter:get_performance_report()
    -- Calculate statistics
    self:calculate_statistics()

    -- Identify optimization opportunities
    local optimization_suggestions = self:generate_optimization_suggestions()

    return {
        summary = {
            raw_instructions = self.current_instructions,
            weighted_instructions = self.weighted_instructions,
            average_weight = self.stats.average_weight_per_operation,
            efficiency = self.stats.execution_efficiency
        },

        operation_breakdown = self.operation_counts,

        hot_spots = self:get_top_hot_spots(5),
        expensive_operations = self:get_top_expensive_operations(5),

        optimization_suggestions = optimization_suggestions,

        limits = {
            weighted_usage = (self.weighted_instructions / self.limits.max_weighted_instructions) * 100,
            raw_usage = (self.current_instructions / self.limits.max_raw_instructions) * 100
        }
    }
end

function AdvancedInstructionCounter:calculate_statistics()
    local total_weight = 0
    local total_ops = 0

    for _, count in pairs(self.operation_counts) do
        total_ops = total_ops + count
    end

    for op, count in pairs(self.operation_counts) do
        local weight = self.INSTRUCTION_WEIGHTS[op] or 1
        total_weight = total_weight + (count * weight)
    end

    self.stats.total_operations = total_ops
    self.stats.average_weight_per_operation = total_ops > 0 and (total_weight / total_ops) or 0

    -- Calculate efficiency (lower weight per op is better)
    self.stats.execution_efficiency = self.stats.average_weight_per_operation > 0
        and (1.0 / self.stats.average_weight_per_operation)
        or 1.0
end

function AdvancedInstructionCounter:get_top_hot_spots(n)
    local spots = {}
    for location, data in pairs(self.execution_profile.hot_spots) do
        table.insert(spots, {
            location = location,
            count = data.count,
            total_weight = data.total_weight,
            avg_weight = data.count > 0 and (data.total_weight / data.count) or 0
        })
    end

    table.sort(spots, function(a, b)
        return a.total_weight > b.total_weight
    end)

    local result = {}
    for i = 1, math.min(n, #spots) do
        table.insert(result, spots[i])
    end

    return result
end

function AdvancedInstructionCounter:get_top_expensive_operations(n)
    local ops = {}
    for operation, data in pairs(self.execution_profile.expensive_operations) do
        table.insert(ops, {
            operation = operation,
            count = data.count,
            total_weight = data.total_weight,
            avg_weight = data.count > 0 and (data.total_weight / data.count) or 0
        })
    end

    table.sort(ops, function(a, b)
        return a.total_weight > b.total_weight
    end)

    local result = {}
    for i = 1, math.min(n, #ops) do
        table.insert(result, ops[i])
    end

    return result
end

function AdvancedInstructionCounter:generate_optimization_suggestions()
    local suggestions = {}

    -- Check for excessive string operations
    local string_ops = (self.operation_counts["string_concat"] or 0) +
                      (self.operation_counts["string_gsub"] or 0) +
                      (self.operation_counts["string_match"] or 0)

    if string_ops > 1000 then
        table.insert(suggestions, {
            type = "string_operations",
            severity = "medium",
            message = "High number of string operations detected. Consider using table.concat for string building.",
            count = string_ops
        })
    end

    -- Check for excessive table operations
    local table_ops = (self.operation_counts["table_creation"] or 0) +
                     (self.operation_counts["table_insert"] or 0)

    if table_ops > 2000 then
        table.insert(suggestions, {
            type = "table_operations",
            severity = "medium",
            message = "High number of table operations. Consider object pooling or reusing tables.",
            count = table_ops
        })
    end

    -- Check for deep recursion
    local recursion_count = 0
    for _, context in ipairs(self.context_stack) do
        if context.deep_recursion then
            recursion_count = recursion_count + 1
        end
    end

    if recursion_count > 100 then
        table.insert(suggestions, {
            type = "recursion",
            severity = "high",
            message = "Deep recursion detected. Consider iterative solutions or tail call optimization.",
            count = recursion_count
        })
    end

    return suggestions
end

function AdvancedInstructionCounter:reset()
    self.current_instructions = 0
    self.weighted_instructions = 0
    self.operation_counts = {}
    self.context_stack = {}
    self.execution_profile = {
        hot_spots = {},
        expensive_operations = {},
        execution_time = 0,
        samples = 0
    }

    -- Reinitialize operation counts
    for op_name, _ in pairs(self.INSTRUCTION_WEIGHTS) do
        self.operation_counts[op_name] = 0
    end
end

function AdvancedInstructionCounter:get_current_count()
    return self.current_instructions
end

function AdvancedInstructionCounter:get_weighted_count()
    return self.weighted_instructions
end

return AdvancedInstructionCounter