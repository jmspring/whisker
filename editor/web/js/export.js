/**
 * Whisker Story Editor - Export System (OVERHAULED)
 * Completely redesigned for reliability and robustness
 */

class ExportSystem {
    constructor(editor) {
        this.editor = editor;
        this.selectedFormat = 'json';
        this.options = {
            includeMetadata: true,
            minify: false,
            includeVariables: true,
            standalone: true
        };
        this.isInitialized = false;
    }

    /**
     * Initialize the export system
     * Must be called after DOM is ready
     */
    initialize() {
        console.log('[Export] Initializing export system...');
        
        // Verify modal exists
        const modal = document.getElementById('exportModal');
        if (!modal) {
            console.error('[Export] FATAL: Export modal not found in DOM!');
            return false;
        }

        // Ensure modal starts hidden
        modal.style.display = 'none';
        modal.classList.add('hidden');
        
        // Verify required elements exist
        const requiredElements = ['exportFormats', 'exportOptions'];
        for (const id of requiredElements) {
            if (!document.getElementById(id)) {
                console.error(`[Export] FATAL: Required element '${id}' not found!`);
                return false;
            }
        }

        this.isInitialized = true;
        console.log('[Export] Export system initialized successfully');
        return true;
    }

    /**
     * Show export dialog with extensive error handling
     */
    showDialog() {
        console.log('[Export] ========== SHOW DIALOG CALLED ==========');
        
        try {
            // Check initialization
            if (!this.isInitialized) {
                console.warn('[Export] System not initialized, attempting initialization...');
                if (!this.initialize()) {
                    throw new Error('Export system initialization failed');
                }
            }

            // Validate we have a project
            if (!this.editor || !this.editor.project) {
                console.error('[Export] No project available');
                this.showError('No project loaded', 'Please create or open a project before exporting.');
                return;
            }

            // Validate project has passages
            if (!this.editor.project.passages || this.editor.project.passages.length === 0) {
                console.error('[Export] Project has no passages');
                this.showError('Empty project', 'Your project needs at least one passage to export.');
                return;
            }

            console.log('[Export] Project validated:', {
                title: this.editor.project.metadata?.title,
                passageCount: this.editor.project.passages?.length
            });

            // Get modal element
            const modal = document.getElementById('exportModal');
            if (!modal) {
                throw new Error('Export modal element not found');
            }

            // Pre-render the content before showing
            console.log('[Export] Rendering export options...');
            this.render();

            // Show modal using multiple methods to ensure visibility
            console.log('[Export] Making modal visible...');
            modal.classList.remove('hidden');
            modal.style.display = 'flex';
            modal.style.visibility = 'visible';
            modal.style.opacity = '1';
            
            // Force reflow
            modal.offsetHeight;

            console.log('[Export] Modal state:', {
                classList: modal.classList.value,
                display: modal.style.display,
                visibility: modal.style.visibility,
                opacity: modal.style.opacity,
                computed: window.getComputedStyle(modal).display
            });

            console.log('[Export] ========== DIALOG SHOWN ==========');

        } catch (error) {
            console.error('[Export] CRITICAL ERROR in showDialog:', error);
            console.error('[Export] Stack trace:', error.stack);
            this.showError('Export Error', `Failed to open export dialog: ${error.message}`);
        }
    }

    /**
     * Hide export dialog
     */
    hideDialog() {
        console.log('[Export] Hiding dialog...');
        const modal = document.getElementById('exportModal');
        if (modal) {
            modal.classList.add('hidden');
            modal.style.display = 'none';
            modal.style.visibility = 'hidden';
            modal.style.opacity = '0';
        }
    }

