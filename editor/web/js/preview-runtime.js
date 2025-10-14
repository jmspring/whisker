/**
 * PreviewRuntime - In-editor story preview with live execution
 *
 * Provides real-time story testing with variable tracking, choice execution,
 * and debug information display.
 */
class PreviewRuntime {
    constructor(editor) {
        this.editor = editor;

        // Runtime state
        this.currentPassage = null;
        this.currentPassageId = null;
        this.visitedPassages = new Set();
        this.variables = {};
        this.history = [];
        this.maxHistory = 50;

        // Configuration
        this.config = {
            enableDebug: true,
            trackHistory: true,
            highlightVisited: true,
            showVariables: true,
            autoSave: false
        };

        // Debug information
        this.debugInfo = {
            passagesVisited: 0,
            choicesMade: 0,
            variablesChanged: 0,
            startTime: null,
            sessionTime: 0
        };

        // UI elements (will be set during initialization)
        this.previewContent = null;
        this.previewDebug = null;
        this.previewControls = null;
    }

    /**
     * Initialize the preview runtime
     */
    initialize() {
        this.previewContent = document.getElementById('previewContent');

        // Create debug panel if it doesn't exist
        if (!document.getElementById('previewDebug')) {
            this.createDebugPanel();
        }

        this.previewDebug = document.getElementById('previewDebug');
        this.previewControls = document.querySelector('.preview-header');

        // Add additional controls
        this.enhanceControls();

        console.log('[PreviewRuntime] Initialized');
    }

    /**
     * Create debug panel for showing variables and state
     */
    createDebugPanel() {
        const previewPanel = document.querySelector('.preview-panel');
        if (!previewPanel) return;

        const debugPanel = document.createElement('div');
        debugPanel.id = 'previewDebug';
        debugPanel.className = 'preview-debug hidden';
        debugPanel.innerHTML = `
            <div class="debug-section">
                <h4>Variables</h4>
                <div id="debugVariables" class="debug-variables"></div>
            </div>
            <div class="debug-section">
                <h4>Session Info</h4>
                <div id="debugSession" class="debug-session"></div>
            </div>
            <div class="debug-section">
                <h4>History</h4>
                <div id="debugHistory" class="debug-history"></div>
            </div>
        `;

        previewPanel.appendChild(debugPanel);
    }

    /**
     * Enhance preview controls with additional buttons
     */
    enhanceControls() {
        const header = document.querySelector('.preview-header');
        if (!header) return;

        // Add debug toggle
        const debugBtn = document.createElement('button');
        debugBtn.className = 'btn-small btn-secondary';
        debugBtn.textContent = '🐛';
        debugBtn.title = 'Toggle Debug Info';
        debugBtn.onclick = () => this.toggleDebug();

        // Add step back button
        const backBtn = document.createElement('button');
        backBtn.className = 'btn-small btn-secondary';
        backBtn.textContent = '↶';
        backBtn.title = 'Go Back';
        backBtn.onclick = () => this.goBack();
        backBtn.id = 'previewBackBtn';

        // Insert before restart button
        const restartBtn = header.querySelector('button');
        if (restartBtn) {
            header.insertBefore(debugBtn, restartBtn);
            header.insertBefore(backBtn, restartBtn);
        }
    }

    /**
     * Start or restart the story preview
     */
    start() {
        if (!this.editor.project) {
            this.showError('No project loaded');
            return;
        }

        // Reset state
        this.reset();

        // Start timing
        this.debugInfo.startTime = Date.now();

        // Navigate to start passage
        const startPassageId = this.editor.project.settings.startPassage;
        if (!startPassageId) {
            this.showError('No start passage set');
            return;
        }

        this.navigateToPassage(startPassageId);

        console.log('[PreviewRuntime] Started preview');
    }

    /**
     * Reset the preview state
     */
    reset() {
        this.currentPassage = null;
        this.currentPassageId = null;
        this.visitedPassages.clear();
        this.variables = {};
        this.history = [];

        this.debugInfo = {
            passagesVisited: 0,
            choicesMade: 0,
            variablesChanged: 0,
            startTime: Date.now(),
            sessionTime: 0
        };
    }

    /**
     * Navigate to a specific passage
     * @param {string} passageId - ID of the passage to navigate to
     */
    navigateToPassage(passageId) {
        const passage = this.editor.getPassage(passageId);
        if (!passage) {
            this.showError(`Passage not found: ${passageId}`);
            return;
        }

        // Save current state to history
        if (this.config.trackHistory && this.currentPassageId) {
            this.addToHistory({
                passageId: this.currentPassageId,
                variables: {...this.variables},
                timestamp: Date.now()
            });
        }

        // Update state
        this.currentPassage = passage;
        this.currentPassageId = passageId;
        this.visitedPassages.add(passageId);
        this.debugInfo.passagesVisited++;

        // Render the passage
        this.render();

        // Update debug info
        this.updateDebug();
    }

