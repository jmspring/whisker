/**
 * Test Helpers and Utilities
 * Common functions and mock data for Twine import tests
 */

/**
 * Create a minimal valid Twine HTML file
 * @param {Object} options - Configuration options
 * @returns {string} HTML string
 */
function createTwineHTML(options = {}) {
    const {
        name = 'Test Story',
        creator = 'Test Author',
        ifid = '12345678-1234-4123-8123-123456789ABC',
        format = 'Harlowe',
        formatVersion = '3.2.3',
        startnode = '1',
        passages = []
    } = options;

    const defaultPassages = passages.length > 0 ? passages : [
        {
            pid: '1',
            name: 'Start',
            tags: '',
            position: '100,100',
            content: 'Welcome to the story!\n\n[[Next Passage]]'
        }
    ];

    const passageHTML = defaultPassages.map(p => `
        <tw-passagedata pid="${p.pid}" name="${p.name}" tags="${p.tags || ''}" position="${p.position || '100,100'}" size="100,100">
${p.content}
        </tw-passagedata>
    `).join('\n');

    return `<!DOCTYPE html>
<html>
<head>
    <title>${name}</title>
    <meta charset="UTF-8">
</head>
<body>
<tw-storydata name="${name}" startnode="${startnode}" creator="${creator}"
              creator-version="2.3.14" ifid="${ifid}" zoom="1"
              format="${format}" format-version="${formatVersion}" options="" hidden>

<style role="stylesheet" id="twine-user-stylesheet" type="text/twine-css"></style>
<script role="script" id="twine-user-script" type="text/twine-javascript"></script>

${passageHTML}

</tw-storydata>
</body>
</html>`;
}

/**
 * Create a Harlowe-specific test story
 * @returns {string} HTML string
 */
function createHarloweTestStory() {
    return createTwineHTML({
        name: 'Harlowe Test',
        format: 'Harlowe',
        formatVersion: '3.2.3',
        passages: [
            {
                pid: '1',
                name: 'Start',
                tags: 'intro',
                position: '400,200',
                content: `You wake up with $health health.

(set: $health to 100)
(set: $hasKey to false)

Where do you go?

[[North->Forest]]
[[South->Village]]`
            },
            {
                pid: '2',
                name: 'Forest',
                tags: 'location',
                position: '400,350',
                content: `(if: $hasKey)[
    You unlock the gate with the key!
    [[Continue->Victory]]
](else:)[
    The gate is locked.
    [[Go back->Start]]
]`
            },
            {
                pid: '3',
                name: 'Village',
                tags: 'location',
                position: '600,350',
                content: `You find a key on the ground.

(set: $hasKey to true)

[[Return->Start]]`
            },
            {
                pid: '4',
                name: 'Victory',
                tags: 'ending',
                position: '400,500',
                content: `Congratulations! You won!

Final health: (print: $health)

[[Play again->Start]]`
            }
        ]
    });
}

/**
 * Create a SugarCube-specific test story
 * @returns {string} HTML string
 */
function createSugarCubeTestStory() {
    return createTwineHTML({
        name: 'SugarCube Test',
        format: 'SugarCube',
        formatVersion: '2.36.1',
        passages: [
            {
                pid: '1',
                name: 'Start',
                tags: 'intro',
                position: '400,200',
                content: `<<set $fuel to 100>>
<<set $shields to false>>

Fuel: $fuel

[[Launch into space|Space]]
[[Visit station|Station]]`
            },
            {
                pid: '2',
                name: 'Space',
                tags: 'location danger',
                position: '400,350',
                content: `<<set $fuel to $fuel - 20>>

<<if $shields>>
    Your shields protect you!
    [[Continue|Victory]]
<<else>>
    It's too dangerous!
    [[Return|Start]]
<<endif>>`
            },
            {
                pid: '3',
                name: 'Station',
                tags: 'location',
                position: '600,350',
                content: `<<set $shields to true>>

Shields installed!

[[Launch|Space]]`
            },
            {
                pid: '4',
                name: 'Victory',
                tags: 'ending',
                position: '400,500',
                content: `Mission complete!

Fuel remaining: <<print $fuel>>

[[Restart|Start]]`
            }
        ]
    });
}

/**
 * Create invalid Twine HTML (missing tw-storydata)
 * @returns {string} HTML string
 */
function createInvalidTwineHTML() {
    return `<!DOCTYPE html>
<html>
<head><title>Not Twine</title></head>
<body>
    <div>This is not a Twine story</div>
</body>
</html>`;
}

/**
 * Create Twine HTML with no passages
 * @returns {string} HTML string
 */
function createEmptyTwineHTML() {
    return `<!DOCTYPE html>
<html>
<body>
<tw-storydata name="Empty Story" format="Harlowe" startnode="1">
</tw-storydata>
</body>
</html>`;
}

/**
 * Create mock File object for testing
 * @param {string} content - File content
 * @param {string} filename - File name
 * @returns {File} Mock File object
 */
function createMockFile(content, filename = 'test.html') {
    const file = new File([content], filename, { type: 'text/html' });
    // Mock text() method to return content
    file.text = jest.fn().mockResolvedValue(content);
    return file;
}

