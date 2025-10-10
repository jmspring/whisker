/**
 * Whisker Story Editor - Settings Manager
 * Phase 4 - Polish & Export
 */

class SettingsManager {
    constructor(editor) {
        this.editor = editor;
        this.settings = {
            // Editor preferences
            autoSave: true,
            autoSaveInterval: 60000, // 1 minute
            autosaveTimer: null,
            
            // Display settings
            fontSize: 14,
            lineHeight: 1.6,
            showLineNumbers: false,
            wordWrap: true,
            
            // Behavior settings
            confirmDelete: true,
            autoValidate: true,
            livePreview: true,
            
            // Graph settings
            autoLayout: true,
            snapToGrid: false,
            gridSize: 20,
            
            // Advanced
            maxHistorySteps: 50,
            debugMode: false
        };

        this.currentTab = 'general';
    }

    /**
     * Initialize settings
     */
    initialize() {
        this.loadSettings();
        this.applySettings();
        
        // Start autosave if enabled
        if (this.settings.autoSave) {
            this.startAutoSave();
        }
    }

    /**
     * Load settings from localStorage
     */
    loadSettings() {
        const saved = localStorage.getItem('whisker_settings');
        if (saved) {
            try {
                const parsed = JSON.parse(saved);
                this.settings = { ...this.settings, ...parsed };
            } catch (e) {
                console.error('Failed to load settings:', e);
            }
        }
    }

    /**
     * Save settings to localStorage
     */
    saveSettings() {
        const toSave = { ...this.settings };
        delete toSave.autosaveTimer; // Don't save timer reference
        
        localStorage.setItem('whisker_settings', JSON.stringify(toSave));
        this.editor.updateStatus('Settings saved');
    }

    /**
     * Apply current settings to editor
     */
    applySettings() {
        const textarea = document.getElementById('passageContent');
        if (textarea) {
            textarea.style.fontSize = this.settings.fontSize + 'px';
            textarea.style.lineHeight = this.settings.lineHeight;
            textarea.style.whiteSpace = this.settings.wordWrap ? 'pre-wrap' : 'pre';
        }

        // Update validation
        if (validationSystem) {
            validationSystem.autoValidate = this.settings.autoValidate;
        }

        // Update history
        if (historySystem) {
            historySystem.maxHistory = this.settings.maxHistorySteps;
        }
    }

    /**
     * Show settings dialog
     */
    showDialog() {
        const modal = document.getElementById('settingsModal');
        if (!modal) return;

        this.render();
        modal.classList.remove('hidden');
    }

    /**
     * Hide settings dialog
     */
    hideDialog() {
        const modal = document.getElementById('settingsModal');
        if (modal) {
            modal.classList.add('hidden');
        }
    }

    /**
     * Switch tab
     */
    switchTab(tab) {
        this.currentTab = tab;
        this.render();
    }

    /**
     * Render settings dialog
     */
    render() {
        this.renderTabs();
        this.renderContent();
    }

    /**
     * Render tabs
     */
    renderTabs() {
        const container = document.getElementById('settingsTabs');
        if (!container) return;

        const tabs = [
            { id: 'general', label: 'General' },
            { id: 'editor', label: 'Editor' },
            { id: 'graph', label: 'Graph' },
            { id: 'advanced', label: 'Advanced' }
        ];

        container.innerHTML = tabs.map(tab => `
            <div class="settings-tab ${tab.id === this.currentTab ? 'active' : ''}"
                 onclick="settingsManager.switchTab('${tab.id}')">
                ${tab.label}
            </div>
        `).join('');
    }

    /**
     * Render content for current tab
     */
    renderContent() {
        const container = document.getElementById('settingsContent');
        if (!container) return;

        switch (this.currentTab) {
            case 'general':
                container.innerHTML = this.renderGeneralSettings();
                break;
            case 'editor':
                container.innerHTML = this.renderEditorSettings();
                break;
            case 'graph':
                container.innerHTML = this.renderGraphSettings();
                break;
            case 'advanced':
                container.innerHTML = this.renderAdvancedSettings();
                break;
        }
    }

    /**
     * Render general settings
     */
    renderGeneralSettings() {
        return `
            <div class="settings-group">
                <h3>Saving</h3>
                ${this.renderToggle('autoSave', 'Auto-save', 'Automatically save your work periodically')}
                ${this.settings.autoSave ? `
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Auto-save interval</div>
                        <div class="settings-item-desc">How often to auto-save (seconds)</div>
                    </div>
                    <input type="number" value="${this.settings.autoSaveInterval / 1000}" 
                           onchange="settingsManager.updateSetting('autoSaveInterval', this.value * 1000)"
                           style="width: 80px; padding: 6px; background: var(--bg-primary); border: 1px solid var(--border-color); color: var(--text-primary); border-radius: 4px;">
                </div>
                ` : ''}
            </div>

            <div class="settings-group">
                <h3>Behavior</h3>
                ${this.renderToggle('confirmDelete', 'Confirm deletions', 'Ask for confirmation before deleting')}
                ${this.renderToggle('autoValidate', 'Auto-validate', 'Automatically check for errors')}
                ${this.renderToggle('livePreview', 'Live preview', 'Update preview as you type')}
            </div>
        `;
    }

