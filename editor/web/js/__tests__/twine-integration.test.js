/**
 * Integration tests for Twine import
 * Tests the complete workflow from HTML to Whisker project
 */

const fs = require('fs');
const path = require('path');
const {
    createHarloweTestStory,
    createSugarCubeTestStory,
    createInvalidTwineHTML,
    createEmptyTwineHTML,
    assertValidWhiskerProject,
    assertValidWhiskerPassage,
    assertHasPassages,
    assertHasVariables,
    findPassageByTitle,
    countPassagesWithTag,
    getVariableNames
} = require('./test-helpers');

// Load TwineParser
const twineParserSource = fs.readFileSync(
    path.join(__dirname, '../twine-parser.js'),
    'utf8'
);
eval(twineParserSource);

describe('Twine Import Integration Tests', () => {
    describe('Harlowe Story Import', () => {
        let project;

        beforeAll(() => {
            const html = createHarloweTestStory();
            project = TwineParser.parse(html);
        });

        test('creates valid Whisker project', () => {
            assertValidWhiskerProject(project);
        });

        test('preserves story metadata', () => {
            expect(project.metadata.title).toBe('Harlowe Test');
            expect(project.metadata.twineData.format).toBe('harlowe');
            expect(project.metadata.twineData.formatVersion).toBe('3.2.3');
        });

        test('imports all passages', () => {
            expect(project.passages).toHaveLength(4);
            assertHasPassages(project, ['Start', 'Forest', 'Village', 'Victory']);
        });

        test('all passages have valid structure', () => {
            project.passages.forEach(passage => {
                assertValidWhiskerPassage(passage);
            });
        });

        test('preserves passage tags', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.tags).toContain('intro');

            const forestPassage = findPassageByTitle(project, 'Forest');
            expect(forestPassage.tags).toContain('location');
        });

        test('converts links to choices', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.choices).toHaveLength(2);
            expect(startPassage.choices[0].text).toBe('North');
            expect(startPassage.choices[1].text).toBe('South');
        });

        test('resolves choice targets correctly', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            const forestPassage = findPassageByTitle(project, 'Forest');
            const villagePassage = findPassageByTitle(project, 'Village');

            expect(startPassage.choices[0].target).toBe(forestPassage.id);
            expect(startPassage.choices[1].target).toBe(villagePassage.id);
        });

        test('converts Harlowe macros', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.content).toContain('{{health}}');
            expect(startPassage.content).toContain('game_state:set("health", 100)');
        });

        test('converts Harlowe conditionals', () => {
            const forestPassage = findPassageByTitle(project, 'Forest');
            expect(forestPassage.content).toContain('{{#if hasKey}}');
            expect(forestPassage.content).toContain('{{else}}');
            expect(forestPassage.content).toContain('{{/if}}');
        });

        test('extracts variables', () => {
            assertHasVariables(project, ['health', 'hasKey']);
            expect(project.variables.health.initial).toBe(100);
            expect(project.variables.health.type).toBe('number');
            expect(project.variables.hasKey.initial).toBe(false);
            expect(project.variables.hasKey.type).toBe('boolean');
        });

        test('preserves passage positions', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.position.x).toBe(400);
            expect(startPassage.position.y).toBe(200);
        });

        test('sets correct start passage', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(project.settings.startPassage).toBe(startPassage.id);
        });

        test('stores Twine metadata in passages', () => {
            project.passages.forEach(passage => {
                expect(passage.twineData).toBeDefined();
                expect(passage.twineData.pid).toBeDefined();
                expect(passage.twineData.originalName).toBeDefined();
                expect(passage.twineData.format).toBe('harlowe');
            });
        });

        test('removes links from passage content', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.content).not.toContain('[[North->Forest]]');
            expect(startPassage.content).not.toContain('[[South->Village]]');
        });

        test('converts print macros', () => {
            const victoryPassage = findPassageByTitle(project, 'Victory');
            expect(victoryPassage.content).toContain('{{health}}');
        });
    });

    describe('SugarCube Story Import', () => {
        let project;

        beforeAll(() => {
            const html = createSugarCubeTestStory();
            project = TwineParser.parse(html);
        });

        test('creates valid Whisker project', () => {
            assertValidWhiskerProject(project);
        });

        test('detects SugarCube format', () => {
            expect(project.metadata.twineData.format).toBe('sugarcube');
            expect(project.metadata.twineData.formatVersion).toBe('2.36.1');
        });

        test('imports all passages', () => {
            expect(project.passages).toHaveLength(4);
            assertHasPassages(project, ['Start', 'Space', 'Station', 'Victory']);
        });

        test('converts <<set>> macros', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.content).toContain('game_state:set("fuel", 100)');
            expect(startPassage.content).toContain('game_state:set("shields", false)');
        });

        test('converts SugarCube conditionals', () => {
            const spacePassage = findPassageByTitle(project, 'Space');
            expect(spacePassage.content).toContain('{{#if shields}}');
            expect(spacePassage.content).toContain('{{else}}');
            expect(spacePassage.content).toContain('{{/if}}');
        });

        test('converts variable display', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.content).toContain('{{fuel}}');
        });

        test('converts <<print>> macros', () => {
            const victoryPassage = findPassageByTitle(project, 'Victory');
            expect(victoryPassage.content).toContain('{{fuel}}');
        });

        test('extracts variables with correct types', () => {
            assertHasVariables(project, ['fuel', 'shields']);
            expect(project.variables.fuel.initial).toBe(100);
            expect(project.variables.fuel.type).toBe('number');
            expect(project.variables.shields.initial).toBe(false);
            expect(project.variables.shields.type).toBe('boolean');
        });

        test('handles pipes in links', () => {
            const startPassage = findPassageByTitle(project, 'Start');
            expect(startPassage.choices).toHaveLength(2);
            expect(startPassage.choices[0].text).toBe('Launch into space');
            expect(startPassage.choices[1].text).toBe('Visit station');
        });

        test('handles multiple tags per passage', () => {
            const spacePassage = findPassageByTitle(project, 'Space');
            expect(spacePassage.tags).toContain('location');
            expect(spacePassage.tags).toContain('danger');
        });
    });

    describe('Error Handling', () => {
        test('throws error for invalid HTML', () => {
            const html = createInvalidTwineHTML();
            expect(() => TwineParser.parse(html)).toThrow('Not a valid Twine 2 HTML file');
        });

        test('throws error for empty story', () => {
            const html = createEmptyTwineHTML();
            expect(() => TwineParser.parse(html)).toThrow('No passages found');
        });

        test('handles malformed HTML gracefully', () => {
            const html = '<html><invalid';
            expect(() => TwineParser.parse(html)).toThrow();
        });
    });

    describe('Edge Cases', () => {
        test('handles passages with no links', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="End" position="100,100">
                        The end. No links here.
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].choices).toHaveLength(0);
        });

        test('handles passages with special characters in names', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start (Part 1)" position="100,100">
                        [[Go to Part 2->End (Part 2)]]
                    </tw-passagedata>
                    <tw-passagedata pid="2" name="End (Part 2)" position="200,100">
                        Done
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages).toHaveLength(2);

            const part1 = findPassageByTitle(project, 'Start (Part 1)');
            const part2 = findPassageByTitle(project, 'End (Part 2)');

            expect(part1.id).toMatch(/start_part_1/);
            expect(part2.id).toMatch(/end_part_2/);
            expect(part1.choices[0].target).toBe(part2.id);
        });

        test('handles empty passage content', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Empty" position="100,100">
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].content).toBe('');
        });

        test('handles passages with only whitespace', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Whitespace" position="100,100">


                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].content.trim()).toBe('');
        });

        test('handles missing position attribute', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="NoPos">
                        Content
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].position.x).toBe(100);
            expect(project.passages[0].position.y).toBe(100);
        });

        test('handles missing tags attribute', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="NoTags" position="100,100">
                        Content
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].tags).toEqual([]);
        });

        test('handles very long passage names', () => {
            const longName = 'A'.repeat(100);
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="${longName}" position="100,100">
                        Content
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].id.length).toBeLessThanOrEqual(50);
        });

        test('handles numeric variable values', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="100,100">
                        (set: $x to 42)
                        (set: $y to 3.14)
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.variables.x.initial).toBe(42);
            expect(project.variables.y.initial).toBe(3.14);
        });

        test('handles string variable values', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="100,100">
                        (set: $name to "Alice")
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.variables.name.initial).toBe('Alice');
            expect(project.variables.name.type).toBe('string');
        });
    });

    describe('Real-World Scenarios', () => {
        test('handles complex branching story', () => {
            // Story with multiple paths and choices
            const html = `
                <html><body>
                <tw-storydata name="Complex" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="400,100">
                        [[Path A]]
                        [[Path B]]
                        [[Path C]]
                    </tw-passagedata>
                    <tw-passagedata pid="2" name="Path A" position="200,250">
                        [[Start]]
                        [[Ending A]]
                    </tw-passagedata>
                    <tw-passagedata pid="3" name="Path B" position="400,250">
                        [[Start]]
                        [[Ending B]]
                    </tw-passagedata>
                    <tw-passagedata pid="4" name="Path C" position="600,250">
                        [[Start]]
                        [[Ending C]]
                    </tw-passagedata>
                    <tw-passagedata pid="5" name="Ending A" position="200,400">
                        End A
                    </tw-passagedata>
                    <tw-passagedata pid="6" name="Ending B" position="400,400">
                        End B
                    </tw-passagedata>
                    <tw-passagedata pid="7" name="Ending C" position="600,400">
                        End C
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages).toHaveLength(7);

            const start = findPassageByTitle(project, 'Start');
            expect(start.choices).toHaveLength(3);
        });

        test('handles story with many variables', () => {
            const html = `
                <html><body>
                <tw-storydata name="RPG" format="SugarCube" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="100,100">
                        <<set $health to 100>>
                        <<set $mana to 50>>
                        <<set $gold to 10>>
                        <<set $level to 1>>
                        <<set $name to "Hero">>
                        <<set $hasWeapon to false>>
                        <<set $hasSword to false>>
                        <<set $hasShield to false>>
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            const varNames = getVariableNames(project);
            expect(varNames.length).toBeGreaterThanOrEqual(8);
        });
    });
});
