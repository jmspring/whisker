/**
 * Twine Importer - UI integration for importing Twine 2 HTML files
 *
 * Provides file selection dialog and confirmation UI for importing
 * Twine stories into the Whisker editor.
 *
 * @version 1.0.0
 */

class TwineImporter {
    constructor(editor) {
        this.editor = editor;
        this.isInitialized = false;
    }

    /**
     * Initialize the Twine importer
     */
    initialize() {
        console.log('[TwineImporter] Initializing...');
        this.isInitialized = true;
        console.log('[TwineImporter] Initialized');
    }

    /**
     * Show file selection dialog for Twine HTML import
     */
    showImportDialog() {
        console.log('[TwineImporter] Showing import dialog...');

        // Check if we have an active project
        const hasActiveProject = this.editor.project &&
                                  this.editor.project.passages &&
                                  this.editor.project.passages.length > 0;

        if (hasActiveProject) {
            const warning = confirm(
                'Warning: Importing will replace your current project.\n\n' +
                'Make sure you have saved your work before continuing.\n\n' +
                'Do you want to continue?'
            );

            if (!warning) {
                console.log('[TwineImporter] Import cancelled by user');
                return;
            }
        }

        // Create file input
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.html,.htm';
        input.style.display = 'none';

        input.onchange = (e) => this.handleFileSelect(e);

        // Trigger file dialog
        document.body.appendChild(input);
        input.click();
        document.body.removeChild(input);
    }

    /**
     * Handle file selection
     * @param {Event} event - File input change event
     */
    async handleFileSelect(event) {
        const file = event.target.files[0];
        if (!file) {
            console.log('[TwineImporter] No file selected');
            return;
        }

        console.log('[TwineImporter] File selected:', file.name, file.size, 'bytes');

        // Check file size (warn if > 5MB)
        if (file.size > 5 * 1024 * 1024) {
            const proceed = confirm(
                'Warning: This file is quite large (' + (file.size / 1024 / 1024).toFixed(2) + ' MB).\n\n' +
                'Import may take a while. Continue?'
            );

            if (!proceed) {
                return;
            }
        }

        try {
            // Show loading indicator
            if (this.editor.updateStatus) {
                this.editor.updateStatus('📥 Importing from Twine...');
            }

            // Read file content
            const htmlContent = await file.text();
            console.log('[TwineImporter] File read:', htmlContent.length, 'characters');

            // Parse Twine HTML
            const whiskerProject = TwineParser.parse(htmlContent);

            // Show import confirmation dialog
            this.showConfirmationDialog(whiskerProject, file.name);

        } catch (error) {
            console.error('[TwineImporter] Import failed:', error);
            this.showError('Import Failed', error.message);

            if (this.editor.updateStatus) {
                this.editor.updateStatus('❌ Import failed');
            }
        }
    }

    /**
     * Show import confirmation dialog
     * @param {Object} whiskerProject - Parsed Whisker project
     * @param {string} filename - Original filename
     */
    showConfirmationDialog(whiskerProject, filename) {
        const metadata = whiskerProject.metadata;
        const passages = whiskerProject.passages;
        const variables = Object.keys(whiskerProject.variables).length;

        // Build confirmation message
        let message = `Import "${metadata.title}" from Twine?\n\n`;
        message += `File: ${filename}\n`;
        message += `Format: ${metadata.twineData.format} ${metadata.twineData.formatVersion || ''}\n`;
        message += `Author: ${metadata.author}\n`;
        message += `Passages: ${passages.length}\n`;
        message += `Variables: ${variables}\n`;
        message += `\n`;

        // Check for format-specific warnings
        if (metadata.twineData.format === 'sugarcube') {
            message += '⚠️  SugarCube format: Some macros may need manual adjustment\n';
        } else if (metadata.twineData.format === 'unknown') {
            message += '⚠️  Unknown format: Content may need manual adjustment\n';
        }

        message += `\nThis will replace your current project.`;

        const confirmed = confirm(message);

        if (confirmed) {
            this.importProject(whiskerProject);
        } else {
            console.log('[TwineImporter] Import cancelled by user');
            if (this.editor.updateStatus) {
                this.editor.updateStatus('Import cancelled');
            }
        }
    }

