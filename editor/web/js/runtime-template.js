/**
 * Runtime Template Generator
 * Generates complete standalone HTML files with embedded Whisker runtime
 *
 * Features:
 * - Full LuaWhiskerPlayer embedded
 * - Complete CSS inlined
 * - Save/Load functionality
 * - Theme support
 * - Undo/Redo
 * - Progress tracking
 * - Responsive design
 */

class RuntimeTemplate {
    /**
     * Generate complete standalone HTML
     * @param {Object} storyData - Story data
     * @param {Object} options - Generation options
     * @returns {Promise<string>} Complete HTML
     */
    static async generateFullHTML(storyData, options = {}) {
        const {
            needsLua = false,
            includeStats = true,
            theme = 'light'
        } = options;

        const css = await CSSInliner.getCachedCSS();

        const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${this.escape(storyData.metadata?.title || 'Whisker Story')}</title>
    <meta name="description" content="${this.escape(storyData.metadata?.description || 'Interactive fiction created with Whisker')}">
    <meta name="author" content="${this.escape(storyData.metadata?.author || '')}">
    <meta name="generator" content="Whisker Interactive Fiction Editor">
    ${needsLua ? this.getFengariScript() : ''}
    ${this.getEmbeddedCSS(css)}
</head>
<body>
    ${this.getHTMLStructure(storyData, includeStats)}
    ${needsLua ? this.getLuaPlayerScript() : this.getStandardPlayerScript()}
    ${this.getInitializationScript(storyData)}
</body>
</html>`;

        return html;
    }

    /**
     * Get Fengari script tag
     */
    static getFengariScript() {
        return `<!-- Fengari: Lua VM for JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js"></script>`;
    }

    /**
     * Get embedded CSS in style tag
     * @param {string} css - Minified CSS
     */
    static getEmbeddedCSS(css) {
        return `<style>
        ${css}
    </style>`;
    }

    /**
     * Get HTML structure with full UI
     * @param {Object} storyData - Story data
     * @param {boolean} includeStats - Whether to include stats sidebar
     */
    static getHTMLStructure(storyData, includeStats) {
        return `
    <div id="whisker-container">
        <!-- Header -->
        <div class="whisker-header">
            <div class="whisker-title-section">
                <h1 class="whisker-title" id="story-title">${this.escape(storyData.metadata?.title || 'Whisker Story')}</h1>
                ${storyData.metadata?.author ? `<div class="whisker-subtitle" id="story-author" style="display: block;">by ${this.escape(storyData.metadata.author)}</div>` : `<div class="whisker-subtitle" id="story-author" style="display: none;"></div>`}
            </div>
            <div class="whisker-controls">
                <button class="whisker-btn whisker-save-btn" onclick="player.showSaveModal()" title="Save game (Ctrl+S)">
                    <span class="whisker-icon">💾</span>
                    <span class="whisker-btn-text">Save</span>
                </button>
                <button class="whisker-btn whisker-load-btn" onclick="player.showLoadModal()" title="Load game (Ctrl+L)">
                    <span class="whisker-icon">📂</span>
                    <span class="whisker-btn-text">Load</span>
                </button>
                <button class="whisker-btn whisker-undo-btn" onclick="player.undo()" title="Undo (Ctrl+Z)">
                    <span class="whisker-icon">↶</span>
                    <span class="whisker-btn-text">Undo</span>
                </button>
                <button class="whisker-btn whisker-restart-btn" onclick="player.restart()" title="Restart story">
                    <span class="whisker-icon">↻</span>
                    <span class="whisker-btn-text">Restart</span>
                </button>
            </div>
        </div>

        <!-- Progress Bar -->
        <div class="whisker-progress-bar">
            <div class="whisker-progress-fill" id="progress-bar" style="width: 0%;"></div>
        </div>

        <!-- Main Content -->
        <div class="whisker-main">
            <div class="whisker-content">
                <div class="whisker-passage">
                    <h2 class="whisker-passage-title" id="passage-title"></h2>
                    <div class="whisker-passage-content" id="passage-content"></div>
                    <div class="whisker-choices" id="choices-container"></div>
                </div>
            </div>

            ${includeStats ? this.getSidebarHTML() : ''}
        </div>
    </div>

    <!-- Notifications -->
    <div class="whisker-notifications" id="notifications"></div>`;
    }

