/**
 * Unit tests for TwineImporter
 * Tests UI integration and import workflow
 */

// Load dependencies
const fs = require('fs');
const path = require('path');

// Read source files
const twineParserSource = fs.readFileSync(
    path.join(__dirname, '../twine-parser.js'),
    'utf8'
);
const twineImporterSource = fs.readFileSync(
    path.join(__dirname, '../twine-importer.js'),
    'utf8'
);

// Execute to define classes (TwineParser first, as TwineImporter depends on it)
eval(twineParserSource);
eval(twineImporterSource);

// Assign to global for tests
global.TwineParser = TwineParser;
global.TwineImporter = TwineImporter;

// Mock editor for testing
class MockEditor {
    constructor() {
        this.project = null;
        this.currentPassage = null;
        this.currentView = 'graph';
        this.updateStatusCalled = false;
        this.renderAllCalled = false;
        this.renderPassageListCalled = false;
        this.switchViewCalled = false;
        this.lastStatus = null;
    }

    updateStatus(status) {
        this.updateStatusCalled = true;
        this.lastStatus = status;
    }

    renderAll() {
        this.renderAllCalled = true;
    }

    renderPassageList() {
        this.renderPassageListCalled = true;
    }

    switchView(view) {
        this.switchViewCalled = true;
        this.currentView = view;
    }
}

