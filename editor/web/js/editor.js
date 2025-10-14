/**
 * Whisker Story Editor - Main JavaScript
 * Phase 1 MVP - Core Editor Functionality
 */

class WhiskerEditor {
    constructor() {
        this.project = null;
        this.currentPassageId = null;
        this.previewPassageId = null;
        this.currentView = 'list'; // 'list' or 'graph'
    }

    /**
     * Create a new project
     */
    newProject() {
        const title = prompt("Project Title:", "My Story");
        if (!title) return;

        this.project = {
            metadata: {
                title: title,
                author: "Author Name",
                version: "1.0.0",
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            },
            settings: {
                startPassage: "start"
            },
            variables: {},
            passages: [
                {
                    id: "start",
                    title: "Start",
                    content: "This is the beginning of your story.",
                    choices: [],
                    position: { x: 100, y: 100 }
                }
            ]
        };

        this.currentPassageId = "start";
        this.previewPassageId = "start";
        
        if (historySystem) {
            historySystem.clear();
            historySystem.save('Project created');
        }
        
        this.initializeGraph();
        this.render();
        this.updateStatus("New project created");
    }

    /**
     * Add a new passage to the project
     */
    addPassage() {
        if (!this.project) {
            alert("Please create or open a project first");
            return;
        }

        const title = prompt("Passage Title:", "New Passage");
        if (!title) return;

        const id = this.generateId(title);
        
        // Find a position for the new passage
        const existingPositions = this.project.passages
            .filter(p => p.position)
            .map(p => p.position);
        
        let position = { x: 100, y: 100 };
        if (existingPositions.length > 0) {
            // Place new passage below the last one
            const maxY = Math.max(...existingPositions.map(p => p.y));
            position = { x: 100, y: maxY + 150 };
        }
        
        const passage = {
            id: id,
            title: title,
            content: "",
            choices: [],
            position: position
        };

        this.project.passages.push(passage);
        this.currentPassageId = id;
        this.project.metadata.modified = new Date().toISOString();
        this.saveToHistory('Added passage: ' + title);
        this.render();
        this.updateStatus(`Added passage: ${title}`);
    }

    /**
     * Delete the current passage
     */
    deleteCurrentPassage() {
        if (!this.currentPassageId) return;
        
        if (this.currentPassageId === this.project.settings.startPassage) {
            alert("Cannot delete the start passage");
            return;
        }

        if (!confirm("Delete this passage?")) return;

        const passageTitle = this.getCurrentPassage()?.title || 'passage';

        this.project.passages = this.project.passages.filter(
            p => p.id !== this.currentPassageId
        );

        // Remove references to this passage in choices
        this.project.passages.forEach(p => {
            p.choices = p.choices.filter(c => c.target !== this.currentPassageId);
        });

        this.currentPassageId = this.project.passages[0]?.id || null;
        this.saveToHistory('Deleted passage: ' + passageTitle);
        this.render();
        this.updateStatus("Passage deleted");
    }

    /**
     * Add a new choice to the current passage
     */
    addChoice() {
        const passage = this.getCurrentPassage();
        if (!passage) return;

        passage.choices.push({
            text: "Choice text",
            target: "start"
        });

        this.renderChoices();
        this.updatePreview();
    }

    /**
     * Delete a choice from the current passage
     * @param {number} index - Index of the choice to delete
     */
    deleteChoice(index) {
        const passage = this.getCurrentPassage();
        if (!passage) return;

        passage.choices.splice(index, 1);
        this.renderChoices();
        this.updatePreview();
    }

    /**
     * Update the current passage with form values
     */
    updateCurrentPassage() {
        const passage = this.getCurrentPassage();
        if (!passage) return;

        passage.title = document.getElementById('passageTitle').value;
        passage.content = document.getElementById('passageContent').value;

        this.project.metadata.modified = new Date().toISOString();
        this.renderPassageList();
        this.updatePreview();
    }

    /**
     * Update a specific choice
     * @param {number} index - Choice index
     * @param {string} field - Field to update ('text' or 'target')
     * @param {string} value - New value
     */
    updateChoice(index, field, value) {
        const passage = this.getCurrentPassage();
        if (!passage || !passage.choices[index]) return;

        passage.choices[index][field] = value;
        this.project.metadata.modified = new Date().toISOString();
        this.updatePreview();
    }

    /**
     * Get the currently selected passage
     * @returns {Object|null} The current passage object
     */
    getCurrentPassage() {
        if (!this.project || !this.currentPassageId) return null;
        return this.project.passages.find(p => p.id === this.currentPassageId);
    }

