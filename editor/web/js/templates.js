/**
 * Whisker Story Editor - Story Templates
 * Phase 3 - Enhanced Features
 */

class TemplateSystem {
    constructor(editor) {
        this.editor = editor;
        this.templates = this.getBuiltInTemplates();
    }

    /**
     * Get built-in templates
     */
    getBuiltInTemplates() {
        return [
            {
                id: 'blank',
                title: 'Blank Story',
                description: 'Start with a single empty passage',
                icon: '📄',
                passages: 1,
                choices: 0,
                generate: () => this.generateBlank()
            },
            {
                id: 'simple_choice',
                title: 'Simple Choice',
                description: 'A basic branching story with two paths',
                icon: '🔀',
                passages: 4,
                choices: 3,
                generate: () => this.generateSimpleChoice()
            },
            {
                id: 'complex_story',
                title: 'Complex Story',
                description: 'A story structure with multiple branches and loops',
                icon: '🌳',
                passages: 8,
                choices: 12,
                generate: () => this.generateComplexStory()
            },
            {
                id: 'game_template',
                title: 'Game Template',
                description: 'RPG-style game with stats and inventory',
                icon: '🎮',
                passages: 6,
                choices: 8,
                generate: () => this.generateGameTemplate()
            },
            {
                id: 'quiz',
                title: 'Quiz/Survey',
                description: 'Question and answer format with scoring',
                icon: '📝',
                passages: 5,
                choices: 8,
                generate: () => this.generateQuiz()
            },
            {
                id: 'tutorial',
                title: 'Interactive Tutorial',
                description: 'Step-by-step tutorial structure',
                icon: '📚',
                passages: 6,
                choices: 5,
                generate: () => this.generateTutorial()
            }
        ];
    }

    /**
     * Show templates dialog
     */
    showDialog() {
        const modal = document.getElementById('templatesModal');
        if (!modal) return;

        this.render();
        modal.classList.remove('hidden');
    }

    /**
     * Hide templates dialog
     */
    hideDialog() {
        const modal = document.getElementById('templatesModal');
        if (modal) {
            modal.classList.add('hidden');
        }
    }

    /**
     * Render templates grid
     */
    render() {
        const container = document.getElementById('templateGrid');
        if (!container) return;

        container.innerHTML = this.templates.map(template => `
            <div class="template-card" onclick="templateSystem.applyTemplate('${template.id}')">
                <div class="template-icon">${template.icon}</div>
                <div class="template-title">${template.title}</div>
                <div class="template-description">${template.description}</div>
                <div class="template-meta">
                    <span>${template.passages} passages</span>
                    <span>${template.choices} choices</span>
                </div>
            </div>
        `).join('');
    }

    /**
     * Apply a template
     */
    applyTemplate(templateId) {
        try {
            const template = this.templates.find(t => t.id === templateId);
            if (!template) {
                console.error('Template not found:', templateId);
                return;
            }

            if (this.editor.project) {
                if (!confirm('This will replace your current story. Continue?')) {
                    return;
                }
            }

            const project = template.generate();
            
            const title = prompt("Story Title:", project.metadata.title);
            if (title) {
                project.metadata.title = title;
            }

            // Set the project on editor
            this.editor.project = project;
            this.editor.currentPassageId = project.settings.startPassage;
            this.editor.previewPassageId = project.settings.startPassage;
            
            console.log('Template applied, project:', this.editor.project);
            
            // History system (with error handling)
            if (window.historySystem) {
                try {
                    historySystem.clear();
                    historySystem.save('Created from template: ' + template.title);
                } catch (err) {
                    console.warn('History system error:', err);
                }
            }
            
            this.editor.initializeGraph();
            this.editor.render();
            
            this.hideDialog();
            this.editor.updateStatus('Template applied: ' + template.title);
            
            // Verify project was set correctly
            console.log('Editor project after template:', this.editor.project ? 'SET' : 'NOT SET');
        } catch (error) {
            console.error('Error applying template:', error);
            alert('Error applying template: ' + error.message);
        }
    }