    /**
     * Render editor settings
     */
    renderEditorSettings() {
        return `
            <div class="settings-group">
                <h3>Display</h3>
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Font size</div>
                        <div class="settings-item-desc">Editor text size (px)</div>
                    </div>
                    <input type="number" value="${this.settings.fontSize}" min="10" max="24"
                           onchange="settingsManager.updateSetting('fontSize', parseInt(this.value))"
                           style="width: 80px; padding: 6px; background: var(--bg-primary); border: 1px solid var(--border-color); color: var(--text-primary); border-radius: 4px;">
                </div>
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Line height</div>
                        <div class="settings-item-desc">Spacing between lines</div>
                    </div>
                    <input type="number" value="${this.settings.lineHeight}" min="1.0" max="2.5" step="0.1"
                           onchange="settingsManager.updateSetting('lineHeight', parseFloat(this.value))"
                           style="width: 80px; padding: 6px; background: var(--bg-primary); border: 1px solid var(--border-color); color: var(--text-primary); border-radius: 4px;">
                </div>
                ${this.renderToggle('wordWrap', 'Word wrap', 'Wrap long lines in editor')}
            </div>
        `;
    }

    /**
     * Render graph settings
     */
    renderGraphSettings() {
        return `
            <div class="settings-group">
                <h3>Graph Behavior</h3>
                ${this.renderToggle('autoLayout', 'Auto-layout on open', 'Automatically arrange passages when opening')}
                ${this.renderToggle('snapToGrid', 'Snap to grid', 'Align nodes to grid when dragging')}
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Grid size</div>
                        <div class="settings-item-desc">Grid spacing (pixels)</div>
                    </div>
                    <input type="number" value="${this.settings.gridSize}" min="10" max="50"
                           onchange="settingsManager.updateSetting('gridSize', parseInt(this.value))"
                           style="width: 80px; padding: 6px; background: var(--bg-primary); border: 1px solid var(--border-color); color: var(--text-primary); border-radius: 4px;">
                </div>
            </div>
        `;
    }

    /**
     * Render advanced settings
     */
    renderAdvancedSettings() {
        return `
            <div class="settings-group">
                <h3>Performance</h3>
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Max undo steps</div>
                        <div class="settings-item-desc">Number of undo levels to keep</div>
                    </div>
                    <input type="number" value="${this.settings.maxHistorySteps}" min="10" max="100"
                           onchange="settingsManager.updateSetting('maxHistorySteps', parseInt(this.value))"
                           style="width: 80px; padding: 6px; background: var(--bg-primary); border: 1px solid var(--border-color); color: var(--text-primary); border-radius: 4px;">
                </div>
            </div>

            <div class="settings-group">
                <h3>Development</h3>
                ${this.renderToggle('debugMode', 'Debug mode', 'Show console logs and debug info')}
            </div>

            <div class="settings-group">
                <h3>Data</h3>
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Reset settings</div>
                        <div class="settings-item-desc">Restore default settings</div>
                    </div>
                    <button class="btn btn-danger" onclick="settingsManager.resetSettings()">Reset</button>
                </div>
                <div class="settings-item">
                    <div class="settings-item-label">
                        <div class="settings-item-title">Clear cache</div>
                        <div class="settings-item-desc">Clear all stored data</div>
                    </div>
                    <button class="btn btn-danger" onclick="settingsManager.clearCache()">Clear</button>
                </div>
            </div>
        `;
    }

    /**
     * Render toggle switch
     */
    renderToggle(key, title, description) {
        return `
            <div class="settings-item">
                <div class="settings-item-label">
                    <div class="settings-item-title">${title}</div>
                    <div class="settings-item-desc">${description}</div>
                </div>
                <div class="toggle-switch ${this.settings[key] ? 'active' : ''}" 
                     onclick="settingsManager.toggleSetting('${key}')">
                    <div class="toggle-slider"></div>
                </div>
            </div>
        `;
    }

    /**
     * Toggle a boolean setting
     */
    toggleSetting(key) {
        this.settings[key] = !this.settings[key];
        this.saveSettings();
        this.applySettings();
        this.render();

        // Handle special cases
        if (key === 'autoSave') {
            if (this.settings.autoSave) {
                this.startAutoSave();
            } else {
                this.stopAutoSave();
            }
        }
    }

    /**
     * Update a setting value
     */
    updateSetting(key, value) {
        this.settings[key] = value;
        this.saveSettings();
        this.applySettings();

        if (key === 'autoSaveInterval') {
            if (this.settings.autoSave) {
                this.stopAutoSave();
                this.startAutoSave();
            }
        }
    }

    /**
     * Reset all settings to defaults
     */
    resetSettings() {
        if (!confirm('Reset all settings to defaults?')) return;

        localStorage.removeItem('whisker_settings');
        this.initialize();
        this.render();
        this.editor.updateStatus('Settings reset to defaults');
    }

    /**
     * Clear all cached data
     */
    clearCache() {
        if (!confirm('Clear all cached data? This will not affect your saved projects.')) return;

        localStorage.clear();
        this.editor.updateStatus('Cache cleared');
    }

    /**
     * Start auto-save timer
     */
    startAutoSave() {
        this.stopAutoSave(); // Clear any existing timer

        this.settings.autosaveTimer = setInterval(() => {
            if (this.editor.project) {
                this.editor.saveProject();
                console.log('Auto-saved project');
            }
        }, this.settings.autoSaveInterval);
    }

    /**
     * Stop auto-save timer
     */
    stopAutoSave() {
        if (this.settings.autosaveTimer) {
            clearInterval(this.settings.autosaveTimer);
            this.settings.autosaveTimer = null;
        }
    }
}

// Global instance
let settingsManager = null;