    /**
     * Show error message to user
     */
    showError(title, message) {
        // Create a simple modal alert
        const errorHtml = `
            <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
                        background: rgba(0,0,0,0.8); display: flex; align-items: center; 
                        justify-content: center; z-index: 10000;" id="exportErrorModal">
                <div style="background: #2d2d2d; border: 2px solid #c5262c; border-radius: 8px; 
                            padding: 24px; max-width: 400px; color: #e0e0e0;">
                    <h2 style="color: #c5262c; margin: 0 0 12px 0; font-size: 18px;">${title}</h2>
                    <p style="margin: 0 0 20px 0; line-height: 1.5;">${message}</p>
                    <button onclick="document.getElementById('exportErrorModal').remove()" 
                            style="background: #0e639c; color: white; border: none; padding: 8px 16px; 
                                   border-radius: 4px; cursor: pointer; font-size: 14px;">OK</button>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', errorHtml);
    }

    /**
     * Render export format options
     */
    render() {
        console.log('[Export] Rendering export UI...');
        
        const formatsContainer = document.getElementById('exportFormats');
        if (!formatsContainer) {
            console.error('[Export] exportFormats container not found!');
            return;
        }

        const formats = this.getFormats();
        console.log('[Export] Rendering', formats.length, 'formats');
        
        formatsContainer.innerHTML = formats.map(format => `
            <div class="export-format ${format.id === this.selectedFormat ? 'selected' : ''}" 
                 onclick="exportSystem.selectFormat('${format.id}')"
                 style="cursor: pointer;">
                <div class="export-format-title">
                    <span style="font-size: 20px; margin-right: 8px;">${format.icon}</span>
                    <span>${format.title}</span>
                </div>
                <div class="export-format-desc">${format.description}</div>
            </div>
        `).join('');

        this.renderOptions();
        console.log('[Export] UI rendered successfully');
    }

    /**
     * Render format-specific options
     */
    renderOptions() {
        const container = document.getElementById('exportOptions');
        if (!container) {
            console.error('[Export] exportOptions container not found!');
            return;
        }

        const format = this.getFormats().find(f => f.id === this.selectedFormat);
        if (!format || !format.options || Object.keys(format.options).length === 0) {
            container.innerHTML = '<p style="color: #888; font-size: 14px;">No additional options for this format.</p>';
            return;
        }

        container.innerHTML = `
            <h3 style="margin: 0 0 12px 0; font-size: 14px; font-weight: 600;">Export Options</h3>
            ${Object.entries(format.options).map(([key, option]) => `
                <div class="export-option-item" style="display: flex; align-items: center; gap: 12px; margin-bottom: 12px;">
                    <input type="checkbox" 
                           id="option_${key}" 
                           ${this.options[key] ? 'checked' : ''}
                           onchange="exportSystem.toggleOption('${key}', this.checked)"
                           style="cursor: pointer;">
                    <label for="option_${key}" style="cursor: pointer; flex: 1;">${option}</label>
                </div>
            `).join('')}
        `;
    }

    /**
     * Get available export formats
     */
    getFormats() {
        return [
            {
                id: 'json',
                title: 'Whisker JSON',
                icon: '📄',
                description: 'Standard Whisker story format for web players',
                extension: '.json',
                options: {
                    includeMetadata: 'Include metadata',
                    minify: 'Minify JSON',
                    includeVariables: 'Include variables'
                },
                export: () => this.exportJSON()
            },
            {
                id: 'html',
                title: 'Standalone HTML',
                icon: '🌐',
                description: 'Self-contained HTML file with embedded player',
                extension: '.html',
                options: {
                    standalone: 'Include runtime player',
                    includeVariables: 'Include variables'
                },
                export: () => this.exportHTML()
            },
            {
                id: 'whisker',
                title: 'Whisker Project',
                icon: '💾',
                description: 'Complete project file (can be reopened in editor)',
                extension: '.whisker',
                options: {
                    includeMetadata: 'Include metadata'
                },
                export: () => this.exportWhisker()
            },
            {
                id: 'markdown',
                title: 'Markdown',
                icon: '📝',
                description: 'Text-based format for documentation',
                extension: '.md',
                options: {},
                export: () => this.exportMarkdown()
            },
            {
                id: 'twine',
                title: 'Twine HTML',
                icon: '🔄',
                description: 'Import into Twine 2 (Harlowe format)',
                extension: '.html',
                options: {},
                export: () => this.exportTwine()
            }
        ];
    }

    /**
     * Select export format
     */
    selectFormat(formatId) {
        console.log('[Export] Format selected:', formatId);
        this.selectedFormat = formatId;
        this.render();
    }

    /**
     * Toggle export option
     */
    toggleOption(key, value) {
        console.log('[Export] Option toggled:', key, '=', value);
        this.options[key] = value;
    }

    /**
     * Execute export
     */
    async doExport() {
        console.log('[Export] ========== STARTING EXPORT ==========');
        console.log('[Export] Format:', this.selectedFormat);
        console.log('[Export] Options:', this.options);

        try {
            if (!this.editor || !this.editor.project) {
                throw new Error('No project to export');
            }

            const format = this.getFormats().find(f => f.id === this.selectedFormat);
            if (!format) {
                throw new Error('Invalid export format selected');
            }

            console.log('[Export] Executing export for format:', format.title);
            const result = await format.export();
            
            if (result) {
                console.log('[Export] Export successful!');
                this.hideDialog();
                if (this.editor.updateStatus) {
                    this.editor.updateStatus(`✓ Exported as ${format.title}`);
                }
            } else {
                throw new Error('Export function returned false');
            }

        } catch (error) {
            console.error('[Export] Export failed:', error);
            this.showError('Export Failed', error.message);
        }
    }

    /**
     * Export as Whisker JSON
     */
    exportJSON() {
        console.log('[Export] Generating JSON...');
        const data = {
            metadata: this.options.includeMetadata ? this.editor.project.metadata : undefined,
            settings: this.editor.project.settings,
            variables: this.options.includeVariables ? this.editor.project.variables : {},
            passages: this.editor.project.passages.map(p => ({
                id: p.id,
                title: p.title,
                content: p.content,
                choices: p.choices
            }))
        };

        const json = this.options.minify ? 
            JSON.stringify(data) : 
            JSON.stringify(data, null, 2);

        this.downloadFile(
            json,
            this.getFilename('.json'),
            'application/json'
        );

        return true;
    }

    /**
     * Detect if any passage contains Lua code
     */
    detectLuaUsage() {
        if (!this.editor || !this.editor.project || !this.editor.project.passages) {
            return false;
        }

        for (const passage of this.editor.project.passages) {
            if (passage.content && passage.content.includes('{{lua:')) {
                console.log('[Export] Lua usage detected in passage:', passage.id);
                return true;
            }
        }

        console.log('[Export] No Lua usage detected');
        return false;
    }

    /**
     * Export as standalone HTML
     */
    exportHTML() {
        console.log('[Export] Generating HTML...');
        const needsLua = this.detectLuaUsage();
        console.log('[Export] Needs Lua runtime:', needsLua);

        const storyData = {
            metadata: this.editor.project.metadata,
            settings: this.editor.project.settings,
            variables: this.options.includeVariables ? this.editor.project.variables : {},
            passages: this.editor.project.passages.map(p => ({
                id: p.id,
                title: p.title,
                content: p.content,
                choices: p.choices
            }))
        };

        const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${this.escapeHTML(this.editor.project.metadata.title)}</title>
    ${needsLua ? '<!-- Fengari: Lua VM for JavaScript -->\n    <script src="https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js"></script>' : ''}
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #1e1e1e;
            color: #e0e0e0;
            padding: 20px;
            line-height: 1.6;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: #2d2d2d;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
        }
        h1 { margin-bottom: 12px; color: #61dafb; }
        .subtitle { color: #888; margin-bottom: 30px; }
        .passage { margin-bottom: 30px; }
        .content {
            margin-bottom: 20px;
            font-size: 16px;
        }
        .choices {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .choice {
            background: #0e639c;
            padding: 12px 20px;
            border-radius: 6px;
            cursor: pointer;
            transition: background 0.2s;
            border: none;
            color: white;
            font-size: 15px;
            text-align: left;
        }
        .choice:hover {
            background: #1177bb;
        }
        .stats {
            margin-top: 30px;
            padding: 20px;
            background: #1e1e1e;
            border-radius: 8px;
            font-size: 14px;
        }
        .stat-item {
            display: flex;
            justify-content: space-between;
            padding: 4px 0;
        }
    </style>
</head>
<body>
    <div class="container" id="game">
        <h1 id="title">${this.escapeHTML(this.editor.project.metadata.title)}</h1>
        <div class="subtitle">by ${this.escapeHTML(this.editor.project.metadata.author)}</div>
        <div id="passage-container"></div>
        ${this.options.includeVariables && Object.keys(this.editor.project.variables).length > 0 ? `
        <div class="stats" id="stats"></div>
        ` : ''}
    </div>

    <script>
        ${needsLua ? '// NOTE: This story contains Lua code ({{lua:}} blocks)\n        // Fengari is loaded for Lua support\n        // Future versions will include full LuaWhiskerPlayer for complete functionality\n        if (typeof fengari !== "undefined") {\n            console.log("✅ Fengari Lua runtime loaded");\n        } else {\n            console.warn("⚠️ Fengari failed to load - Lua blocks will not execute");\n        }' : ''}

        const story = ${JSON.stringify(storyData)};
        let currentPassageId = story.settings.startPassage;
        let variables = {};

        // Initialize variables
        Object.entries(story.variables || {}).forEach(([name, data]) => {
            variables[name] = data.initial;
        });

        function renderPassage(passageId) {
            const passage = story.passages.find(p => p.id === passageId);
            if (!passage) {
                console.error('Passage not found:', passageId);
                return;
            }

            const container = document.getElementById('passage-container');
            
            // Process content with variables
            let content = passage.content;
            Object.entries(variables).forEach(([name, value]) => {
                content = content.replace(new RegExp('\\\\{\\\\{' + name + '\\\\}\\\\}', 'g'), value);
            });

            const choicesHTML = passage.choices.map((choice, index) => 
                \`<button class="choice" onclick="makeChoice('\${choice.target}')">\${choice.text}</button>\`
            ).join('');

            container.innerHTML = \`
                <div class="passage">
                    <div class="content">\${content.replace(/\\n/g, '<br>')}</div>
                    <div class="choices">\${choicesHTML}</div>
                </div>
            \`;

            updateStats();
        }

        function makeChoice(targetId) {
            currentPassageId = targetId;
            renderPassage(targetId);
        }

        function updateStats() {
            const statsEl = document.getElementById('stats');
            if (!statsEl) return;

            const statsHTML = Object.entries(variables).map(([name, value]) =>
                \`<div class="stat-item"><span>\${name}:</span><span>\${value}</span></div>\`
            ).join('');

            statsEl.innerHTML = '<strong>Variables:</strong><br>' + statsHTML;
        }

        // Start the story
        renderPassage(currentPassageId);
    </script>
</body>
</html>`;

        this.downloadFile(
            html,
            this.getFilename('.html'),
            'text/html'
        );

        return true;
    }