    /**
     * Generate blank template
     */
    generateBlank() {
        return {
            metadata: {
                title: "My Story",
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
                    content: "Your story begins here...",
                    position: { x: 100, y: 100 },
                    choices: []
                }
            ]
        };
    }

    /**
     * Generate simple choice template
     */
    generateSimpleChoice() {
        return {
            metadata: {
                title: "Simple Choice Story",
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
                    title: "Beginning",
                    content: "You stand at a crossroads. Which path will you take?",
                    position: { x: 100, y: 100 },
                    choices: [
                        { text: "Take the left path", target: "left_path" },
                        { text: "Take the right path", target: "right_path" }
                    ]
                },
                {
                    id: "left_path",
                    title: "Left Path",
                    content: "You walk down the left path and discover something amazing.",
                    position: { x: 100, y: 250 },
                    choices: [
                        { text: "Continue", target: "ending" }
                    ]
                },
                {
                    id: "right_path",
                    title: "Right Path",
                    content: "The right path leads you to an unexpected adventure.",
                    position: { x: 400, y: 250 },
                    choices: [
                        { text: "Continue", target: "ending" }
                    ]
                },
                {
                    id: "ending",
                    title: "Ending",
                    content: "Your journey comes to an end. Thank you for playing!",
                    position: { x: 250, y: 400 },
                    choices: []
                }
            ]
        };
    }

    /**
     * Generate complex story template
     */
    generateComplexStory() {
        return {
            metadata: {
                title: "Complex Story",
                author: "Author Name",
                version: "1.0.0",
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            },
            settings: {
                startPassage: "start"
            },
            variables: {
                chapter: { type: "number", initial: 1 }
            },
            passages: [
                {
                    id: "start",
                    title: "Prologue",
                    content: "Welcome to Chapter {{chapter}}. Your adventure begins...",
                    position: { x: 100, y: 50 },
                    choices: [
                        { text: "Begin", target: "chapter1" }
                    ]
                },
                {
                    id: "chapter1",
                    title: "Chapter 1",
                    content: "You find yourself in a mysterious place.",
                    position: { x: 100, y: 200 },
                    choices: [
                        { text: "Explore the area", target: "explore" },
                        { text: "Look for help", target: "help" }
                    ]
                },
                {
                    id: "explore",
                    title: "Exploration",
                    content: "As you explore, you discover clues about this strange world.",
                    position: { x: 100, y: 350 },
                    choices: [
                        { text: "Follow the clues", target: "clues" },
                        { text: "Return", target: "chapter1" }
                    ]
                },
                {
                    id: "help",
                    title: "Seeking Help",
                    content: "You encounter a mysterious figure who offers guidance.",
                    position: { x: 400, y: 350 },
                    choices: [
                        { text: "Accept help", target: "guided" },
                        { text: "Decline politely", target: "chapter1" }
                    ]
                },
                {
                    id: "clues",
                    title: "Following Clues",
                    content: "The clues lead you deeper into the mystery.",
                    position: { x: 100, y: 500 },
                    choices: [
                        { text: "Continue", target: "revelation" }
                    ]
                },
                {
                    id: "guided",
                    title: "Guided Path",
                    content: "With help, you learn secrets about this world.",
                    position: { x: 400, y: 500 },
                    choices: [
                        { text: "Continue", target: "revelation" }
                    ]
                },
                {
                    id: "revelation",
                    title: "Revelation",
                    content: "Everything becomes clear. You now understand the truth.",
                    position: { x: 250, y: 650 },
                    choices: [
                        { text: "Make your choice", target: "finale" }
                    ]
                },
                {
                    id: "finale",
                    title: "Finale",
                    content: "Your choices have led you here. The story concludes.",
                    position: { x: 250, y: 800 },
                    choices: []
                }
            ]
        };
    }

    /**
     * Generate game template
     */
    generateGameTemplate() {
        return {
            metadata: {
                title: "RPG Adventure",
                author: "Author Name",
                version: "1.0.0",
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            },
            settings: {
                startPassage: "start"
            },
            variables: {
                health: { type: "number", initial: 100 },
                gold: { type: "number", initial: 0 },
                has_sword: { type: "boolean", initial: false }
            },
            passages: [
                {
                    id: "start",
                    title: "Character Creation",
                    content: "Welcome, adventurer! Health: {{health}} | Gold: {{gold}}",
                    position: { x: 100, y: 50 },
                    choices: [
                        { text: "Begin Adventure", target: "town" }
                    ]
                },
                {
                    id: "town",
                    title: "Town Square",
                    content: "You are in the town square. Where would you like to go?",
                    position: { x: 100, y: 200 },
                    choices: [
                        { text: "Visit the shop", target: "shop" },
                        { text: "Go to the dungeon", target: "dungeon" },
                        { text: "Rest at the inn", target: "inn" }
                    ]
                },
                {
                    id: "shop",
                    title: "Shop",
                    content: "The shopkeeper greets you. Gold: {{gold}}",
                    position: { x: 100, y: 350 },
                    choices: [
                        { text: "Buy sword (50 gold)", target: "buy_sword" },
                        { text: "Leave", target: "town" }
                    ]
                },
                {
                    id: "dungeon",
                    title: "Dark Dungeon",
                    content: "You enter a dangerous dungeon. Health: {{health}}",
                    position: { x: 400, y: 350 },
                    choices: [
                        { text: "Fight monster", target: "combat" },
                        { text: "Retreat", target: "town" }
                    ]
                },
                {
                    id: "inn",
                    title: "Cozy Inn",
                    content: "You rest and recover your health.",
                    position: { x: 700, y: 350 },
                    choices: [
                        { text: "Leave", target: "town" }
                    ]
                },
                {
                    id: "buy_sword",
                    title: "Purchase",
                    content: "You bought a sword! Sword: {{has_sword}}",
                    position: { x: 100, y: 500 },
                    choices: [
                        { text: "Return to town", target: "town" }
                    ]
                },
                {
                    id: "combat",
                    title: "Battle",
                    content: "You face a fearsome monster!",
                    position: { x: 400, y: 500 },
                    choices: [
                        { text: "Victory!", target: "victory" },
                        { text: "Flee", target: "town" }
                    ]
                },
                {
                    id: "victory",
                    title: "Victory",
                    content: "You defeated the monster and found treasure!",
                    position: { x: 400, y: 650 },
                    choices: [
                        { text: "Return to town", target: "town" }
                    ]
                }
            ]
        };
    }

    /**
     * Generate quiz template
     */
    generateQuiz() {
        return {
            metadata: {
                title: "Interactive Quiz",
                author: "Author Name",
                version: "1.0.0",
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            },
            settings: {
                startPassage: "start"
            },
            variables: {
                score: { type: "number", initial: 0 }
            },
            passages: [
                {
                    id: "start",
                    title: "Quiz Introduction",
                    content: "Welcome to the quiz! Let's begin.",
                    position: { x: 100, y: 50 },
                    choices: [
                        { text: "Start Quiz", target: "q1" }
                    ]
                },
                {
                    id: "q1",
                    title: "Question 1",
                    content: "Question 1: What is 2 + 2?",
                    position: { x: 100, y: 200 },
                    choices: [
                        { text: "3", target: "q2" },
                        { text: "4", target: "q2" },
                        { text: "5", target: "q2" }
                    ]
                },
                {
                    id: "q2",
                    title: "Question 2",
                    content: "Question 2: What color is the sky?",
                    position: { x: 100, y: 350 },
                    choices: [
                        { text: "Blue", target: "q3" },
                        { text: "Green", target: "q3" },
                        { text: "Red", target: "q3" }
                    ]
                },
                {
                    id: "q3",
                    title: "Question 3",
                    content: "Question 3: How many days in a week?",
                    position: { x: 100, y: 500 },
                    choices: [
                        { text: "5", target: "results" },
                        { text: "7", target: "results" },
                        { text: "10", target: "results" }
                    ]
                },
                {
                    id: "results",
                    title: "Quiz Results",
                    content: "Quiz complete! Your score: {{score}}/3\n\nThank you for participating!",
                    position: { x: 100, y: 650 },
                    choices: []
                }
            ]
        };
    }

    /**
     * Generate tutorial template
     */
    generateTutorial() {
        return {
            metadata: {
                title: "Interactive Tutorial",
                author: "Author Name",
                version: "1.0.0",
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            },
            settings: {
                startPassage: "start"
            },
            variables: {
                progress: { type: "number", initial: 0 }
            },
            passages: [
                {
                    id: "start",
                    title: "Welcome",
                    content: "Welcome to this interactive tutorial!",
                    position: { x: 100, y: 50 },
                    choices: [
                        { text: "Begin Tutorial", target: "step1" }
                    ]
                },
                {
                    id: "step1",
                    title: "Step 1: Basics",
                    content: "Let's start with the basics...",
                    position: { x: 100, y: 200 },
                    choices: [
                        { text: "Next", target: "step2" },
                        { text: "Skip", target: "summary" }
                    ]
                },
                {
                    id: "step2",
                    title: "Step 2: Intermediate",
                    content: "Now let's try something more advanced...",
                    position: { x: 100, y: 350 },
                    choices: [
                        { text: "Next", target: "step3" },
                        { text: "Back", target: "step1" }
                    ]
                },
                {
                    id: "step3",
                    title: "Step 3: Advanced",
                    content: "Here's an advanced technique...",
                    position: { x: 100, y: 500 },
                    choices: [
                        { text: "Next", target: "practice" },
                        { text: "Back", target: "step2" }
                    ]
                },
                {
                    id: "practice",
                    title: "Practice",
                    content: "Try it yourself!",
                    position: { x: 100, y: 650 },
                    choices: [
                        { text: "Complete", target: "summary" }
                    ]
                },
                {
                    id: "summary",
                    title: "Summary",
                    content: "Tutorial complete! You've learned the essentials.",
                    position: { x: 100, y: 800 },
                    choices: []
                }
            ]
        };
    }
}

// Global instance
let templateSystem = null;