    /**
     * Get sidebar HTML
     */
    static getSidebarHTML() {
        return `
            <!-- Sidebar -->
            <div class="whisker-sidebar">
                <div class="whisker-sidebar-section">
                    <div class="whisker-sidebar-heading">Stats</div>
                    <div class="whisker-stats" id="stats-container"></div>
                </div>
                <div class="whisker-sidebar-section">
                    <div class="whisker-sidebar-heading">Progress</div>
                    <div class="whisker-progress-info" id="progress-info">
                        <div class="whisker-stat-row">
                            <span class="whisker-stat-label">Passages Visited</span>
                            <span class="whisker-stat-value" id="visited-count">0</span>
                        </div>
                    </div>
                </div>
                <div class="whisker-sidebar-section">
                    <div class="whisker-sidebar-heading">History</div>
                    <div class="whisker-history" id="history-container"></div>
                </div>
            </div>`;
    }

    /**
     * Get Lua player script
     */
    static getLuaPlayerScript() {
        // Read the content from lua-whisker-player.js
        // For now, we'll inline it directly
        // In production, you'd fetch it or bundle it
        return `<script>
        ${this.getLuaWhiskerPlayerCode()}
    </script>`;
    }

    /**
     * Get standard player script (no Lua)
     */
    static getStandardPlayerScript() {
        return `<script>
        ${this.getStandardWhiskerPlayerCode()}
    </script>`;
    }