    /**
     * Export as Whisker project file
     */
    exportWhisker() {
        console.log('[Export] Generating Whisker project file...');
        const json = JSON.stringify(this.editor.project, null, 2);
        
        this.downloadFile(
            json,
            this.getFilename('.whisker'),
            'application/json'
        );

        return true;
    }

    /**
     * Export as Markdown
     */
    exportMarkdown() {
        console.log('[Export] Generating Markdown...');
        let md = `# ${this.editor.project.metadata.title}\n\n`;
        md += `**Author:** ${this.editor.project.metadata.author}\n\n`;
        md += `---\n\n`;

        this.editor.project.passages.forEach(passage => {
            md += `## ${passage.title}\n\n`;
            md += `**ID:** \`${passage.id}\`\n\n`;
            md += `${passage.content}\n\n`;

            if (passage.choices.length > 0) {
                md += `**Choices:**\n\n`;
                passage.choices.forEach((choice, i) => {
                    md += `${i + 1}. ${choice.text} → \`${choice.target}\`\n`;
                });
                md += `\n`;
            }

            md += `---\n\n`;
        });

        this.downloadFile(
            md,
            this.getFilename('.md'),
            'text/markdown'
        );

        return true;
    }

    /**
     * Export as Twine HTML
     */
    exportTwine() {
        console.log('[Export] Generating Twine HTML...');
        let html = `<tw-storydata name="${this.escapeXML(this.editor.project.metadata.title)}" `;
        html += `creator="Whisker" creator-version="1.0.0" `;
        html += `ifid="${this.generateIFID()}" `;
        html += `format="Harlowe" format-version="3.2.3" `;
        html += `start="${this.editor.project.settings.startPassage}" hidden>\n`;

        this.editor.project.passages.forEach(passage => {
            const pos = passage.position || { x: 100, y: 100 };
            html += `<tw-passagedata pid="${this.generatePID()}" `;
            html += `name="${this.escapeXML(passage.title)}" `;
            html += `tags="" position="${pos.x},${pos.y}">\n`;
            
            let content = passage.content;
            passage.choices.forEach(choice => {
                content += `\n[[${choice.text}|${choice.target}]]`;
            });
            
            html += this.escapeXML(content);
            html += `\n</tw-passagedata>\n`;
        });

        html += `</tw-storydata>`;

        this.downloadFile(
            html,
            this.getFilename('_twine.html'),
            'text/html'
        );

        return true;
    }

    /**
     * Get filename for export
     */
    getFilename(extension) {
        const title = this.editor.project.metadata.title
            .replace(/[^a-z0-9]/gi, '_')
            .toLowerCase();
        return `${title}${extension}`;
    }

    /**
     * Download file
     */
    downloadFile(content, filename, mimeType) {
        console.log('[Export] Downloading file:', filename);
        try {
            const blob = new Blob([content], { type: mimeType });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            console.log('[Export] File download initiated successfully');
        } catch (error) {
            console.error('[Export] Download failed:', error);
            throw error;
        }
    }

    /**
     * Generate IFID for Twine
     */
    generateIFID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16).toUpperCase();
        });
    }

    /**
     * Generate PID for Twine passage
     */
    generatePID() {
        return Math.floor(Math.random() * 1000000);
    }

    /**
     * Escape XML special characters
     */
    escapeXML(text) {
        if (!text) return '';
        return String(text)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&apos;');
    }

    /**
     * Escape HTML special characters
     */
    escapeHTML(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Global instance
let exportSystem = null;