    /**
     * Make a choice and navigate to target
     * @param {number} choiceIndex - Index of the choice to make
     */
    makeChoice(choiceIndex) {
        if (!this.currentPassage || !this.currentPassage.choices[choiceIndex]) {
            return;
        }

        const choice = this.currentPassage.choices[choiceIndex];

        // Check if choice is available (conditional)
        if (choice.condition && !this.evaluateCondition(choice.condition)) {
            console.log('[PreviewRuntime] Choice not available:', choice.condition);
            return;
        }

        // Execute choice action (set variables, etc.)
        if (choice.action) {
            this.executeAction(choice.action);
        }

        this.debugInfo.choicesMade++;

        // Navigate to target passage
        if (choice.target) {
            this.navigateToPassage(choice.target);
        }
    }

    /**
     * Go back to previous passage
     */
    goBack() {
        if (this.history.length === 0) {
            return;
        }

        const previousState = this.history.pop();
        this.variables = previousState.variables;
        this.navigateToPassage(previousState.passageId);

        // Don't add to history again
        this.history.pop();
    }

    /**
     * Evaluate a condition expression
     * @param {string} condition - Condition to evaluate
     * @returns {boolean} Result of condition
     */
    evaluateCondition(condition) {
        try {
            // Simple variable substitution for common patterns
            let expr = condition;

            // Replace variable references: health > 50 -> this.variables.health > 50
            expr = expr.replace(/\b([a-zA-Z_]\w*)\b/g, (match) => {
                if (['true', 'false', 'null', 'undefined', 'and', 'or', 'not'].includes(match)) {
                    return match;
                }
                return `this.variables.${match}`;
            });

            // Simple evaluation (not production-safe, but okay for preview)
            const result = eval(expr);
            return !!result;
        } catch (e) {
            console.error('[PreviewRuntime] Condition evaluation error:', e);
            return false;
        }
    }

    /**
     * Execute an action (set variables, etc.)
     * @param {string} action - Action to execute
     */
    executeAction(action) {
        try {
            // Parse simple actions like "health = health - 10" or "hasKey = true"
            const setMatch = action.match(/(\w+)\s*=\s*(.+)/);
            if (setMatch) {
                const varName = setMatch[1];
                let value = setMatch[2].trim();

                // Evaluate the value
                value = value.replace(/\b([a-zA-Z_]\w*)\b/g, (match) => {
                    if (['true', 'false', 'null', 'undefined'].includes(match)) {
                        return match;
                    }
                    if (this.variables.hasOwnProperty(match)) {
                        return `this.variables.${match}`;
                    }
                    return match;
                });

                const result = eval(value);
                this.setVariable(varName, result);
            }
        } catch (e) {
            console.error('[PreviewRuntime] Action execution error:', e);
        }
    }

    /**
     * Set a variable value
     * @param {string} name - Variable name
     * @param {*} value - Variable value
     */
    setVariable(name, value) {
        const oldValue = this.variables[name];
        this.variables[name] = value;

        if (oldValue !== value) {
            this.debugInfo.variablesChanged++;
        }

        console.log(`[PreviewRuntime] Set variable: ${name} = ${value}`);
        this.updateDebug();
    }

    /**
     * Get a variable value
     * @param {string} name - Variable name
     * @param {*} defaultValue - Default value if not set
     * @returns {*} Variable value
     */
    getVariable(name, defaultValue = undefined) {
        return this.variables.hasOwnProperty(name) ? this.variables[name] : defaultValue;
    }

