/**
 * Template Processor for Whisker Editor Preview
 * Handles {{#if}}...{{else if}}...{{else}}...{{/if}} conditionals
 * Supports Lua execution via Fengari
 */

class TemplateProcessor {
    static luaState = null;
    static luaInitialized = false;
    /**
     * Process template content with variables
     * @param {string} content - Template content
     * @param {Object} variables - Variable values
     * @returns {string} Processed content
     */
    static process(content, variables = {}) {
        if (!content) return '';

        // Process conditionals first
        content = this.processConditionals(content, variables);

        // Process {{lua:...}} blocks (execute if possible, otherwise show indicator)
        content = this.processLuaBlocks(content, variables);

        // Then process variable substitutions
        content = this.processVariables(content, variables);

        return content;
    }

    /**
     * Process conditional blocks
     * @param {string} content - Content with conditionals
     * @param {Object} variables - Variable values
     * @returns {string} Processed content
     */
    static processConditionals(content, variables) {
        let maxIterations = 100;
        let iteration = 0;

        // Process {{#if}}...{{else if}}...{{else}}...{{/if}} blocks
        while (content.includes('{{#if') && iteration < maxIterations) {
            iteration++;

            // Find first {{#if}} tag
            const ifMatch = content.match(/\{\{#if\s+([^}]+)\}\}/);
            if (!ifMatch) break;

            const ifStart = ifMatch.index;
            const ifEnd = ifStart + ifMatch[0].length;
            const initialCondition = ifMatch[1];

            // Find matching {{/if}}
            const endifMatch = content.substring(ifEnd).match(/\{\{\/if\}\}/);
            if (!endifMatch) break;

            const endifStart = ifEnd + endifMatch.index;
            const endifEnd = endifStart + endifMatch[0].length;

            // Extract block content between {{#if}} and {{/if}}
            const blockContent = content.substring(ifEnd, endifStart);

            // Parse conditional blocks
            const blocks = this.parseConditionalBlocks(blockContent, initialCondition);

            // Evaluate blocks and find the first matching one
            let replacement = '';
            for (const block of blocks) {
                if (block.condition === null) {
                    // {{else}} block - use if no other conditions matched
                    replacement = block.content;
                    break;
                } else {
                    // Evaluate condition
                    if (this.evaluateCondition(block.condition, variables)) {
                        replacement = block.content;
                        break;
                    }
                }
            }

            // Replace the entire conditional block with the result
            content = content.substring(0, ifStart) + replacement + content.substring(endifEnd);
        }

        return content;
    }

    /**
     * Parse conditional blocks to handle {{else if}} and {{else}}
     * @param {string} blockContent - Content between {{#if}} and {{/if}}
     * @param {string} initialCondition - The initial {{#if}} condition
     * @returns {Array} Array of {condition, content} objects
     */
    static parseConditionalBlocks(blockContent, initialCondition) {
        const blocks = [];
        const markers = [];

        // Find all {{else if}} and {{else}} markers
        let pos = 0;
        while (pos < blockContent.length) {
            // Look for {{else if condition}}
            const elseIfMatch = blockContent.substring(pos).match(/\{\{else if\s+([^}]+)\}\}/);

            // Look for {{else}}
            const elseMatch = blockContent.substring(pos).match(/\{\{else\}\}/);

            // Determine which comes first
            let nextMarker = null;
            if (elseIfMatch && (!elseMatch || elseIfMatch.index < elseMatch.index)) {
                nextMarker = {
                    start: pos + elseIfMatch.index,
                    end: pos + elseIfMatch.index + elseIfMatch[0].length,
                    type: 'else_if',
                    condition: elseIfMatch[1]
                };
            } else if (elseMatch) {
                nextMarker = {
                    start: pos + elseMatch.index,
                    end: pos + elseMatch.index + elseMatch[0].length,
                    type: 'else',
                    condition: null
                };
            }

            if (!nextMarker) break;

            markers.push(nextMarker);
            pos = nextMarker.end;
        }

        // Build blocks array
        let currentPos = 0;

        // First block (initial {{#if}})
        const firstBlockEnd = markers.length > 0 ? markers[0].start : blockContent.length;
        blocks.push({
            condition: initialCondition,
            content: blockContent.substring(0, firstBlockEnd)
        });

        // Process remaining blocks
        for (let i = 0; i < markers.length; i++) {
            const marker = markers[i];
            const nextMarker = markers[i + 1];

            const blockEnd = nextMarker ? nextMarker.start : blockContent.length;
            blocks.push({
                condition: marker.condition,
                content: blockContent.substring(marker.end, blockEnd)
            });
        }

        return blocks;
    }

    /**
     * Evaluate a condition expression
     * @param {string} condition - Condition to evaluate
     * @param {Object} variables - Variable values
     * @returns {boolean} Result of evaluation
     */
    static evaluateCondition(condition, variables) {
        if (!condition) return false;

        condition = condition.trim();

        // Check for comparison operators
        const operators = [
            { op: '==', fn: (a, b) => a == b },
            { op: '!=', fn: (a, b) => a != b },
            { op: '>=', fn: (a, b) => Number(a) >= Number(b) },
            { op: '<=', fn: (a, b) => Number(a) <= Number(b) },
            { op: '>', fn: (a, b) => Number(a) > Number(b) },
            { op: '<', fn: (a, b) => Number(a) < Number(b) }
        ];

        for (const {op, fn} of operators) {
            const parts = condition.split(op);
            if (parts.length === 2) {
                const left = this.resolveValue(parts[0].trim(), variables);
                const right = this.resolveValue(parts[1].trim(), variables);
                return fn(left, right);
            }
        }

        // Check for logical operators
        if (condition.includes(' and ')) {
            const parts = condition.split(' and ');
            return parts.every(part => this.evaluateCondition(part.trim(), variables));
        }

        if (condition.includes(' or ')) {
            const parts = condition.split(' or ');
            return parts.some(part => this.evaluateCondition(part.trim(), variables));
        }

        // Check for negation
        if (condition.startsWith('not ') || condition.startsWith('!')) {
            const inner = condition.replace(/^not\s+/, '').replace(/^!/, '');
            return !this.evaluateCondition(inner, variables);
        }

        // Simple variable lookup - check if truthy
        const value = variables[condition];

        if (value === undefined || value === null) return false;
        if (typeof value === 'boolean') return value;
        if (typeof value === 'number') return value !== 0;
        if (typeof value === 'string') return value !== '';

        return !!value;
    }

    /**
     * Resolve a value (variable or literal)
     * @param {string} str - String to resolve
     * @param {Object} variables - Variable values
     * @returns {*} Resolved value
     */
    static resolveValue(str, variables) {
        str = str.trim();

        // Check if it's a quoted string
        if ((str.startsWith('"') && str.endsWith('"')) ||
            (str.startsWith("'") && str.endsWith("'"))) {
            return str.slice(1, -1);
        }

        // Check if it's a number
        const num = Number(str);
        if (!isNaN(num)) return num;

        // Check if it's a boolean
        if (str === 'true') return true;
        if (str === 'false') return false;

        // Otherwise, look up as variable
        return variables[str];
    }

    /**
     * Process Lua blocks
     * @param {string} content - Content with Lua blocks
     * @param {Object} variables - Variable values (mutable)
     * @returns {string} Processed content
     */
    static processLuaBlocks(content, variables) {
        // Initialize Lua if not already done
        if (!this.luaInitialized && typeof fengari !== 'undefined') {
            this.initializeLua();
        }

        // Execute Lua if available, otherwise show indicator
        if (this.luaInitialized && this.luaState) {
            return content.replace(/\{\{lua:([\s\S]*?)\}\}/g, (match, code) => {
                try {
                    this.executeLuaInPreview(code.trim(), variables);
                    return ''; // Lua blocks don't output text
                } catch (error) {
                    console.error('[Template Processor] Lua preview error:', error);
                    return `<span style="color: #ef4444;">Lua Error</span>`;
                }
            });
        } else {
            // Fallback: show indicator
            return content.replace(/\{\{lua:([\s\S]*?)\}\}/g, (match, code) => {
                const codePreview = code.trim().split('\n')[0].substring(0, 50);
                return `<span style="display: inline-block; background: #fef3c7; color: #92400e; padding: 2px 8px; border-radius: 4px; font-size: 0.85em; font-family: monospace;" title="${this.escapeHtml(code.trim())}">🌙 Lua: ${this.escapeHtml(codePreview)}${code.length > 50 ? '...' : ''}</span>`;
            });
        }
    }

    /**
     * Escape HTML for safe display
     * @param {string} str - String to escape
     * @returns {string} Escaped string
     */
    static escapeHtml(str) {
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    /**
     * Initialize Lua runtime for preview
     */
    static initializeLua() {
        if (this.luaInitialized) return;

        if (typeof fengari === 'undefined') {
            console.warn('[Template Processor] Fengari not loaded, Lua preview disabled');
            return;
        }

        try {
            const lua = fengari.lua;
            const lauxlib = fengari.lauxlib;
            const lualib = fengari.lualib;

            this.luaState = lauxlib.luaL_newstate();
            lualib.luaL_openlibs(this.luaState);

            this.luaInitialized = true;
            console.log('[Template Processor] ✅ Lua preview enabled');
        } catch (error) {
            console.error('[Template Processor] Failed to initialize Lua:', error);
        }
    }

    /**
     * Execute Lua code in preview with variables
     * @param {string} code - Lua code to execute
     * @param {Object} variables - Variable object (mutable)
     */
    static executeLuaInPreview(code, variables) {
        if (!this.luaState || !this.luaInitialized) {
            console.warn('[Template Processor] Lua not initialized');
            return;
        }

        try {
            const lua = fengari.lua;
            const lauxlib = fengari.lauxlib;
            const to_jsstring = fengari.to_jsstring;

            // Create Lua code with game_state bridge
            const luaCode = `
                game_state = {
                    data = {},
                    set = function(self, key, value)
                        self.data[key] = value
                        js_set_variable(key, value)
                    end,
                    get = function(self, key)
                        return js_get_variable(key)
                    end
                }

                -- User code
                ${code}
            `;

            const L = this.luaState;

            // Register js_set_variable callback
            lua.lua_pushcfunction(L, (L) => {
                const key = to_jsstring(lua.lua_tostring(L, -2));
                const value = lua.lua_tonumber(L, -1) !== null ?
                    lua.lua_tonumber(L, -1) :
                    (lua.lua_toboolean(L, -1) ?
                        lua.lua_toboolean(L, -1) :
                        to_jsstring(lua.lua_tostring(L, -1)));

                variables[key] = value;
                return 0;
            });
            lua.lua_setglobal(L, to_jsstring("js_set_variable"));

            // Register js_get_variable callback
            lua.lua_pushcfunction(L, (L) => {
                const key = to_jsstring(lua.lua_tostring(L, -1));
                const value = variables[key];

                if (typeof value === 'number') {
                    lua.lua_pushnumber(L, value);
                } else if (typeof value === 'boolean') {
                    lua.lua_pushboolean(L, value);
                } else if (typeof value === 'string') {
                    lua.lua_pushstring(L, to_jsstring(value));
                } else {
                    lua.lua_pushnil(L);
                }

                return 1;
            });
            lua.lua_setglobal(L, to_jsstring("js_get_variable"));

            // Execute Lua code
            lauxlib.luaL_dostring(L, to_jsstring(luaCode));

            console.log('[Template Processor] ✅ Lua preview executed successfully');
        } catch (error) {
            console.error('[Template Processor] ❌ Lua preview error:', error);
        }
    }

    /**
     * Process variable substitutions
     * @param {string} content - Content with variables
     * @param {Object} variables - Variable values
     * @returns {string} Processed content
     */
    static processVariables(content, variables) {
        return content.replace(/\{\{([a-zA-Z_][a-zA-Z0-9_]*)\}\}/g, (match, varName) => {
            varName = varName.trim();

            if (variables.hasOwnProperty(varName)) {
                return String(variables[varName]);
            }

            // Return placeholder with cyan color for undefined variables
            return `<span style="color: #61dafb;">[${varName}]</span>`;
        });
    }
}
