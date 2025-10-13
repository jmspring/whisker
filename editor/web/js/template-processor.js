/**
 * Template Processor for Whisker Editor Preview
 * Handles {{#if}}...{{else if}}...{{else}}...{{/if}} conditionals
 */

class TemplateProcessor {
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

        // Remove {{lua:...}} tags
        content = content.replace(/\{\{lua:[^}]*\}\}/g, '');

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
