/**
 * Unit tests for TwineParser
 * Tests parsing of Twine 2 HTML files into Whisker format
 */

// Mock the global window object for tests that need it
global.window = global.window || {};

// Load the TwineParser class
const fs = require('fs');
const path = require('path');

// Read the TwineParser source code
const twineParserSource = fs.readFileSync(
    path.join(__dirname, '../twine-parser.js'),
    'utf8'
);

// Execute in global scope to define TwineParser class
eval(twineParserSource);

describe('TwineParser', () => {
    describe('generatePassageId', () => {
        test('converts to lowercase', () => {
            expect(TwineParser.generatePassageId('MyPassage')).toBe('mypassage');
        });

        test('replaces spaces with underscores', () => {
            expect(TwineParser.generatePassageId('My Passage Name')).toBe('my_passage_name');
        });

        test('removes special characters', () => {
            expect(TwineParser.generatePassageId('Hello! World?')).toBe('hello_world');
        });

        test('removes leading/trailing underscores', () => {
            expect(TwineParser.generatePassageId('__test__')).toBe('test');
        });

        test('handles multiple consecutive special chars', () => {
            expect(TwineParser.generatePassageId('test---passage')).toBe('test_passage');
        });

        test('limits length to 50 characters', () => {
            const longName = 'a'.repeat(100);
            expect(TwineParser.generatePassageId(longName).length).toBeLessThanOrEqual(50);
        });

        test('generates random ID for empty input', () => {
            const id = TwineParser.generatePassageId('');
            expect(id).toMatch(/^passage_[a-z0-9]+$/);
        });

        test('handles unicode characters', () => {
            expect(TwineParser.generatePassageId('Café Français')).toBe('caf_fran_ais');
        });
    });

    describe('generateIFID', () => {
        test('generates valid UUID format', () => {
            const ifid = TwineParser.generateIFID();
            expect(ifid).toMatch(/^[A-F0-9]{8}-[A-F0-9]{4}-4[A-F0-9]{3}-[89AB][A-F0-9]{3}-[A-F0-9]{12}$/);
        });

        test('generates unique IDs', () => {
            const ifid1 = TwineParser.generateIFID();
            const ifid2 = TwineParser.generateIFID();
            expect(ifid1).not.toBe(ifid2);
        });

        test('has version 4 UUID format', () => {
            const ifid = TwineParser.generateIFID();
            expect(ifid.charAt(14)).toBe('4'); // Version 4
        });
    });

    describe('detectFormat', () => {
        test('detects Harlowe', () => {
            expect(TwineParser.detectFormat('Harlowe')).toBe('harlowe');
            expect(TwineParser.detectFormat('harlowe 3.2.3')).toBe('harlowe');
            expect(TwineParser.detectFormat('HARLOWE')).toBe('harlowe');
        });

        test('detects SugarCube', () => {
            expect(TwineParser.detectFormat('SugarCube')).toBe('sugarcube');
            expect(TwineParser.detectFormat('sugarcube-2')).toBe('sugarcube');
            expect(TwineParser.detectFormat('SUGARCUBE')).toBe('sugarcube');
        });

        test('detects Snowman', () => {
            expect(TwineParser.detectFormat('Snowman')).toBe('snowman');
        });

        test('detects Chapbook', () => {
            expect(TwineParser.detectFormat('Chapbook')).toBe('chapbook');
        });

        test('returns unknown for unrecognized format', () => {
            expect(TwineParser.detectFormat('CustomFormat')).toBe('unknown');
            expect(TwineParser.detectFormat('')).toBe('unknown');
        });
    });

    describe('parseLinkFormat', () => {
        test('parses simple link [[Text]]', () => {
            const result = TwineParser.parseLinkFormat('Next Passage');
            expect(result.text).toBe('Next Passage');
            expect(result.twineName).toBe('Next Passage');
            expect(result.target).toBe('next_passage');
        });

        test('parses pipe format [[Text|Target]]', () => {
            const result = TwineParser.parseLinkFormat('Click here|Next');
            expect(result.text).toBe('Click here');
            expect(result.twineName).toBe('Next');
            expect(result.target).toBe('next');
        });

        test('parses arrow format [[Text->Target]]', () => {
            const result = TwineParser.parseLinkFormat('Click here->Next');
            expect(result.text).toBe('Click here');
            expect(result.twineName).toBe('Next');
            expect(result.target).toBe('next');
        });

        test('parses reverse arrow format [[Target<-Text]]', () => {
            const result = TwineParser.parseLinkFormat('Next<-Click here');
            expect(result.text).toBe('Click here');
            expect(result.twineName).toBe('Next');
            expect(result.target).toBe('next');
        });

        test('handles whitespace around separators', () => {
            const result = TwineParser.parseLinkFormat('Text  |  Target');
            expect(result.text).toBe('Text');
            expect(result.twineName).toBe('Target');
        });
    });

    describe('extractLinks', () => {
        test('extracts single link', () => {
            const content = 'Some text [[Next Passage]] more text';
            const result = TwineParser.extractLinks(content);
            expect(result.choices).toHaveLength(1);
            expect(result.choices[0].text).toBe('Next Passage');
            expect(result.cleanContent).toBe('Some text  more text');
        });

        test('extracts multiple links', () => {
            const content = '[[Link1]] and [[Link2]] and [[Link3]]';
            const result = TwineParser.extractLinks(content);
            expect(result.choices).toHaveLength(3);
            expect(result.choices[0].text).toBe('Link1');
            expect(result.choices[1].text).toBe('Link2');
            expect(result.choices[2].text).toBe('Link3');
        });

        test('extracts links with different formats', () => {
            const content = '[[Simple]] [[Text|Target]] [[Go->There]]';
            const result = TwineParser.extractLinks(content);
            expect(result.choices).toHaveLength(3);
            expect(result.choices[0].text).toBe('Simple');
            expect(result.choices[1].text).toBe('Text');
            expect(result.choices[2].text).toBe('Go');
        });

        test('removes links from content', () => {
            const content = 'Start [[Link1]] middle [[Link2]] end';
            const result = TwineParser.extractLinks(content);
            expect(result.cleanContent).toBe('Start  middle  end');
        });

        test('handles content with no links', () => {
            const content = 'Just plain text';
            const result = TwineParser.extractLinks(content);
            expect(result.choices).toHaveLength(0);
            expect(result.cleanContent).toBe(content);
        });

        test('handles nested brackets correctly', () => {
            const content = 'Text with [brackets] and [[Real Link]]';
            const result = TwineParser.extractLinks(content);
            expect(result.choices).toHaveLength(1);
            expect(result.choices[0].text).toBe('Real Link');
            expect(result.cleanContent).toContain('[brackets]');
        });
    });

    describe('convertHarloweToWhisker', () => {
        test('converts variable display $var to {{var}}', () => {
            const content = 'Your health is $health points';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toBe('Your health is {{health}} points');
        });

        test('converts multiple variables', () => {
            const content = '$name has $health health and $gold gold';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toContain('{{name}}');
            expect(result).toContain('{{health}}');
            expect(result).toContain('{{gold}}');
        });

        test('converts (set:) macro', () => {
            const content = '(set: $health to 100)';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toContain('game_state:set("health", 100)');
        });

        test('converts (set:) with string value', () => {
            const content = '(set: $name to "Alice")';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toContain('game_state:set("name", "Alice")');
        });

        test('converts (if:) macro', () => {
            const content = '(if: $health)[You are healthy]';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toContain('{{#if health}}');
            expect(result).toContain('{{/if}}');
        });

        test('converts (else:) macro', () => {
            const content = '(else:)[You are sick]';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toContain('{{else}}');
        });

        test('converts (print:) macro', () => {
            const content = '(print: $name)';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toBe('{{name}}');
        });

        test('handles complex content with multiple macros', () => {
            const content = '(set: $x to 5)(if: $x)[Value is $x](else:)[No value]';
            const result = TwineParser.convertHarloweToWhisker(content);
            expect(result).toContain('game_state:set');
            expect(result).toContain('{{#if x}}');
            expect(result).toContain('{{x}}');
            expect(result).toContain('{{else}}');
        });
    });

    describe('convertSugarCubeToWhisker', () => {
        test('converts variable display $var to {{var}}', () => {
            const content = 'Your health is $health points';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toBe('Your health is {{health}} points');
        });

        test('converts <<set>> macro with "to"', () => {
            const content = '<<set $health to 100>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toContain('game_state:set("health", 100)');
        });

        test('converts <<set>> macro with "="', () => {
            const content = '<<set $health = 100>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toContain('game_state:set("health", 100)');
        });

        test('converts <<if>> macro', () => {
            const content = '<<if $health>>You are healthy<<endif>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toContain('{{#if health}}');
            expect(result).toContain('{{/if}}');
        });

        test('converts <<elseif>> macro', () => {
            const content = '<<elseif $health>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toContain('{{else if health}}');
        });

        test('converts <<else>> macro', () => {
            const content = '<<else>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toBe('{{else}}');
        });

        test('converts <<print>> macro', () => {
            const content = '<<print $name>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toBe('{{name}}');
        });

        test('handles complex conditionals', () => {
            const content = '<<if $x>>A<<elseif $y>>B<<else>>C<<endif>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            expect(result).toContain('{{#if x}}');
            expect(result).toContain('{{else if y}}');
            expect(result).toContain('{{else}}');
            expect(result).toContain('{{/if}}');
        });

        test('handles uppercase macros (case insensitive)', () => {
            const content = '<<SET $health to 100>><<IF $x>>Text<<ENDIF>>';
            const result = TwineParser.convertSugarCubeToWhisker(content);
            // Macros should be case-insensitive
            expect(result).toContain('game_state:set');
            expect(result).toContain('{{#if x}}'); // $x inside IF becomes {{#if x}}, not standalone {{x}}
        });
    });

    describe('extractVariables', () => {
        test('extracts numeric variables', () => {
            const passages = [{
                content: '{{lua: game_state:set("health", 100)}}'
            }];
            const vars = TwineParser.extractVariables(passages, 'harlowe');
            expect(vars.health).toBeDefined();
            expect(vars.health.initial).toBe(100);
            expect(vars.health.type).toBe('number');
        });

        test('extracts boolean variables', () => {
            const passages = [{
                content: '{{lua: game_state:set("hasKey", false)}}'
            }];
            const vars = TwineParser.extractVariables(passages, 'harlowe');
            expect(vars.hasKey).toBeDefined();
            expect(vars.hasKey.initial).toBe(false);
            expect(vars.hasKey.type).toBe('boolean');
        });

        test('extracts string variables', () => {
            const passages = [{
                content: '{{lua: game_state:set("name", "Alice")}}'
            }];
            const vars = TwineParser.extractVariables(passages, 'harlowe');
            expect(vars.name).toBeDefined();
            expect(vars.name.initial).toBe('Alice');
            expect(vars.name.type).toBe('string');
        });

        test('extracts multiple variables from multiple passages', () => {
            const passages = [
                { content: '{{lua: game_state:set("health", 100)}}' },
                { content: '{{lua: game_state:set("gold", 50)}}' },
                { content: '{{lua: game_state:set("name", "Bob")}}' }
            ];
            const vars = TwineParser.extractVariables(passages, 'harlowe');
            expect(Object.keys(vars).length).toBe(3);
            expect(vars.health.initial).toBe(100);
            expect(vars.gold.initial).toBe(50);
            expect(vars.name.initial).toBe('Bob');
        });

        test('uses first occurrence of duplicate variables', () => {
            const passages = [
                { content: '{{lua: game_state:set("health", 100)}}' },
                { content: '{{lua: game_state:set("health", 50)}}' }
            ];
            const vars = TwineParser.extractVariables(passages, 'harlowe');
            expect(vars.health.initial).toBe(100); // First value wins
        });

        test('handles passages with no variables', () => {
            const passages = [
                { content: 'Just some plain text' }
            ];
            const vars = TwineParser.extractVariables(passages, 'harlowe');
            expect(Object.keys(vars).length).toBe(0);
        });
    });

    describe('extractMetadata', () => {
        test('extracts basic metadata', () => {
            const storyData = {
                getAttribute: (attr) => {
                    const attrs = {
                        'name': 'Test Story',
                        'creator': 'Test Author',
                        'ifid': '12345-ABCDE',
                        'format': 'Harlowe',
                        'format-version': '3.2.3',
                        'startnode': '1'
                    };
                    return attrs[attr];
                }
            };

            const metadata = TwineParser.extractMetadata(storyData);
            expect(metadata.title).toBe('Test Story');
            expect(metadata.author).toBe('Test Author');
            expect(metadata.ifid).toBe('12345-ABCDE');
            expect(metadata.format).toBe('harlowe');
            expect(metadata.formatVersion).toBe('3.2.3');
            expect(metadata.startPassage).toBe('1');
        });

        test('generates IFID if missing', () => {
            const storyData = {
                getAttribute: (attr) => {
                    if (attr === 'ifid') return null;
                    return attr === 'format' ? 'Harlowe' : 'Test';
                }
            };

            const metadata = TwineParser.extractMetadata(storyData);
            expect(metadata.ifid).toMatch(/^[A-F0-9-]+$/);
        });

        test('handles missing optional fields', () => {
            const storyData = {
                getAttribute: (attr) => {
                    if (attr === 'name') return 'Story';
                    if (attr === 'format') return 'Harlowe';
                    return null;
                }
            };

            const metadata = TwineParser.extractMetadata(storyData);
            expect(metadata.title).toBe('Story');
            expect(metadata.author).toBe('Unknown');
            expect(metadata.formatVersion).toBe('');
        });
    });

    describe('parse - integration tests', () => {
        test('parses minimal valid Twine HTML', () => {
            const html = `
                <!DOCTYPE html>
                <html>
                <body>
                <tw-storydata name="Test" creator="Author" ifid="123" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" tags="" position="100,100">
                        Hello world!
                        [[Next]]
                    </tw-passagedata>
                    <tw-passagedata pid="2" name="Next" tags="" position="200,100">
                        The end.
                    </tw-passagedata>
                </tw-storydata>
                </body>
                </html>
            `;

            const project = TwineParser.parse(html);

            expect(project.metadata.title).toBe('Test');
            expect(project.passages).toHaveLength(2);
            expect(project.passages[0].title).toBe('Start');
            expect(project.passages[1].title).toBe('Next');
            expect(project.passages[0].choices).toHaveLength(1);
            expect(project.settings.startPassage).toBe('start');
        });

        test('throws error for missing tw-storydata', () => {
            const html = '<html><body>Not a Twine file</body></html>';
            expect(() => TwineParser.parse(html)).toThrow('Not a valid Twine 2 HTML file');
        });

        test('throws error for no passages', () => {
            const html = `
                <html><body>
                <tw-storydata name="Empty" format="Harlowe">
                </tw-storydata>
                </body></html>
            `;
            expect(() => TwineParser.parse(html)).toThrow('No passages found');
        });

        test('resolves link targets correctly', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="100,100">
                        [[End]]
                    </tw-passagedata>
                    <tw-passagedata pid="2" name="End" position="200,100">
                        Done
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            const startPassage = project.passages[0];
            const endPassage = project.passages[1];

            expect(startPassage.choices[0].target).toBe(endPassage.id);
            expect(startPassage.choices[0].target).toBe('end');
        });

        test('preserves passage positions', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="400,200">
                        Text
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].position.x).toBe(400);
            expect(project.passages[0].position.y).toBe(200);
        });

        test('preserves passage tags', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" startnode="1">
                    <tw-passagedata pid="1" name="Start" tags="intro menu important" position="100,100">
                        Text
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.passages[0].tags).toEqual(['intro', 'menu', 'important']);
        });

        test('stores Twine metadata for reference', () => {
            const html = `
                <html><body>
                <tw-storydata name="Test" format="Harlowe" format-version="3.2.3" startnode="1">
                    <tw-passagedata pid="1" name="Start" position="100,100">
                        Text
                    </tw-passagedata>
                </tw-storydata>
                </body></html>
            `;

            const project = TwineParser.parse(html);
            expect(project.metadata.twineData.format).toBe('harlowe');
            expect(project.metadata.twineData.formatVersion).toBe('3.2.3');
            expect(project.passages[0].twineData.pid).toBe('1');
            expect(project.passages[0].twineData.originalName).toBe('Start');
        });
    });
});