/**
 * Create mock editor instance for testing
 * @returns {Object} Mock editor
 */
function createMockEditor() {
    return {
        project: null,
        currentPassage: null,
        currentView: 'graph',

        updateStatus: jest.fn(),
        renderAll: jest.fn(),
        renderPassageList: jest.fn(),
        switchView: jest.fn(function(view) {
            this.currentView = view;
        }),
        showNotification: jest.fn()
    };
}

/**
 * Setup DOM environment for testing
 * Creates necessary HTML elements
 */
function setupTestDOM() {
    document.body.innerHTML = `
        <div id="welcomeScreen" class="welcome-screen"></div>
        <div id="graphView" class="hidden"></div>
        <div id="editorContent" class="hidden"></div>
        <div id="passageList"></div>
        <div id="variablesList"></div>
    `;
}

/**
 * Setup global mocks for browser APIs
 */
function setupGlobalMocks() {
    global.confirm = jest.fn(() => true);
    global.alert = jest.fn();

    global.window = global.window || {};

    global.window.graph = {
        render: jest.fn(),
        autoLayout: jest.fn(),
        zoomToFit: jest.fn()
    };

    global.window.historySystem = {
        recordState: jest.fn(),
        undo: jest.fn(),
        redo: jest.fn()
    };

    global.window.validationSystem = {
        validate: jest.fn()
    };
}

/**
 * Clean up after tests
 */
function cleanupAfterTest() {
    document.body.innerHTML = '';
    jest.clearAllMocks();
}

/**
 * Assert that a Whisker project has valid structure
 * @param {Object} project - Project to validate
 */
function assertValidWhiskerProject(project) {
    expect(project).toBeDefined();
    expect(project.metadata).toBeDefined();
    expect(project.metadata.title).toBeDefined();
    expect(project.passages).toBeDefined();
    expect(Array.isArray(project.passages)).toBe(true);
    expect(project.variables).toBeDefined();
    expect(typeof project.variables).toBe('object');
    expect(project.settings).toBeDefined();
    expect(project.settings.startPassage).toBeDefined();
}

/**
 * Assert that a passage has valid Whisker structure
 * @param {Object} passage - Passage to validate
 */
function assertValidWhiskerPassage(passage) {
    expect(passage).toBeDefined();
    expect(passage.id).toBeDefined();
    expect(passage.title).toBeDefined();
    expect(passage.content).toBeDefined();
    expect(Array.isArray(passage.choices)).toBe(true);
    expect(passage.position).toBeDefined();
    expect(typeof passage.position.x).toBe('number');
    expect(typeof passage.position.y).toBe('number');
}

/**
 * Find passage by title in project
 * @param {Object} project - Whisker project
 * @param {string} title - Passage title
 * @returns {Object|null} Passage or null
 */
function findPassageByTitle(project, title) {
    return project.passages.find(p => p.title === title) || null;
}

/**
 * Count passages with specific tag
 * @param {Object} project - Whisker project
 * @param {string} tag - Tag to count
 * @returns {number} Count
 */
function countPassagesWithTag(project, tag) {
    return project.passages.filter(p => p.tags && p.tags.includes(tag)).length;
}

/**
 * Get all variable names from project
 * @param {Object} project - Whisker project
 * @returns {Array<string>} Variable names
 */
function getVariableNames(project) {
    return Object.keys(project.variables);
}

/**
 * Assert project has expected passages
 * @param {Object} project - Whisker project
 * @param {Array<string>} expectedTitles - Expected passage titles
 */
function assertHasPassages(project, expectedTitles) {
    const actualTitles = project.passages.map(p => p.title);
    expectedTitles.forEach(title => {
        expect(actualTitles).toContain(title);
    });
}

/**
 * Assert project has expected variables
 * @param {Object} project - Whisker project
 * @param {Array<string>} expectedVars - Expected variable names
 */
function assertHasVariables(project, expectedVars) {
    const actualVars = Object.keys(project.variables);
    expectedVars.forEach(varName => {
        expect(actualVars).toContain(varName);
    });
}

/**
 * Create test passage for parser testing
 * @param {Object} overrides - Property overrides
 * @returns {Object} Mock passage element
 */
function createMockPassageElement(overrides = {}) {
    const defaults = {
        pid: '1',
        name: 'Test Passage',
        tags: 'test',
        position: '100,100'
    };

    const attrs = { ...defaults, ...overrides };

    return {
        getAttribute: (attr) => attrs[attr] || null,
        textContent: attrs.content || 'Test content'
    };
}

// Export all helpers
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        createTwineHTML,
        createHarloweTestStory,
        createSugarCubeTestStory,
        createInvalidTwineHTML,
        createEmptyTwineHTML,
        createMockFile,
        createMockEditor,
        setupTestDOM,
        setupGlobalMocks,
        cleanupAfterTest,
        assertValidWhiskerProject,
        assertValidWhiskerPassage,
        findPassageByTitle,
        countPassagesWithTag,
        getVariableNames,
        assertHasPassages,
        assertHasVariables,
        createMockPassageElement
    };
}
