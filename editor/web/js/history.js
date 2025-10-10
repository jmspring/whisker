/**
 * Whisker Story Editor - History System (Undo/Redo)
 * Phase 3 - Enhanced Features
 */

class HistorySystem {
    constructor(editor) {
        this.editor = editor;
        this.history = [];
        this.currentIndex = -1;
        this.maxHistory = 50;
        this.isUndoRedoing = false;
    }

    /**
     * Initialize history system
     */
    initialize() {
        this.setupKeyboardShortcuts();
    }

    /**
     * Setup keyboard shortcuts
     */
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Undo: Ctrl/Cmd + Z
            if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
                e.preventDefault();
                this.undo();
            }
            
            // Redo: Ctrl/Cmd + Shift + Z or Ctrl/Cmd + Y
            if ((e.ctrlKey || e.metaKey) && (
                (e.shiftKey && e.key === 'z') || 
                e.key === 'y'
            )) {
                e.preventDefault();
                this.redo();
            }
        });
    }

    /**
     * Save current state to history
     */
    save(description = 'Change') {
        if (this.isUndoRedoing || !this.editor.project) return;

        // Create deep copy of current state
        const state = {
            project: JSON.parse(JSON.stringify(this.editor.project)),
            currentPassageId: this.editor.currentPassageId,
            timestamp: Date.now(),
            description: description
        };

        // Remove any states after current index
        this.history = this.history.slice(0, this.currentIndex + 1);

        // Add new state
        this.history.push(state);
        this.currentIndex++;

        // Limit history size
        if (this.history.length > this.maxHistory) {
            this.history.shift();
            this.currentIndex--;
        }

        this.updateUI();
    }

    /**
     * Undo last action
     */
    undo() {
        if (!this.canUndo()) return;

        this.isUndoRedoing = true;
        this.currentIndex--;

        const state = this.history[this.currentIndex];
        this.restoreState(state);

        this.editor.updateStatus('Undo: ' + state.description);
        this.updateUI();
        
        this.isUndoRedoing = false;
    }

    /**
     * Redo last undone action
     */
    redo() {
        if (!this.canRedo()) return;

        this.isUndoRedoing = true;
        this.currentIndex++;

        const state = this.history[this.currentIndex];
        this.restoreState(state);

        this.editor.updateStatus('Redo: ' + state.description);
        this.updateUI();
        
        this.isUndoRedoing = false;
    }

    /**
     * Restore a saved state
     */
    restoreState(state) {
        this.editor.project = JSON.parse(JSON.stringify(state.project));
        this.editor.currentPassageId = state.currentPassageId;
        this.editor.render();
        
        if (graph) {
            graph.render();
        }
        
        if (variablesManager) {
            variablesManager.render();
        }
    }

    /**
     * Check if undo is available
     */
    canUndo() {
        return this.currentIndex > 0;
    }

    /**
     * Check if redo is available
     */
    canRedo() {
        return this.currentIndex < this.history.length - 1;
    }

    /**
     * Update UI state
     */
    updateUI() {
        const undoBtn = document.getElementById('undoBtn');
        const redoBtn = document.getElementById('redoBtn');
        const indicator = document.getElementById('historyIndicator');

        if (undoBtn) {
            undoBtn.disabled = !this.canUndo();
        }

        if (redoBtn) {
            redoBtn.disabled = !this.canRedo();
        }

        if (indicator) {
            indicator.textContent = `${this.currentIndex + 1} / ${this.history.length}`;
        }
    }

    /**
     * Clear history
     */
    clear() {
        this.history = [];
        this.currentIndex = -1;
        this.updateUI();
    }

    /**
     * Get history info
     */
    getInfo() {
        return {
            total: this.history.length,
            current: this.currentIndex + 1,
            canUndo: this.canUndo(),
            canRedo: this.canRedo()
        };
    }

    /**
     * Get recent history
     */
    getRecent(count = 5) {
        const start = Math.max(0, this.currentIndex - count + 1);
        const end = this.currentIndex + 1;
        return this.history.slice(start, end).map(state => ({
            description: state.description,
            timestamp: state.timestamp,
            isCurrent: state === this.history[this.currentIndex]
        }));
    }
}

// Global instance
let historySystem = null;