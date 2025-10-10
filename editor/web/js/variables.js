/**
 * Whisker Story Editor - Variables Manager
 * Phase 3 - Enhanced Features
 */

class VariablesManager {
    constructor(editor) {
        this.editor = editor;
        this.collapsed = false;
    }

    /**
     * Initialize the variables manager
     */
    initialize() {
        this.setupEventListeners();
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Panel toggle
        const toggleBtn = document.getElementById('toggleVariables');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', () => this.togglePanel());
        }
    }

    /**
     * Toggle variables panel
     */
    togglePanel() {
        this.collapsed = !this.collapsed;
        const panel = document.querySelector('.variables-panel');
        if (panel) {
            if (this.collapsed) {
                panel.classList.add('collapsed');
            } else {
                panel.classList.remove('collapsed');
            }
        }
    }

    /**
     * Render the variables list
     */
    render() {
        if (!this.editor.project) return;

        const container = document.getElementById('variablesList');
        if (!container) return;

        const variables = this.editor.project.variables || {};
        const entries = Object.entries(variables);

        if (entries.length === 0) {
            container.innerHTML = '<p style="color: #888; text-align: center; padding: 20px;">No variables defined</p>';
            return;
        }

        container.innerHTML = entries.map(([name, data]) => {
            const value = data.initial !== undefined ? data.initial : '';
            const type = data.type || 'string';
            
            return `
                <div class="variable-item">
                    <div class="variable-header">
                        <span class="variable-name">${name}</span>
                        <span class="variable-type">${type}</span>
                    </div>
                    <input type="${this.getInputType(type)}" 
                           class="variable-value" 
                           value="${value}"
                           onchange="variablesManager.updateVariable('${name}', this.value, '${type}')">
                    <div class="variable-actions">
                        <button class="btn-small btn-secondary" 
                                onclick="variablesManager.editVariable('${name}')">Edit</button>
                        <button class="btn-small btn-danger" 
                                onclick="variablesManager.deleteVariable('${name}')">Delete</button>
                    </div>
                </div>
            `;
        }).join('');
    }

    /**
     * Get HTML input type for variable type
     */
    getInputType(type) {
        switch (type) {
            case 'number': return 'number';
            case 'boolean': return 'checkbox';
            default: return 'text';
        }
    }

    /**
     * Add a new variable
     */
    addVariable() {
        if (!this.editor.project) return;

        const name = prompt("Variable name (use lowercase, no spaces):");
        if (!name) return;

        // Validate name
        if (!/^[a-z_][a-z0-9_]*$/i.test(name)) {
            alert("Invalid variable name. Use only letters, numbers, and underscores.");
            return;
        }

        if (this.editor.project.variables[name]) {
            alert("A variable with this name already exists.");
            return;
        }

        const type = prompt("Variable type (string, number, boolean):", "string");
        if (!type) return;

        let initialValue = '';
        if (type === 'number') {
            initialValue = 0;
        } else if (type === 'boolean') {
            initialValue = false;
        }

        this.editor.project.variables[name] = {
            type: type,
            initial: initialValue
        };

        this.editor.saveToHistory();
        this.render();
        this.editor.updateStatus(`Added variable: ${name}`);
    }

    /**
     * Update variable value
     */
    updateVariable(name, value, type) {
        if (!this.editor.project || !this.editor.project.variables[name]) return;

        let parsedValue = value;
        if (type === 'number') {
            parsedValue = parseFloat(value) || 0;
        } else if (type === 'boolean') {
            parsedValue = value === 'true' || value === true;
        }

        this.editor.project.variables[name].initial = parsedValue;
        this.editor.saveToHistory();
        this.editor.project.metadata.modified = new Date().toISOString();
    }

    /**
     * Edit variable properties
     */
    editVariable(name) {
        if (!this.editor.project || !this.editor.project.variables[name]) return;

        const variable = this.editor.project.variables[name];
        
        const newName = prompt("Variable name:", name);
        if (!newName || newName === name) return;

        // Validate new name
        if (!/^[a-z_][a-z0-9_]*$/i.test(newName)) {
            alert("Invalid variable name.");
            return;
        }

        if (this.editor.project.variables[newName]) {
            alert("A variable with this name already exists.");
            return;
        }

        // Rename variable
        this.editor.project.variables[newName] = variable;
        delete this.editor.project.variables[name];

        this.editor.saveToHistory();
        this.render();
        this.editor.updateStatus(`Renamed variable to: ${newName}`);
    }

    /**
     * Delete a variable
     */
    deleteVariable(name) {
        if (!this.editor.project || !this.editor.project.variables[name]) return;

        if (!confirm(`Delete variable "${name}"?`)) return;

        delete this.editor.project.variables[name];
        
        this.editor.saveToHistory();
        this.render();
        this.editor.updateStatus(`Deleted variable: ${name}`);
    }

    /**
     * Get all variable names
     */
    getVariableNames() {
        if (!this.editor.project) return [];
        return Object.keys(this.editor.project.variables || {});
    }

    /**
     * Insert variable syntax at cursor
     */
    insertVariableSyntax(variableName) {
        const textarea = document.getElementById('passageContent');
        if (!textarea) return;

        const syntax = `{{${variableName}}}`;
        const start = textarea.selectionStart;
        const end = textarea.selectionEnd;
        const text = textarea.value;

        textarea.value = text.substring(0, start) + syntax + text.substring(end);
        textarea.selectionStart = textarea.selectionEnd = start + syntax.length;
        textarea.focus();

        this.editor.updateCurrentPassage();
    }

    /**
     * Show insert variable popup
     */
    showInsertPopup(event) {
        const popup = document.getElementById('insertVariablePopup');
        if (!popup) return;

        const variables = this.getVariableNames();
        if (variables.length === 0) {
            alert("No variables defined. Add variables first.");
            return;
        }

        const listHtml = variables.map(name => `
            <div class="variable-list-item" onclick="variablesManager.insertVariableSyntax('${name}')">
                <span>${name}</span>
                <span class="variable-syntax">{{${name}}}</span>
            </div>
        `).join('');

        popup.innerHTML = listHtml;
        popup.classList.remove('hidden');

        // Position near button
        const rect = event.target.getBoundingClientRect();
        popup.style.left = rect.left + 'px';
        popup.style.top = (rect.bottom + 5) + 'px';

        // Close on click outside
        setTimeout(() => {
            document.addEventListener('click', () => {
                popup.classList.add('hidden');
            }, { once: true });
        }, 0);
    }
}

// Global instance
let variablesManager = null;