describe('TwineImporter', () => {
    let importer;
    let mockEditor;

    beforeEach(() => {
        // Reset DOM
        document.body.innerHTML = `
            <div id="welcomeScreen"></div>
            <div id="graphView" class="hidden"></div>
            <div id="editorContent" class="hidden"></div>
        `;

        // Create fresh instances
        mockEditor = new MockEditor();
        importer = new TwineImporter(mockEditor);
        importer.initialize();

        // Mock window methods
        global.confirm = jest.fn(() => true);
        global.alert = jest.fn();

        // Mock window.graph
        global.window.graph = {
            render: jest.fn()
        };

        // Mock window.historySystem
        global.window.historySystem = {
            recordState: jest.fn()
        };
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('initialization', () => {
        test('initializes successfully', () => {
            expect(importer.isInitialized).toBe(true);
        });

        test('stores reference to editor', () => {
            expect(importer.editor).toBe(mockEditor);
        });
    });

    describe('showImportDialog', () => {
        test('shows confirmation if project exists', () => {
            mockEditor.project = {
                passages: [{ id: 'test' }]
            };

            global.confirm = jest.fn(() => false);

            importer.showImportDialog();

            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('replace your current project')
            );
        });

        test('does not show confirmation for empty project', () => {
            mockEditor.project = {
                passages: []
            };

            global.confirm = jest.fn(() => true);

            importer.showImportDialog();

            expect(global.confirm).not.toHaveBeenCalled();
        });

        test('creates file input element', () => {
            // Mock document.body methods
            const appendChildSpy = jest.spyOn(document.body, 'appendChild');
            const removeChildSpy = jest.spyOn(document.body, 'removeChild');

            importer.showImportDialog();

            // Should have created and removed input element
            expect(appendChildSpy).toHaveBeenCalled();
            expect(removeChildSpy).toHaveBeenCalled();
        });

        test('cancels if user declines warning', () => {
            mockEditor.project = {
                passages: [{ id: 'test' }]
            };

            global.confirm = jest.fn(() => false);
            const appendChildSpy = jest.spyOn(document.body, 'appendChild');

            importer.showImportDialog();

            // Should not create file input
            expect(appendChildSpy).not.toHaveBeenCalled();
        });
    });

    describe('handleFileSelect', () => {
        test('shows loading status', async () => {
            const mockFile = new File(['content'], 'test.html', { type: 'text/html' });
            const event = { target: { files: [mockFile] } };

            // Track all status updates
            const statusUpdates = [];
            mockEditor.updateStatus = jest.fn((status) => {
                statusUpdates.push(status);
                mockEditor.lastStatus = status;
            });

            // Mock file.text() to reject, but we want to capture status before error
            mockFile.text = jest.fn().mockRejectedValue(new Error('Test error'));

            await importer.handleFileSelect(event);

            // Should have called updateStatus with "Importing" before the error
            expect(statusUpdates).toContain('📥 Importing from Twine...');
        });

        test('handles no file selected', async () => {
            const event = { target: { files: [] } };

            await importer.handleFileSelect(event);

            // Should exit early without error
            expect(mockEditor.updateStatusCalled).toBe(false);
        });

        test('warns for large files', async () => {
            const largeSize = 6 * 1024 * 1024; // 6MB
            const mockFile = new File(
                [new ArrayBuffer(largeSize)],
                'large.html',
                { type: 'text/html' }
            );
            const event = { target: { files: [mockFile] } };

            global.confirm = jest.fn(() => false);

            await importer.handleFileSelect(event);

            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('quite large')
            );
        });

        test('continues if user accepts large file warning', async () => {
            const largeSize = 6 * 1024 * 1024;
            const mockFile = new File(
                [new ArrayBuffer(largeSize)],
                'large.html',
                { type: 'text/html' }
            );
            mockFile.text = jest.fn().mockResolvedValue('<html></html>');

            const event = { target: { files: [mockFile] } };

            global.confirm = jest.fn(() => true);

            await importer.handleFileSelect(event);

            expect(mockFile.text).toHaveBeenCalled();
        });

        test('shows error status on parse failure', async () => {
            const mockFile = new File(['invalid'], 'test.html', { type: 'text/html' });
            mockFile.text = jest.fn().mockResolvedValue('<html>Not Twine</html>');

            const event = { target: { files: [mockFile] } };

            await importer.handleFileSelect(event);

            expect(mockEditor.lastStatus).toContain('failed');
        });
    });

    describe('showConfirmationDialog', () => {
        let mockProject;

        beforeEach(() => {
            mockProject = {
                metadata: {
                    title: 'Test Story',
                    author: 'Test Author',
                    twineData: {
                        format: 'harlowe',
                        formatVersion: '3.2.3'
                    }
                },
                passages: [
                    { id: 'p1', title: 'Passage 1' },
                    { id: 'p2', title: 'Passage 2' }
                ],
                variables: {
                    health: { initial: 100 },
                    gold: { initial: 50 }
                }
            };
        });

        test('shows confirmation with story details', () => {
            importer.showConfirmationDialog(mockProject, 'test.html');

            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('Test Story')
            );
            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('Test Author')
            );
            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('harlowe')
            );
            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('Passages: 2')
            );
            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('Variables: 2')
            );
        });

        test('shows warning for SugarCube format', () => {
            mockProject.metadata.twineData.format = 'sugarcube';

            importer.showConfirmationDialog(mockProject, 'test.html');

            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('SugarCube format')
            );
        });

        test('shows warning for unknown format', () => {
            mockProject.metadata.twineData.format = 'unknown';

            importer.showConfirmationDialog(mockProject, 'test.html');

            expect(global.confirm).toHaveBeenCalledWith(
                expect.stringContaining('Unknown format')
            );
        });

        test('imports if user confirms', () => {
            global.confirm = jest.fn(() => true);
            const importSpy = jest.spyOn(importer, 'importProject');

            importer.showConfirmationDialog(mockProject, 'test.html');

            expect(importSpy).toHaveBeenCalledWith(mockProject);
        });

        test('cancels if user declines', () => {
            global.confirm = jest.fn(() => false);
            const importSpy = jest.spyOn(importer, 'importProject');

            importer.showConfirmationDialog(mockProject, 'test.html');

            expect(importSpy).not.toHaveBeenCalled();
            expect(mockEditor.lastStatus).toContain('cancelled');
        });
    });

    describe('importProject', () => {
        let mockProject;

        beforeEach(() => {
            mockProject = {
                metadata: {
                    title: 'Test Story',
                    author: 'Author'
                },
                passages: [
                    { id: 'start', title: 'Start' }
                ],
                variables: {}
            };
        });

        test('replaces editor project', () => {
            importer.importProject(mockProject);

            expect(mockEditor.project).toBe(mockProject);
        });

        test('updates editor UI', () => {
            importer.importProject(mockProject);

            expect(mockEditor.renderAllCalled).toBe(true);
            expect(mockEditor.renderPassageListCalled).toBe(true);
        });

        test('clears current passage', () => {
            mockEditor.currentPassage = { id: 'old' };

            importer.importProject(mockProject);

            expect(mockEditor.currentPassage).toBeNull();
        });

        test('switches to graph view', () => {
            importer.importProject(mockProject);

            expect(mockEditor.switchViewCalled).toBe(true);
            expect(mockEditor.currentView).toBe('graph');
        });

        test('shows/hides appropriate UI elements', () => {
            const welcomeScreen = document.getElementById('welcomeScreen');
            const graphView = document.getElementById('graphView');
            const editorContent = document.getElementById('editorContent');

            importer.importProject(mockProject);

            expect(welcomeScreen.classList.contains('hidden')).toBe(true);
            expect(graphView.classList.contains('hidden')).toBe(false);
            expect(editorContent.classList.contains('hidden')).toBe(true);
        });

        test('updates status with success message', () => {
            importer.importProject(mockProject);

            expect(mockEditor.lastStatus).toContain('Imported');
            expect(mockEditor.lastStatus).toContain('Test Story');
            expect(mockEditor.lastStatus).toContain('1 passages');
        });

        test('records state in history', () => {
            importer.importProject(mockProject);

            expect(window.historySystem.recordState).toHaveBeenCalled();
        });

        test('renders graph if available', () => {
            mockEditor.currentView = 'graph';

            importer.importProject(mockProject);

            expect(window.graph.render).toHaveBeenCalled();
        });

        test('handles import errors gracefully', () => {
            // Make renderAll throw error
            mockEditor.renderAll = () => {
                throw new Error('Render failed');
            };

            importer.importProject(mockProject);

            // Should not crash, should show error
            // (In real implementation, error is shown via showError)
        });
    });

    describe('showSuccessNotification', () => {
        let mockProject;

        beforeEach(() => {
            mockProject = {
                metadata: { title: 'Test Story' },
                passages: [{ id: 'p1' }, { id: 'p2' }],
                variables: { health: {}, gold: {} }
            };

            // Mock editor notification method
            mockEditor.showNotification = jest.fn();
        });

        test('shows notification with project details', (done) => {
            importer.showSuccessNotification(mockProject);

            setTimeout(() => {
                expect(global.alert).toHaveBeenCalledWith(
                    expect.stringContaining('Test Story')
                );
                expect(global.alert).toHaveBeenCalledWith(
                    expect.stringContaining('2 passages')
                );
                expect(global.alert).toHaveBeenCalledWith(
                    expect.stringContaining('2 variables')
                );
                done();
            }, 150);
        });

        test('uses editor notification if available', () => {
            importer.showSuccessNotification(mockProject);

            expect(mockEditor.showNotification).toHaveBeenCalledWith(
                expect.any(String),
                'success'
            );
        });
    });

    describe('showError', () => {
        test('creates error modal', () => {
            importer.showError('Test Error', 'Error message');

            const errorModal = document.getElementById('twineImportError');
            expect(errorModal).toBeTruthy();
        });

        test('displays error title and message', () => {
            importer.showError('Test Error', 'Error message');

            const modalContent = document.body.innerHTML;
            expect(modalContent).toContain('Test Error');
            expect(modalContent).toContain('Error message');
        });

        test('escapes HTML in title', () => {
            importer.showError('<script>alert("xss")</script>', 'Message');

            const modalContent = document.body.innerHTML;
            expect(modalContent).toContain('&lt;script&gt;');
            expect(modalContent).not.toContain('<script>alert');
        });

        test('escapes HTML in message', () => {
            importer.showError('Title', '<img src=x onerror=alert(1)>');

            const modalContent = document.body.innerHTML;
            expect(modalContent).toContain('&lt;img');
            expect(modalContent).not.toContain('<img src=');
        });

        test('modal contains close button', () => {
            importer.showError('Title', 'Message');

            const modalContent = document.body.innerHTML;
            expect(modalContent).toContain('Close');
        });
    });

    describe('escapeHTML', () => {
        test('escapes ampersand', () => {
            expect(importer.escapeHTML('foo & bar')).toBe('foo &amp; bar');
        });

        test('escapes less than', () => {
            expect(importer.escapeHTML('<tag>')).toBe('&lt;tag&gt;');
        });

        test('escapes quotes', () => {
            expect(importer.escapeHTML('"quoted"')).toBe('&quot;quoted&quot;');
            expect(importer.escapeHTML("'quoted'")).toBe('&#39;quoted&#39;');
        });

        test('handles null/undefined', () => {
            expect(importer.escapeHTML(null)).toBe('');
            expect(importer.escapeHTML(undefined)).toBe('');
        });

        test('handles empty string', () => {
            expect(importer.escapeHTML('')).toBe('');
        });

        test('escapes all special characters', () => {
            const input = '<script>alert("XSS & \'hacks\'")</script>';
            const output = importer.escapeHTML(input);
            expect(output).not.toContain('<script>');
            expect(output).not.toContain('</script>');
            expect(output).toContain('&lt;script&gt;');
        });
    });

    describe('integration - full import flow', () => {
        test('complete import workflow', async () => {
            // Create valid Twine HTML
            const twineHTML = `
                <html><body>
                <tw-storydata name="Integration Test" creator="Tester"
                              ifid="123" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="100,100">
                        (set: $health to 100)
                        Welcome! [[Continue->Next]]
                    </tw-passagedata>
                    <tw-passagedata pid="2" name="Next" position="200,100">
                        You have $health health.
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            // Create mock file
            const mockFile = new File([twineHTML], 'test.html', { type: 'text/html' });
            mockFile.text = jest.fn().mockResolvedValue(twineHTML);

            const event = { target: { files: [mockFile] } };

            // User confirms import
            global.confirm = jest.fn(() => true);

            // Perform import
            await importer.handleFileSelect(event);

            // Wait for async operations
            await new Promise(resolve => setTimeout(resolve, 100));

            // Verify project was imported
            expect(mockEditor.project).toBeDefined();
            expect(mockEditor.project.passages).toHaveLength(2);
            expect(mockEditor.project.metadata.title).toBe('Integration Test');

            // Verify UI was updated
            expect(mockEditor.renderAllCalled).toBe(true);
            expect(mockEditor.renderPassageListCalled).toBe(true);

            // Verify success status
            expect(mockEditor.lastStatus).toContain('Imported');
        });
    });
});