    /**
     * Get LuaWhiskerPlayer code
     * This should be the actual code from lua-whisker-player.js
     */
    static getLuaWhiskerPlayerCode() {
        // AUTO-GENERATED: Synced from lua-whisker-player.js
        // DO NOT EDIT MANUALLY - Run sync-player-code.js to update
        return `
class LuaWhiskerPlayer {
    constructor() {
        this.story = null;
        this.currentPassage = null;
        this.variables = {};
        this.visited = {};
        this.history = [];
        this.maxHistory = 50;
        this.luaState = null;
        this.initializeLua();
    }

    /**
     * Sanitize HTML to prevent XSS attacks
     * Allows only safe formatting tags
     * @param {string} html - HTML to sanitize
     * @returns {string} Sanitized HTML
     */
    sanitizeHTML(html) {
        if (!html) return '';

        const div = document.createElement('div');
        div.innerHTML = html;

        // Allowed tags for formatting
        const allowedTags = ['strong', 'em', 'b', 'i', 'span', 'p', 'br', 'code'];
        const allowedAttrs = ['class']; // Only allow class attribute

        const walk = (node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
                // Check if tag is allowed
                if (!allowedTags.includes(node.tagName.toLowerCase())) {
                    // Replace with text content
                    const textNode = document.createTextNode(node.textContent);
                    node.parentNode.replaceChild(textNode, node);
                    return;
                }

                // Remove disallowed attributes
                Array.from(node.attributes).forEach(attr => {
                    if (!allowedAttrs.includes(attr.name.toLowerCase())) {
                        node.removeAttribute(attr.name);
                    }
                });

                // Recursively process children
                Array.from(node.childNodes).forEach(child => walk(child));
            }
        };

        Array.from(div.childNodes).forEach(child => walk(child));
        return div.innerHTML;
    }

    /**
     * Escape HTML for safe display
     * @param {string} text - Text to escape
     * @returns {string} Escaped text
     */
    escapeHTML(text) {
        if (!text) return '';
        return String(text)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    /**
     * Initialize Fengari Lua runtime
     */
    initializeLua() {
        if (typeof fengari === 'undefined') {
            console.error('[LuaWhiskerPlayer] Fengari not loaded!');
            return;
        }

        const lua = fengari.lua;
        const lauxlib = fengari.lauxlib;
        const lualib = fengari.lualib;

        this.luaState = lauxlib.luaL_newstate();
        lualib.luaL_openlibs(this.luaState);

        console.log('[LuaWhiskerPlayer] ✅ Lua runtime initialized');
    }

    /**
     * Load story data
     * @param {Object} storyData - Story data object
     */
    loadStory(storyData) {
        this.story = storyData;

        // Extract initial values from variable definitions
        // Variables can be either:
        // 1. Objects with {initial, type, description} structure (from editor)
        // 2. Plain values (from simple JSON)
        this.variables = {};
        if (storyData.variables) {
            for (const [name, varData] of Object.entries(storyData.variables)) {
                if (typeof varData === 'object' && varData !== null && 'initial' in varData) {
                    // Editor format: extract initial value
                    this.variables[name] = varData.initial;
                } else {
                    // Simple format: use value directly
                    this.variables[name] = varData;
                }
            }
        }

        const titleEl = document.getElementById('story-title');
        if (titleEl) {
            titleEl.textContent = storyData.title || 'Whisker Story';
        }

        const authorEl = document.getElementById('story-author');
        if (authorEl) {
            if (storyData.author) {
                authorEl.textContent = 'by ' + storyData.author;
                authorEl.style.display = 'block';
            } else {
                authorEl.style.display = 'none';
            }
        }

        this.updateStats();
    }

    /**
     * Start the story
     */
    start() {
        if (!this.story) {
            console.error('[LuaWhiskerPlayer] No story loaded');
            return;
        }

        if (!this.story.passages || !Array.isArray(this.story.passages)) {
            console.error('[LuaWhiskerPlayer] Story has invalid passages data');
            return;
        }

        if (this.story.passages.length === 0) {
            console.error('[LuaWhiskerPlayer] Story has no passages');
            return;
        }

        const startPassage = this.story.start || this.story.passages[0].id;
        this.goToPassage(startPassage);
    }

    /**
     * Navigate to a passage
     * @param {string} passageId - ID of passage to navigate to
     * @param {boolean} saveHistory - Whether to save to history
     */
    goToPassage(passageId, saveHistory = true) {
        const passage = this.story.passages.find(p => p.id === passageId);

        if (!passage) {
            console.error('[LuaWhiskerPlayer] Passage not found:', passageId);
            return;
        }

        if (saveHistory && this.currentPassage) {
            this.history.push({
                passageId: this.currentPassage.id,
                variables: {...this.variables},
                visited: {...this.visited}
            });

            if (this.history.length > this.maxHistory) {
                this.history.shift();
            }
        }

        this.currentPassage = passage;
        this.visited[passageId] = (this.visited[passageId] || 0) + 1;

        if (passage.script) {
            this.executeScript(passage.script);
        }

        this.render();
        this.updateProgress();
        this.updateHistory();
    }

    /**
     * Render current passage
     */
    render() {
        const passage = this.currentPassage;

        const titleEl = document.getElementById('passage-title');
        if (titleEl) {
            // Sanitize HTML to prevent XSS
            titleEl.innerHTML = this.sanitizeHTML(this.processInline(passage.title || ''));
        }

        const contentEl = document.getElementById('passage-content');
        if (contentEl) {
            const content = this.processContent(passage.content);
            // Sanitize HTML to prevent XSS
            contentEl.innerHTML = this.sanitizeHTML(content);
        }

        const choicesContainer = document.getElementById('choices-container');
        if (choicesContainer) {
            choicesContainer.innerHTML = '';

            if (passage.choices && passage.choices.length > 0) {
                passage.choices.forEach(choice => {
                    if (this.evaluateCondition(choice.condition)) {
                        const btn = document.createElement('button');
                        btn.className = 'choice-btn';
                        // Sanitize HTML to prevent XSS
                        btn.innerHTML = this.sanitizeHTML(this.processInline(choice.text));
                        btn.onclick = () => {
                            if (choice.script) {
                                this.executeScript(choice.script);
                            }
                            this.goToPassage(choice.target);
                        };
                        choicesContainer.appendChild(btn);
                    }
                });
            }
        }

        this.updateStats();
    }

    /**
     * Execute Lua code
     * @param {string} code - Lua code to execute
     */
    executeLuaCode(code) {
        if (!this.luaState || typeof fengari === 'undefined') {
            console.error('[LuaWhiskerPlayer] Lua not available');
            return;
        }

        try {
            const lua = fengari.lua;
            const lauxlib = fengari.lauxlib;
            const to_jsstring = fengari.to_jsstring;

            // Create game_state table with get/set methods
            const luaCode = \`
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
                \${code}
            \`;

            // Register JavaScript callbacks
            const L = this.luaState;

            // js_set_variable callback
            lua.lua_pushcfunction(L, (L) => {
                const key = to_jsstring(lua.lua_tostring(L, -2));
                const value = lua.lua_tonumber(L, -1) !== null ?
                    lua.lua_tonumber(L, -1) :
                    (lua.lua_toboolean(L, -1) ?
                        lua.lua_toboolean(L, -1) :
                        to_jsstring(lua.lua_tostring(L, -1)));

                this.variables[key] = value;
                return 0;
            });
            lua.lua_setglobal(L, to_jsstring("js_set_variable"));

            // js_get_variable callback
            lua.lua_pushcfunction(L, (L) => {
                const key = to_jsstring(lua.lua_tostring(L, -1));
                const value = this.variables[key];

                if (typeof value === 'number') {
                    lua.lua_pushnumber(L, value);
                } else if (typeof value === 'boolean') {
                    lua.lua_pushboolean(L, value);
                } else if (typeof value === 'string') {
                    // Push JavaScript string directly to Lua stack
                    // to_jsstring converts Lua->JS, not JS->Lua
                    lua.lua_pushstring(L, value);
                } else {
                    lua.lua_pushnil(L);
                }

                return 1;
            });
            lua.lua_setglobal(L, to_jsstring("js_get_variable"));

            // Execute Lua code
            lauxlib.luaL_dostring(L, to_jsstring(luaCode));

        } catch (error) {
            console.error('[LuaWhiskerPlayer] ❌ Lua execution error:', error);
        }
    }

    /**
     * Process inline content (Lua, conditionals, variables, markdown)
     * @param {string} content - Content to process
     * @returns {string} Processed content
     */
    processInline(content) {
        if (!content) return '';

        // Process {{lua:}} blocks FIRST
        content = content.replace(/\\{\\{lua:([\\s\\S]*?)\\}\\}/g, (match, code) => {
            this.executeLuaCode(code.trim());
            return ''; // Lua blocks don't output text
        });

        // Process {{#if}}...{{/if}} conditionals
        content = this.processConditionals(content);

        // Process {{variable}} expressions
        content = content.replace(/\\{\\{([a-zA-Z_][a-zA-Z0-9_]*)\\}\\}/g, (match, varName) => {
            varName = varName.trim();
            if (this.variables.hasOwnProperty(varName)) {
                return String(this.variables[varName]);
            }
            return \`<span style="color: #ef4444;">[\${varName}]</span>\`;
        });

        // Process markdown
        content = content.replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>');
        content = content.replace(/\\*(.+?)\\*/g, '<em>$1</em>');

        return content;
    }

    /**
     * Process conditional blocks
     * @param {string} content - Content with conditionals
     * @returns {string} Processed content
     */
    processConditionals(content) {
        let maxIterations = 100;
        let iteration = 0;

        while (content.includes('{{#if') && iteration < maxIterations) {
            iteration++;

            const ifMatch = content.match(/\\{\\{#if\\s+([^}]+)\\}\\}/);
            if (!ifMatch) break;

            const ifStart = ifMatch.index;
            const ifEnd = ifStart + ifMatch[0].length;
            const condition = ifMatch[1];

            const endifMatch = content.substring(ifEnd).match(/\\{\\{\\/if\\}\\}/);
            if (!endifMatch) break;

            const endifStart = ifEnd + endifMatch.index;
            const endifEnd = endifStart + endifMatch[0].length;
            const blockContent = content.substring(ifEnd, endifStart);

            // Parse else if / else
            const blocks = this.parseConditionalBlocks(blockContent, condition);

            let replacement = '';
            for (const block of blocks) {
                if (block.condition === null || this.evaluateCondition(block.condition)) {
                    replacement = block.content;
                    break;
                }
            }

            content = content.substring(0, ifStart) + replacement + content.substring(endifEnd);
        }

        return content;
    }

    /**
     * Parse conditional blocks (if/else if/else)
     * @param {string} blockContent - Content between {{#if}} and {{/if}}
     * @param {string} initialCondition - Initial condition
     * @returns {Array} Array of {condition, content} blocks
     */
    parseConditionalBlocks(blockContent, initialCondition) {
        const blocks = [{condition: initialCondition, content: ''}];
        let currentBlock = 0;
        let pos = 0;

        while (pos < blockContent.length) {
            const elseIfMatch = blockContent.substring(pos).match(/\\{\\{else if\\s+([^}]+)\\}\\}/);
            const elseMatch = blockContent.substring(pos).match(/\\{\\{else\\}\\}/);

            let nextPos = blockContent.length;
            let newCondition = null;

            if (elseIfMatch && (!elseMatch || elseIfMatch.index < elseMatch.index)) {
                blocks[currentBlock].content = blockContent.substring(0, pos + elseIfMatch.index);
                newCondition = elseIfMatch[1];
                nextPos = pos + elseIfMatch.index + elseIfMatch[0].length;
            } else if (elseMatch) {
                blocks[currentBlock].content = blockContent.substring(0, pos + elseMatch.index);
                newCondition = null;
                nextPos = pos + elseMatch.index + elseMatch[0].length;
            } else {
                blocks[currentBlock].content = blockContent.substring(pos);
                break;
            }

            blocks.push({condition: newCondition, content: ''});
            currentBlock++;
            blockContent = blockContent.substring(nextPos);
            pos = 0;
        }

        return blocks;
    }

    /**
     * Process content (add paragraphs)
     * @param {string} content - Content to process
     * @returns {string} Processed content
     */
    processContent(content) {
        if (!content) return '';

        content = this.processInline(content);

        const paragraphs = content.split(/\\n\\n+/).filter(p => p.trim());
        content = paragraphs.map(p => \`<p>\${p.trim()}</p>\`).join('');

        return content;
    }

    /**
     * Execute JavaScript passage script
     * @param {string} script - JavaScript code to execute
     */
    executeScript(script) {
        try {
            // Create API functions
            const set = (key, value) => { this.variables[key] = value; };
            const get = (key, defaultValue = null) => this.variables[key] !== undefined ? this.variables[key] : defaultValue;
            const visited = (passageId) => this.visited[passageId] || 0;
            const random = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

            // Create function with explicit parameters instead of with()
            // This is safer and avoids deprecated with statement
            const func = new Function(
                'set', 'get', 'visited', 'random', 'Math',
                script
            );
            func(set, get, visited, random, Math);
            this.updateStats();
        } catch (error) {
            console.error('[LuaWhiskerPlayer] Script execution error:', error);
        }
    }

    /**
     * Evaluate a condition
     * @param {string} condition - Condition to evaluate
     * @returns {boolean} Result
     */
    evaluateCondition(condition) {
        if (!condition) return true;

        try {
            // Create explicit parameters for all variables and functions
            const visited = (passageId) => this.visited[passageId] || 0;
            const varNames = Object.keys(this.variables);
            const varValues = Object.values(this.variables);

            // Create function with explicit parameters instead of with()
            // This is safer and avoids deprecated with statement
            const func = new Function(
                ...varNames,
                'visited',
                \`return \${condition};\`
            );
            return func(...varValues, visited);
        } catch (error) {
            console.error('[LuaWhiskerPlayer] Condition evaluation error:', error);
            return true;
        }
    }

    /**
     * Update stats display
     */
    updateStats() {
        const container = document.getElementById('stats-container');
        if (!container) return;

        container.innerHTML = '';

        for (const [key, value] of Object.entries(this.variables)) {
            const statItem = document.createElement('div');
            statItem.className = 'stat-item';

            // Use safe DOM manipulation instead of innerHTML
            const labelSpan = document.createElement('span');
            labelSpan.className = 'stat-label';
            labelSpan.textContent = key; // textContent is XSS-safe

            const valueSpan = document.createElement('span');
            valueSpan.className = 'stat-value';
            valueSpan.textContent = String(value); // textContent is XSS-safe

            statItem.appendChild(labelSpan);
            statItem.appendChild(valueSpan);
            container.appendChild(statItem);
        }
    }

    /**
     * Update progress bar
     */
    updateProgress() {
        const progressBar = document.getElementById('progress-bar');
        if (!progressBar) return;

        const totalPassages = this.story.passages.length;
        const visitedCount = Object.keys(this.visited).length;
        const percentage = (visitedCount / totalPassages) * 100;
        progressBar.style.width = percentage + '%';
    }

    /**
     * Update history display
     */
    updateHistory() {
        const container = document.getElementById('history-container');
        if (!container) return;

        const recentHistory = this.history.slice(-5).reverse();
        container.innerHTML = '';

        recentHistory.forEach(entry => {
            const passage = this.story.passages.find(p => p.id === entry.passageId);
            if (passage) {
                const item = document.createElement('div');
                item.className = 'history-item';
                item.textContent = passage.title || passage.id;
                container.appendChild(item);
            }
        });
    }

    /**
     * Undo last action
     */
    undo() {
        if (this.history.length === 0) {
            this.showNotification('No more history', 'info');
            return;
        }

        const previousState = this.history.pop();
        this.variables = {...previousState.variables};
        this.visited = {...previousState.visited};
        this.goToPassage(previousState.passageId, false);
        this.showNotification('Undone', 'success');
    }

    /**
     * Restart story
     */
    restart() {
        if (confirm('Are you sure you want to restart the story?')) {
            // Extract initial values properly (same logic as loadStory)
            this.variables = {};
            if (this.story.variables) {
                for (const [name, varData] of Object.entries(this.story.variables)) {
                    if (typeof varData === 'object' && varData !== null && 'initial' in varData) {
                        this.variables[name] = varData.initial;
                    } else {
                        this.variables[name] = varData;
                    }
                }
            }

            this.visited = {};
            this.history = [];
            this.start();
            this.showNotification('Story restarted', 'info');
        }
    }

    /**
     * Show save modal
     */
    showSaveModal() {
        const saveData = {
            passageId: this.currentPassage.id,
            variables: this.variables,
            visited: this.visited,
            history: this.history,
            timestamp: new Date().toISOString()
        };

        localStorage.setItem('whisker_save', JSON.stringify(saveData));
        this.showNotification('Game saved', 'success');
    }

    /**
     * Show load modal
     */
    showLoadModal() {
        const saveData = localStorage.getItem('whisker_save');

        if (!saveData) {
            this.showNotification('No save found', 'error');
            return;
        }

        try {
            // Parse and validate save data
            const data = JSON.parse(saveData);

            // Validate save data structure
            if (!data || typeof data !== 'object') {
                throw new Error('Invalid save data format');
            }

            if (!data.passageId || typeof data.passageId !== 'string') {
                throw new Error('Save data missing passage ID');
            }

            if (!data.variables || typeof data.variables !== 'object') {
                throw new Error('Save data missing variables');
            }

            if (!data.visited || typeof data.visited !== 'object') {
                throw new Error('Save data missing visited tracking');
            }

            if (!Array.isArray(data.history)) {
                throw new Error('Save data missing history');
            }

            // Verify passage exists in story
            const passage = this.story.passages.find(p => p.id === data.passageId);
            if (!passage) {
                throw new Error('Save references non-existent passage: ' + data.passageId);
            }

            // Load validated data
            this.variables = data.variables;
            this.visited = data.visited;
            this.history = data.history;
            this.goToPassage(data.passageId, false);
            this.showNotification('Game loaded', 'success');

        } catch (error) {
            console.error('[LuaWhiskerPlayer] Load failed:', error);
            this.showNotification('Failed to load save: ' + error.message, 'error');
        }
    }

    /**
     * Show notification
     * @param {string} message - Message to show
     * @param {string} type - Type (success, error, info)
     */
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = \`notification \${type}\`;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
}

// Make available globally
if (typeof window !== 'undefined') {
    window.LuaWhiskerPlayer = LuaWhiskerPlayer;
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LuaWhiskerPlayer;
}`;
    }
    /**
     * Get standard WhiskerPlayer code (no Lua support)
     */
    static getStandardWhiskerPlayerCode() {
        return `
// Standard WhiskerPlayer (no Lua support)
// Simplified version of LuaWhiskerPlayer without Lua dependencies
// [Implementation would be similar to LuaWhiskerPlayer but without Lua methods]
// For brevity, reusing LuaWhiskerPlayer structure but skipping Lua initialization
${this.getLuaWhiskerPlayerCode().replace('this.initializeLua();', '// No Lua support').replace('executeLuaCode', 'skipLuaCode')}`;
    }

    /**
     * Get initialization script
     * @param {Object} storyData - Story data
     */
    static getInitializationScript(storyData) {
        return `<script>
        // Story data
        const STORY_DATA = ${JSON.stringify(storyData, null, 2)};

        // Initialize player
        window.player = new LuaWhiskerPlayer();
        player.loadStory(STORY_DATA);
        player.start();

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                if (e.key === 's') {
                    e.preventDefault();
                    player.showSaveModal();
                } else if (e.key === 'z') {
                    e.preventDefault();
                    player.undo();
                } else if (e.key === 'l') {
                    e.preventDefault();
                    player.showLoadModal();
                }
            }
        });

        console.log('✨ Whisker story loaded successfully!');
        console.log('Passages:', STORY_DATA.passages.length);
        console.log('Variables:', Object.keys(STORY_DATA.variables || {}).length);
    </script>`;
    }

    /**
     * Escape HTML
     * @param {string} text - Text to escape
     * @returns {string} Escaped text
     */
    static escape(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Make available globally
if (typeof window !== 'undefined') {
    window.RuntimeTemplate = RuntimeTemplate;
}