    /**
     * Get a passage by ID
     * @param {string} id - Passage ID
     * @returns {Object|null} The passage object
     */
    getPassage(id) {
        if (!this.project) return null;
        return this.project.passages.find(p => p.id === id);
    }

    /**
     * Select a different passage for editing
     * @param {string} id - Passage ID to select
     */
    selectPassage(id) {
        this.currentPassageId = id;
        this.render();
    }

    /**
     * Initialize graph view
     */
    initializeGraph() {
        if (!graph) {
            graph = new GraphView(this);
            graph.initialize();
        }
    }

    /**
     * Switch between views
     * @param {string} view - 'list' or 'graph'
     */
    switchView(view) {
        if (!this.project) return;
        
        this.currentView = view;
        
        const graphView = document.getElementById('graphView');
        const editorContent = document.getElementById('editorContent');
        
        if (view === 'graph') {
            graphView.classList.remove('hidden');
            editorContent.classList.add('hidden');
            
            this.initializeGraph();
            graph.render();
        } else {
            graphView.classList.add('hidden');
            editorContent.classList.remove('hidden');
            
            this.renderEditor();
            this.renderChoices();
        }
    }

    /**
     * Render the entire editor UI
     */
    render() {
        if (!this.project) {
            document.getElementById('welcomeScreen').classList.remove('hidden');
            document.getElementById('editorContent').classList.add('hidden');
            document.getElementById('graphView').classList.add('hidden');
            return;
        }

        document.getElementById('welcomeScreen').classList.add('hidden');

        this.renderPassageList();
        this.updatePreview();
        
        // Render variables
        if (variablesManager) {
            variablesManager.render();
        }
        
        // Run validation
        if (validationSystem) {
            validationSystem.validate();
        }
        
        // Render the current view
        if (this.currentView === 'graph') {
            document.getElementById('graphView').classList.remove('hidden');
            document.getElementById('editorContent').classList.add('hidden');
            
            this.initializeGraph();
            graph.render();
        } else {
            document.getElementById('graphView').classList.add('hidden');
            document.getElementById('editorContent').classList.remove('hidden');
            
            this.renderEditor();
            this.renderChoices();
        }
    }

    /**
     * Render the passage list sidebar
     */
    renderPassageList() {
        const listEl = document.getElementById('passageList');
        listEl.innerHTML = '';

        this.project.passages.forEach(passage => {
            const item = document.createElement('div');
            item.className = 'passage-item' + 
                (passage.id === this.currentPassageId ? ' active' : '');
            item.onclick = () => this.selectPassage(passage.id);

            const content = passage.content || '';
            const preview = content.substring(0, 50) +
                (content.length > 50 ? '...' : '');

            item.innerHTML = `
                <div class="passage-name">${passage.title}</div>
                <div class="passage-preview">${preview || '(empty)'}</div>
            `;

            listEl.appendChild(item);
        });

        document.getElementById('passageCount').textContent = 
            `${this.project.passages.length} passages`;
    }

    /**
     * Render the main editor form
     */
    renderEditor() {
        const passage = this.getCurrentPassage();
        if (!passage) return;

        document.getElementById('passageTitle').value = passage.title;
        document.getElementById('passageId').value = passage.id;
        document.getElementById('passageContent').value = passage.content;
    }

    /**
     * Render the choices list
     */
    renderChoices() {
        const passage = this.getCurrentPassage();
        if (!passage) return;

        const listEl = document.getElementById('choicesList');
        listEl.innerHTML = '';

        passage.choices.forEach((choice, index) => {
            const item = document.createElement('div');
            item.className = 'choice-item';

            const targetOptions = this.project.passages
                .map(p => `<option value="${p.id}" ${p.id === choice.target ? 'selected' : ''}>${p.title}</option>`)
                .join('');

            item.innerHTML = `
                <div class="choice-header">
                    <span>Choice ${index + 1}</span>
                    <button class="btn-small btn-danger" onclick="editor.deleteChoice(${index})">Delete</button>
                </div>
                <div class="choice-inputs">
                    <div>
                        <label>Choice Text</label>
                        <input type="text" value="${choice.text}" 
                               onchange="editor.updateChoice(${index}, 'text', this.value)">
                    </div>
                    <div>
                        <label>Target Passage</label>
                        <select onchange="editor.updateChoice(${index}, 'target', this.value)">
                            ${targetOptions}
                        </select>
                    </div>
                </div>
            `;

            listEl.appendChild(item);
        });
    }