    /**
     * Import the project into the editor
     * @param {Object} whiskerProject - Whisker project structure
     */
    importProject(whiskerProject) {
        console.log('[TwineImporter] Importing project...');

        try {
            // Replace current project
            this.editor.project = whiskerProject;

            // Update UI
            if (this.editor.renderAll) {
                this.editor.renderAll();
            }

            // Update passage list
            if (this.editor.renderPassageList) {
                this.editor.renderPassageList();
            }

            // Update graph if in graph view
            if (this.editor.currentView === 'graph' && window.graph) {
                graph.render();
            }

            // Clear any selected passage
            this.editor.currentPassage = null;

            // Show welcome screen or first passage
            const welcomeScreen = document.getElementById('welcomeScreen');
            const graphView = document.getElementById('graphView');
            const editorContent = document.getElementById('editorContent');

            if (welcomeScreen) welcomeScreen.classList.add('hidden');
            if (editorContent) editorContent.classList.add('hidden');
            if (graphView) graphView.classList.remove('hidden');

            // Switch to graph view to show imported passages
            if (this.editor.switchView) {
                this.editor.switchView('graph');
            }

            // Update status
            const title = whiskerProject.metadata.title;
            const count = whiskerProject.passages.length;

            if (this.editor.updateStatus) {
                this.editor.updateStatus(`✓ Imported: ${title} (${count} passages)`);
            }

            // Save to history
            if (window.historySystem) {
                historySystem.recordState();
            }

            console.log('[TwineImporter] Import successful!');

            // Show success notification
            this.showSuccessNotification(whiskerProject);

        } catch (error) {
            console.error('[TwineImporter] Failed to import project:', error);
            this.showError('Import Failed', 'Failed to load project into editor: ' + error.message);
        }
    }

    /**
     * Show success notification
     * @param {Object} whiskerProject - Imported project
     */
    showSuccessNotification(whiskerProject) {
        const message = `Successfully imported "${whiskerProject.metadata.title}" from Twine!\n\n` +
                       `${whiskerProject.passages.length} passages imported.\n` +
                       `${Object.keys(whiskerProject.variables).length} variables detected.`;

        // Try to show a nicer notification if available
        if (typeof this.editor.showNotification === 'function') {
            this.editor.showNotification(message, 'success');
        } else {
            // Fallback to alert
            setTimeout(() => {
                alert(message);
            }, 100);
        }
    }

    /**
     * Show error dialog
     * @param {string} title - Error title
     * @param {string} message - Error message
     */
    showError(title, message) {
        // Create a simple error modal
        const errorHtml = `
            <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                        background: rgba(0,0,0,0.8); display: flex; align-items: center;
                        justify-content: center; z-index: 10000;" id="twineImportError">
                <div style="background: #2d2d2d; border: 2px solid #c5262c; border-radius: 8px;
                            padding: 24px; max-width: 500px; color: #e0e0e0;">
                    <h2 style="color: #c5262c; margin: 0 0 12px 0; font-size: 18px;">❌ ${this.escapeHTML(title)}</h2>
                    <p style="margin: 0 0 20px 0; line-height: 1.5; white-space: pre-wrap;">${this.escapeHTML(message)}</p>
                    <button onclick="document.getElementById('twineImportError').remove()"
                            style="background: #0e639c; color: white; border: none; padding: 8px 16px;
                                   border-radius: 4px; cursor: pointer; font-size: 14px;">Close</button>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', errorHtml);
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
}

// Make available globally
if (typeof window !== 'undefined') {
    window.TwineImporter = TwineImporter;
}

// Global instance (will be initialized by editor)
let twineImporter = null;