    /**
     * Render the current passage
     */
    render() {
        if (!this.currentPassage || !this.previewContent) {
            return;
        }

        const passage = this.currentPassage;

        // Process content (substitute variables, render markdown)
        let content = this.processContent(passage.content || '');

        // Build choices HTML
        let choicesHTML = '';
        if (passage.choices && passage.choices.length > 0) {
            choicesHTML = '<div class="preview-choices">';
            passage.choices.forEach((choice, index) => {
                const isAvailable = !choice.condition || this.evaluateCondition(choice.condition);
                const visitedClass = this.visitedPassages.has(choice.target) ? 'visited' : '';
                const disabledClass = !isAvailable ? 'disabled' : '';

                choicesHTML += `
                    <div class="preview-choice ${visitedClass} ${disabledClass}"
                         onclick="previewRuntime.makeChoice(${index})"
                         ${!isAvailable ? 'title="Not available"' : ''}>
                        ${choice.text}
                        ${this.config.enableDebug && choice.condition ?
                            `<span class="choice-condition">${choice.condition}</span>` : ''}
                    </div>
                `;
            });
            choicesHTML += '</div>';
        } else {
            choicesHTML = '<div class="preview-end">— End of Story —</div>';
        }

        // Render to preview panel
        this.previewContent.innerHTML = `
            <div class="preview-passage ${this.config.highlightVisited && this.visitedPassages.has(passage.id) ? 'revisit' : ''}">
                <h3 class="preview-title">${passage.title}</h3>
                <div class="preview-text">${content}</div>
                ${choicesHTML}
            </div>
        `;
    }

    /**
     * Process passage content (variables, markdown, etc.)
     * @param {string} content - Raw content
     * @returns {string} Processed content
     */
    processContent(content) {
        // Substitute variables: {{variable}} -> value
        content = content.replace(/\{\{(\w+)\}\}/g, (match, varName) => {
            const value = this.getVariable(varName);
            return value !== undefined ? value : match;
        });

        // Render markdown (reuse editor's method)
        if (this.editor.renderMarkdown) {
            content = this.editor.renderMarkdown(content);
        }

        return content;
    }

    /**
     * Add state to history
     * @param {object} state - State to save
     */
    addToHistory(state) {
        this.history.push(state);

        // Limit history size
        while (this.history.length > this.maxHistory) {
            this.history.shift();
        }
    }

    /**
     * Toggle debug panel visibility
     */
    toggleDebug() {
        if (!this.previewDebug) return;

        this.previewDebug.classList.toggle('hidden');
        this.config.enableDebug = !this.previewDebug.classList.contains('hidden');

        if (this.config.enableDebug) {
            this.updateDebug();
        }
    }

    /**
     * Update debug information display
     */
    updateDebug() {
        if (!this.config.enableDebug || !this.previewDebug) return;

        // Update session time
        this.debugInfo.sessionTime = Date.now() - this.debugInfo.startTime;

        // Variables section
        const debugVariables = document.getElementById('debugVariables');
        if (debugVariables) {
            if (Object.keys(this.variables).length === 0) {
                debugVariables.innerHTML = '<div class="empty-state">No variables set</div>';
            } else {
                debugVariables.innerHTML = Object.entries(this.variables)
                    .map(([key, value]) => `
                        <div class="debug-variable">
                            <span class="var-name">${key}:</span>
                            <span class="var-value">${JSON.stringify(value)}</span>
                        </div>
                    `).join('');
            }
        }

        // Session info
        const debugSession = document.getElementById('debugSession');
        if (debugSession) {
            const minutes = Math.floor(this.debugInfo.sessionTime / 60000);
            const seconds = Math.floor((this.debugInfo.sessionTime % 60000) / 1000);

            debugSession.innerHTML = `
                <div>Passages visited: ${this.debugInfo.passagesVisited}</div>
                <div>Choices made: ${this.debugInfo.choicesMade}</div>
                <div>Variables changed: ${this.debugInfo.variablesChanged}</div>
                <div>Session time: ${minutes}m ${seconds}s</div>
                <div>Current: ${this.currentPassage ? this.currentPassage.title : 'None'}</div>
            `;
        }

        // History
        const debugHistory = document.getElementById('debugHistory');
        if (debugHistory) {
            if (this.history.length === 0) {
                debugHistory.innerHTML = '<div class="empty-state">No history</div>';
            } else {
                const recentHistory = this.history.slice(-5).reverse();
                debugHistory.innerHTML = recentHistory.map(state => {
                    const passage = this.editor.getPassage(state.passageId);
                    return `
                        <div class="history-item" onclick="previewRuntime.navigateToPassage('${state.passageId}')">
                            ${passage ? passage.title : state.passageId}
                        </div>
                    `;
                }).join('');
            }
        }
    }

    /**
     * Show an error message
     * @param {string} message - Error message
     */
    showError(message) {
        if (!this.previewContent) return;

        this.previewContent.innerHTML = `
            <div class="preview-error">
                <div class="error-icon">⚠️</div>
                <div class="error-message">${message}</div>
            </div>
        `;
    }
}

// Make available globally
if (typeof window !== 'undefined') {
    window.PreviewRuntime = PreviewRuntime;
}
