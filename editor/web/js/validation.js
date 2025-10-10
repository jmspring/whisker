/**
 * Whisker Story Editor - Validation System
 * Phase 3 - Enhanced Features
 */

class ValidationSystem {
    constructor(editor) {
        this.editor = editor;
        this.issues = [];
        this.autoValidate = true;
    }

    /**
     * Run full validation on the project
     */
    validate() {
        if (!this.editor.project) return;

        this.issues = [];

        // Run all validation checks
        this.checkOrphanedPassages();
        this.checkDeadEnds();
        this.checkBrokenLinks();
        this.checkEmptyPassages();
        this.checkDuplicateIds();
        this.checkVariableUsage();
        this.checkStartPassage();
        this.checkCircularReferences();

        this.render();
        return this.issues;
    }

    /**
     * Check for orphaned passages (not linked from anywhere)
     */
    checkOrphanedPassages() {
        const project = this.editor.project;
        const linkedIds = new Set([project.settings.startPassage]);

        // Collect all linked passage IDs
        project.passages.forEach(passage => {
            passage.choices.forEach(choice => {
                linkedIds.add(choice.target);
            });
        });

        // Find orphaned passages
        project.passages.forEach(passage => {
            if (passage.id !== project.settings.startPassage && !linkedIds.has(passage.id)) {
                this.addIssue('warning', 'Orphaned Passage', 
                    `Passage "${passage.title}" is not linked from any other passage.`,
                    passage.id);
            }
        });
    }

    /**
     * Check for dead ends (passages with no choices)
     */
    checkDeadEnds() {
        const project = this.editor.project;

        project.passages.forEach(passage => {
            if (passage.choices.length === 0) {
                this.addIssue('info', 'Dead End', 
                    `Passage "${passage.title}" has no choices (story ends here).`,
                    passage.id);
            }
        });
    }

    /**
     * Check for broken links
     */
    checkBrokenLinks() {
        const project = this.editor.project;
        const passageIds = new Set(project.passages.map(p => p.id));

        project.passages.forEach(passage => {
            passage.choices.forEach((choice, index) => {
                if (!passageIds.has(choice.target)) {
                    this.addIssue('error', 'Broken Link', 
                        `Choice "${choice.text}" in "${passage.title}" links to non-existent passage "${choice.target}".`,
                        passage.id);
                }
            });
        });
    }

    /**
     * Check for empty passages
     */
    checkEmptyPassages() {
        const project = this.editor.project;

        project.passages.forEach(passage => {
            if (!passage.content || passage.content.trim() === '') {
                this.addIssue('warning', 'Empty Passage', 
                    `Passage "${passage.title}" has no content.`,
                    passage.id);
            }
        });
    }

    /**
     * Check for duplicate passage IDs
     */
    checkDuplicateIds() {
        const project = this.editor.project;
        const idCounts = {};

        project.passages.forEach(passage => {
            idCounts[passage.id] = (idCounts[passage.id] || 0) + 1;
        });

        Object.entries(idCounts).forEach(([id, count]) => {
            if (count > 1) {
                this.addIssue('error', 'Duplicate ID', 
                    `Passage ID "${id}" is used ${count} times. IDs must be unique.`,
                    id);
            }
        });
    }

    /**
     * Check for undefined variables
     */
    checkVariableUsage() {
        const project = this.editor.project;
        const definedVars = new Set(Object.keys(project.variables || {}));
        const variablePattern = /\{\{([a-zA-Z_][a-zA-Z0-9_]*)\}\}/g;

        project.passages.forEach(passage => {
            let match;
            while ((match = variablePattern.exec(passage.content)) !== null) {
                const varName = match[1];
                if (!definedVars.has(varName)) {
                    this.addIssue('warning', 'Undefined Variable', 
                        `Variable "{{${varName}}}" used in "${passage.title}" is not defined.`,
                        passage.id);
                }
            }
        });
    }

    /**
     * Check start passage validity
     */
    checkStartPassage() {
        const project = this.editor.project;
        const startId = project.settings.startPassage;
        
        const startPassage = project.passages.find(p => p.id === startId);
        if (!startPassage) {
            this.addIssue('error', 'Missing Start Passage', 
                `Start passage "${startId}" does not exist.`,
                null);
        }
    }

    /**
     * Check for circular references (passage links to itself)
     */
    checkCircularReferences() {
        const project = this.editor.project;

        project.passages.forEach(passage => {
            passage.choices.forEach(choice => {
                if (choice.target === passage.id) {
                    this.addIssue('warning', 'Self-Reference', 
                        `Passage "${passage.title}" has a choice that links back to itself.`,
                        passage.id);
                }
            });
        });
    }

    /**
     * Add a validation issue
     */
    addIssue(severity, title, message, passageId) {
        this.issues.push({
            severity: severity, // 'error', 'warning', 'info'
            title: title,
            message: message,
            passageId: passageId,
            timestamp: Date.now()
        });
    }

    /**
     * Render the validation panel
     */
    render() {
        const container = document.getElementById('validationList');
        if (!container) return;

        const count = document.getElementById('validationCount');
        const errorCount = this.issues.filter(i => i.severity === 'error').length;
        const warningCount = this.issues.filter(i => i.severity === 'warning').length;

        if (count) {
            if (errorCount > 0) {
                count.textContent = errorCount;
                count.className = 'validation-count';
            } else if (warningCount > 0) {
                count.textContent = warningCount;
                count.className = 'validation-count warning';
            } else {
                count.textContent = '✓';
                count.className = 'validation-count success';
            }
        }

        if (this.issues.length === 0) {
            container.innerHTML = '<p style="color: #888; text-align: center; padding: 20px;">No issues found ✓</p>';
            return;
        }

        container.innerHTML = this.issues.map(issue => {
            const icon = this.getIssueIcon(issue.severity);
            const passage = issue.passageId ? 
                this.editor.project.passages.find(p => p.id === issue.passageId) : null;
            const location = passage ? `Passage: ${passage.title}` : 'Project';

            return `
                <div class="validation-item ${issue.severity}" 
                     onclick="validationSystem.goToIssue('${issue.passageId}')">
                    <div class="validation-icon">${icon}</div>
                    <div class="validation-content">
                        <div class="validation-message">
                            <strong>${issue.title}:</strong> ${issue.message}
                        </div>
                        <div class="validation-location">${location}</div>
                    </div>
                </div>
            `;
        }).join('');
    }

    /**
     * Get icon for issue severity
     */
    getIssueIcon(severity) {
        switch (severity) {
            case 'error': return '⛔';
            case 'warning': return '⚠️';
            case 'info': return 'ℹ️';
            default: return '•';
        }
    }

    /**
     * Navigate to passage with issue
     */
    goToIssue(passageId) {
        if (!passageId) return;

        this.editor.selectPassage(passageId);
        this.editor.switchView('list');
    }

    /**
     * Toggle validation panel
     */
    togglePanel() {
        const panel = document.querySelector('.validation-panel');
        if (!panel) return;

        panel.classList.toggle('collapsed');
    }

    /**
     * Get issue counts
     */
    getCounts() {
        return {
            errors: this.issues.filter(i => i.severity === 'error').length,
            warnings: this.issues.filter(i => i.severity === 'warning').length,
            info: this.issues.filter(i => i.severity === 'info').length,
            total: this.issues.length
        };
    }
}

// Global instance
let validationSystem = null;