    /**
     * Update the preview panel with current passage
     */
    updatePreview() {
        if (!this.project || !this.previewPassageId) return;

        const passage = this.getPassage(this.previewPassageId);
        if (!passage) return;

        // Process the content
        let displayContent = passage.content;

        // Remove link syntax [[text->target]] and [[target]]
        displayContent = displayContent.replace(/\[\[([^\]]+)\]\]/g, '');

        // Get variables with their initial values
        const variables = {};
        if (this.project.variables) {
            for (const [key, value] of Object.entries(this.project.variables)) {
                // Handle both simple values and variable definitions with initial values
                if (typeof value === 'object' && value.initial !== undefined) {
                    variables[key] = value.initial;
                } else {
                    variables[key] = value;
                }
            }
        }

        // Use template processor to handle conditionals and variables
        if (typeof TemplateProcessor !== 'undefined') {
            displayContent = TemplateProcessor.process(displayContent, variables);
        } else {
            // Fallback to old behavior if template processor not loaded
            console.warn('TemplateProcessor not loaded');
            displayContent = displayContent.replace(/\{\{#if[^}]*\}\}/g, '');
            displayContent = displayContent.replace(/\{\{\/if\}\}/g, '');
            displayContent = displayContent.replace(/\{\{lua:[^}]*\}\}/g, '');
        }

        // Clean up extra whitespace and line breaks
        displayContent = displayContent.replace(/\n\n+/g, '\n\n').trim();

        // Apply basic Markdown formatting
        displayContent = this.renderMarkdown(displayContent);

        const content = document.getElementById('previewContent');
        content.innerHTML = `
            <div class="preview-passage">
                <h3>${passage.title}</h3>
                <div class="preview-text">${displayContent}</div>
                <div class="preview-choices">
                    ${passage.choices.map((choice, i) => `
                        <div class="preview-choice" onclick="editor.previewChoice(${i})">
                            ${choice.text}
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    /**
     * Render basic Markdown to HTML
     * @param {string} text - Markdown text
     * @returns {string} HTML
     */
    renderMarkdown(text) {
        // Escape HTML first to prevent XSS
        text = text.replace(/&/g, '&amp;')
                   .replace(/</g, '&lt;')
                   .replace(/>/g, '&gt;');

        // Headers
        text = text.replace(/^### (.+)$/gm, '<h3>$1</h3>');
        text = text.replace(/^## (.+)$/gm, '<h2>$1</h2>');
        text = text.replace(/^# (.+)$/gm, '<h1>$1</h1>');

        // Bold
        text = text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

        // Italic (handle both * and _)
        text = text.replace(/\*(.+?)\*/g, '<em>$1</em>');
        text = text.replace(/_(.+?)_/g, '<em>$1</em>');

        // Code
        text = text.replace(/`(.+?)`/g, '<code>$1</code>');

        // Lists
        text = text.replace(/^- (.+)$/gm, '<li>$1</li>');
        text = text.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');

        // Line breaks
        text = text.replace(/\n/g, '<br>');

        return text;
    }

    /**
     * Navigate preview to a choice target
     * @param {number} index - Choice index to follow
     */
    previewChoice(index) {
        const passage = this.getPassage(this.previewPassageId);
        if (!passage || !passage.choices[index]) return;

        this.previewPassageId = passage.choices[index].target;
        this.updatePreview();
    }

    /**
     * Restart preview from the start passage
     */
    restartPreview() {
        if (!this.project) return;

        // Use PreviewRuntime if available
        if (typeof previewRuntime !== 'undefined' && previewRuntime) {
            previewRuntime.start();
        } else {
            // Fallback to simple preview
            this.previewPassageId = this.project.settings.startPassage;
            this.updatePreview();
        }
    }

    /**
     * Save the project as a .whisker file
     */
    saveProject() {
        if (!this.project) return;

        const json = JSON.stringify(this.project, null, 2);
        const blob = new Blob([json], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${this.project.metadata.title.replace(/\s+/g, '_')}.whisker`;
        a.click();
        URL.revokeObjectURL(url);

        this.updateStatus("Project saved");
    }

    /**
     * Open an existing project file
     */
    openProject() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.whisker,.json';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = (e) => {
                try {
                    this.project = JSON.parse(e.target.result);

                    // Normalize passages - ensure all passages have required fields
                    if (this.project.passages) {
                        this.project.passages.forEach(passage => {
                            // Handle both Whisker format (name, text) and editor format (id, content)
                            passage.id = passage.id || passage.name || 'untitled';
                            passage.title = passage.title || passage.name || 'Untitled';
                            passage.content = passage.content || passage.text || '';
                            passage.position = passage.position || { x: 100, y: 100 };

                            // Extract choices from text if not already present
                            if (!passage.choices || passage.choices.length === 0) {
                                passage.choices = this.extractChoicesFromText(passage.content);
                            }
                        });
                    }

                    this.currentPassageId = this.project.passages[0]?.id || null;
                    this.previewPassageId = this.project.settings.startPassage;

                    if (historySystem) {
                        historySystem.clear();
                        historySystem.save('Project opened');
                    }

                    this.initializeGraph();
                    this.render();
                    this.updateStatus("Project opened");
                } catch (err) {
                    alert("Error loading project: " + err.message);
                }
            };
            reader.readAsText(file);
        };
        input.click();
    }

    /**
     * Export the project as JSON
     */
    exportJSON() {
        if (!this.project) return;

        const json = JSON.stringify(this.project, null, 2);
        const blob = new Blob([json], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${this.project.metadata.title.replace(/\s+/g, '_')}.json`;
        a.click();
        URL.revokeObjectURL(url);

        this.updateStatus("Exported to JSON");
    }

    /**
     * Extract choices from passage text
     * Supports [[text->target]] and [[target]] syntax
     * @param {string} text - The passage text
     * @returns {Array} Array of choice objects
     */
    extractChoicesFromText(text) {
        if (!text) return [];

        const choices = [];
        const seen = new Set();

        // Match [[text->target]] or [[target]]
        const linkPattern = /\[\[([^\]]+)\]\]/g;
        let match;

        while ((match = linkPattern.exec(text)) !== null) {
            const content = match[1];
            let displayText, target;

            if (content.includes('->')) {
                // [[text->target]] format
                const parts = content.split('->');
                displayText = parts[0].trim();
                target = parts[1].trim();
            } else {
                // [[target]] format
                target = content.trim();
                displayText = target;
            }

            // Avoid duplicates
            const key = `${displayText}|${target}`;
            if (!seen.has(key)) {
                choices.push({ text: displayText, target: target });
                seen.add(key);
            }
        }

        return choices;
    }

    /**
     * Generate a unique ID from a title
     * @param {string} title - The passage title
     * @returns {string} A unique ID
     */
    generateId(title) {
        const base = title.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '');
        let id = base;
        let counter = 1;

        while (this.project.passages.some(p => p.id === id)) {
            id = `${base}_${counter}`;
            counter++;
        }

        return id;
    }

    /**
     * Update the status bar message
     * @param {string} message - Status message to display
     */
    updateStatus(message) {
        document.getElementById('statusText').textContent = message;
        setTimeout(() => {
            document.getElementById('statusText').textContent = 'Ready';
        }, 3000);
    }

    /**
     * Save current state to history
     * @param {string} description - Description of the change
     */
    saveToHistory(description = 'Change') {
        if (historySystem) {
            historySystem.save(description);
        }
    }

    /**
     * Format text in the content editor
     * @param {string} format - Format type (bold, italic, etc.)
     */
    formatText(format) {
        const textarea = document.getElementById('passageContent');
        if (!textarea) return;

        const start = textarea.selectionStart;
        const end = textarea.selectionEnd;
        const selectedText = textarea.value.substring(start, end);
        let formattedText = '';

        switch (format) {
            case 'bold':
                formattedText = `**${selectedText || 'bold text'}**`;
                break;
            case 'italic':
                formattedText = `_${selectedText || 'italic text'}_`;
                break;
            case 'code':
                formattedText = `\`${selectedText || 'code'}\``;
                break;
            case 'h1':
                formattedText = `# ${selectedText || 'Heading 1'}`;
                break;
            case 'h2':
                formattedText = `## ${selectedText || 'Heading 2'}`;
                break;
            case 'list':
                formattedText = `- ${selectedText || 'List item'}`;
                break;
            case 'link':
                formattedText = `[${selectedText || 'link text'}](url)`;
                break;
            default:
                return;
        }

        const text = textarea.value;
        textarea.value = text.substring(0, start) + formattedText + text.substring(end);
        textarea.selectionStart = start;
        textarea.selectionEnd = start + formattedText.length;
        textarea.focus();

        this.updateCurrentPassage();
    }
}

// Initialize the editor
const editor = new WhiskerEditor();