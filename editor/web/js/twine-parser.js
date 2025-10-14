/**
 * Twine Parser - Parse Twine 2 HTML files into Whisker format
 *
 * Supports:
 * - Twine 2 HTML format
 * - Harlowe, SugarCube, Snowman, Chapbook formats
 * - All Twine link styles
 * - Basic macro conversion
 * - Passage positions for graph view
 *
 * @version 1.0.0
 */

class TwineParser {
    /**
     * Parse Twine 2 HTML file into Whisker project format
     * @param {string} htmlContent - Raw HTML from .html file
     * @returns {Object} Whisker project structure
     */
    static parse(htmlContent) {
        console.log('[TwineParser] Starting parse...');

        try {
            // Create DOM parser
            const parser = new DOMParser();
            const doc = parser.parseFromString(htmlContent, 'text/html');

            // Find tw-storydata element
            const storyData = doc.querySelector('tw-storydata');
            if (!storyData) {
                throw new Error('Not a valid Twine 2 HTML file (missing <tw-storydata>)');
            }

            // Extract metadata
            const metadata = this.extractMetadata(storyData);
            console.log('[TwineParser] Metadata:', metadata);

            // Find all passages
            const passageElements = storyData.querySelectorAll('tw-passagedata');
            if (passageElements.length === 0) {
                throw new Error('No passages found in Twine story');
            }

            console.log('[TwineParser] Found', passageElements.length, 'passages');

            // Parse each passage
            const passages = [];
            const passageMap = new Map(); // For resolving link targets

            passageElements.forEach(passageEl => {
                const passage = this.parsePassage(passageEl, metadata.format, htmlContent);
                passages.push(passage);
                // Store mapping of Twine name to Whisker ID
                passageMap.set(passageEl.getAttribute('name'), passage.id);
            });

            // Resolve choice targets (convert Twine names to Whisker IDs)
            passages.forEach(passage => {
                passage.choices = passage.choices.map(choice => ({
                    ...choice,
                    target: passageMap.get(choice.twineName) || choice.target
                }));
            });

            // Find start passage
            const startPassageName = storyData.getAttribute('startnode');
            const startPassageId = passageMap.get(startPassageName) || passages[0]?.id;

            console.log('[TwineParser] Start passage:', startPassageName, '→', startPassageId);

            // Build Whisker project structure
            const project = {
                metadata: {
                    title: metadata.title,
                    author: metadata.author,
                    description: `Imported from Twine (${metadata.format})`,
                    ifid: metadata.ifid,
                    created: new Date().toISOString(),
                    modified: new Date().toISOString(),
                    twineData: {
                        format: metadata.format,
                        formatVersion: metadata.formatVersion,
                        originalFile: true
                    }
                },
                settings: {
                    startPassage: startPassageId,
                    theme: 'light'
                },
                variables: this.extractVariables(passages, metadata.format),
                passages: passages
            };

            console.log('[TwineParser] Parse complete!');
            console.log('[TwineParser] Passages:', passages.length);
            console.log('[TwineParser] Variables:', Object.keys(project.variables).length);

            return project;

        } catch (error) {
            console.error('[TwineParser] Parse error:', error);
            throw error;
        }
    }

    /**
     * Extract story metadata from tw-storydata element
     * @param {Element} storyDataElement - <tw-storydata> element
     * @returns {Object} Metadata object
     */
    static extractMetadata(storyDataElement) {
        const format = storyDataElement.getAttribute('format') || 'Unknown';
        const formatVersion = storyDataElement.getAttribute('format-version') || '';

        return {
            title: storyDataElement.getAttribute('name') || 'Untitled',
            author: storyDataElement.getAttribute('creator') || 'Unknown',
            ifid: storyDataElement.getAttribute('ifid') || this.generateIFID(),
            format: this.detectFormat(format),
            formatVersion: formatVersion,
            startPassage: storyDataElement.getAttribute('startnode')
        };
    }

    /**
     * Parse a single Twine passage
     * @param {Element} passageElement - <tw-passagedata> element
     * @param {string} format - Story format (harlowe, sugarcube, etc.)
     * @param {string} rawHTML - Original HTML string (to extract unmolested content)
     * @returns {Object} Whisker passage object
     */
    static parsePassage(passageElement, format, rawHTML = '') {
        const pid = passageElement.getAttribute('pid');
        const name = passageElement.getAttribute('name');
        const tags = (passageElement.getAttribute('tags') || '').split(' ').filter(t => t);
        const position = (passageElement.getAttribute('position') || '100,100').split(',');

        // Extract content from raw HTML to avoid jsdom mangling <<>> macros
        let content = this.extractPassageContentFromRaw(rawHTML, pid, name) || passageElement.textContent;

        console.log('[TwineParser] Parsing passage:', name);

        // Extract links and convert to choices
        const linkInfo = this.extractLinks(content);
        const choices = linkInfo.choices;
        content = linkInfo.cleanContent;

        // Convert Twine macros/syntax to Whisker syntax
        content = this.convertTwineToWhisker(content, format);

        return {
            id: this.generatePassageId(name),
            title: name,
            content: content.trim(),
            choices: choices,
            position: {
                x: parseInt(position[0]) || 100,
                y: parseInt(position[1]) || 100
            },
            tags: tags,
            twineData: {
                pid: pid,
                originalName: name,
                format: format
            }
        };
    }

    /**
     * Extract Twine links from content and convert to choices
     * @param {string} content - Passage content
     * @returns {Object} {choices, cleanContent}
     */
    static extractLinks(content) {
        const linkRegex = /\[\[([^\]]+)\]\]/g;
        const choices = [];
        const linkPositions = []; // Track positions to remove

        let match;
        while ((match = linkRegex.exec(content)) !== null) {
            const linkContent = match[1];
            const choice = this.parseLinkFormat(linkContent);
            if (choice) {
                choices.push(choice);
                linkPositions.push({
                    start: match.index,
                    end: match.index + match[0].length
                });
            }
        }

        // Remove links from content (they become choices)
        // Go backwards to maintain correct indices
        let cleanContent = content;
        for (let i = linkPositions.length - 1; i >= 0; i--) {
            const pos = linkPositions[i];
            cleanContent = cleanContent.substring(0, pos.start) + cleanContent.substring(pos.end);
        }

        return {
            choices: choices,
            cleanContent: cleanContent
        };
    }

    /**
     * Parse different Twine link formats
     * Supports:
     * - [[Link Text]]
     * - [[Link Text|Target]]
     * - [[Link Text->Target]]
     * - [[Target<-Link Text]]
     *
     * @param {string} linkContent - Content between [[ ]]
     * @returns {Object} Choice object {text, target, twineName}
     */
    static parseLinkFormat(linkContent) {
        // [[Text|Target]]
        if (linkContent.includes('|')) {
            const [text, target] = linkContent.split('|').map(s => s.trim());
            return {
                text: text,
                target: this.generatePassageId(target),
                twineName: target // Store original name for resolution
            };
        }

        // [[Text->Target]]
        if (linkContent.includes('->')) {
            const [text, target] = linkContent.split('->').map(s => s.trim());
            return {
                text: text,
                target: this.generatePassageId(target),
                twineName: target
            };
        }

        // [[Target<-Text]]
        if (linkContent.includes('<-')) {
            const [target, text] = linkContent.split('<-').map(s => s.trim());
            return {
                text: text,
                target: this.generatePassageId(target),
                twineName: target
            };
        }

        // [[Text]] (text is also the target)
        const trimmed = linkContent.trim();
        return {
            text: trimmed,
            target: this.generatePassageId(trimmed),
            twineName: trimmed
        };
    }

    /**
     * Convert Twine syntax to Whisker syntax
     * @param {string} content - Twine content
     * @param {string} format - Story format (harlowe, sugarcube, etc.)
     * @returns {string} Whisker-compatible content
     */
    static convertTwineToWhisker(content, format) {
        let converted = content;

        if (format === 'harlowe') {
            converted = this.convertHarloweToWhisker(converted);
        } else if (format === 'sugarcube') {
            converted = this.convertSugarCubeToWhisker(converted);
        }

        return converted;
    }

    /**
     * Convert Harlowe macros to Whisker syntax
     * @param {string} content - Harlowe content
     * @returns {string} Whisker content
     */
    static convertHarloweToWhisker(content) {
        let converted = content;

        // IMPORTANT: Convert macros FIRST (before variable conversion)
        // This allows macros to match $var syntax

        // Convert (set:) macros: (set: $var to value) -> {{lua: game_state:set("var", value)}}
        converted = converted.replace(
            /\(set:\s*\$(\w+)\s+to\s+([^\)]+)\)/gi,
            (match, varName, value) => {
                // Handle string values
                if (value.includes('"') || value.includes("'")) {
                    return `{{lua: game_state:set("${varName}", ${value})}}`;
                }
                // Handle numeric values
                return `{{lua: game_state:set("${varName}", ${value})}}`;
            }
        );

        // Convert (if:) macros: (if: $var)[content] -> {{#if var}}content{{/if}}
        converted = converted.replace(
            /\(if:\s*\$(\w+)\)\[([^\]]+)\]/g,
            '{{#if $1}}$2{{/if}}'
        );

        // Convert (else-if:) macros
        converted = converted.replace(
            /\(else-if:\s*\$(\w+)\)\[([^\]]+)\]/g,
            '{{else if $1}}$2'
        );

        // Convert (else:) macros
        converted = converted.replace(
            /\(else:\)\[([^\]]+)\]/g,
            '{{else}}$1'
        );

        // Convert (print:) macros: (print: $var) -> {{var}}
        converted = converted.replace(
            /\(print:\s*\$(\w+)\)/g,
            '{{$1}}'
        );

        // Convert remaining variable references: $var -> {{var}}
        // Do this LAST so macros can match $var first
        converted = converted.replace(/\$(\w+)/g, '{{$1}}');

        return converted;
    }

    /**
     * Convert SugarCube macros to Whisker syntax
     * @param {string} content - SugarCube content
     * @returns {string} Whisker content
     */
    static convertSugarCubeToWhisker(content) {
        let converted = content;

        // IMPORTANT: Convert macros FIRST (before variable conversion)
        // This allows macros to match $var syntax

        // Convert <<set>> macros: <<set $var to value>> -> {{lua: game_state:set("var", value)}}
        converted = converted.replace(
            /<<set\s+\$(\w+)\s+(?:to|=)\s+([^>]+)>>/gi,
            (match, varName, value) => {
                value = value.trim();
                return `{{lua: game_state:set("${varName}", ${value})}}`;
            }
        );

        // Convert <<if>> macros: <<if $var>>content<<endif>> -> {{#if var}}content{{/if}}
        converted = converted.replace(
            /<<if\s+\$(\w+)>>/gi,
            '{{#if $1}}'
        );

        converted = converted.replace(
            /<<elseif\s+\$(\w+)>>/gi,
            '{{else if $1}}'
        );

        converted = converted.replace(
            /<<else>>/gi,
            '{{else}}'
        );

        // Convert <<endif>> or <</if>> to {{/if}}
        converted = converted.replace(
            /<<\/?endif>>/gi,
            '{{/if}}'
        );
        converted = converted.replace(
            /<<\/if>>/gi,
            '{{/if}}'
        );

        // Convert <<print>> macros: <<print $var>> -> {{var}}
        converted = converted.replace(
            /<<print\s+\$(\w+)>>/gi,
            '{{$1}}'
        );

        // Convert remaining variable references: $var -> {{var}}
        // Do this LAST so macros can match $var first
        converted = converted.replace(/\$(\w+)/g, '{{$1}}');

        return converted;
    }

    /**
     * Extract variables from passages
     * @param {Array} passages - Parsed passages
     * @param {string} format - Story format
     * @returns {Object} Variables object
     */
    static extractVariables(passages, format) {
        const variables = {};
        const varPattern = /\{\{lua:\s*game_state:set\("(\w+)",\s*([^}]+)\)\}\}/g;

        passages.forEach(passage => {
            let match;
            while ((match = varPattern.exec(passage.content)) !== null) {
                const varName = match[1];
                const initialValue = match[2].trim();

                if (!variables[varName]) {
                    // Try to determine type
                    let value;
                    if (initialValue === 'true' || initialValue === 'false') {
                        value = initialValue === 'true';
                    } else if (!isNaN(initialValue) && initialValue !== '') {
                        value = parseFloat(initialValue);
                    } else {
                        // Remove quotes if present
                        value = initialValue.replace(/^["']|["']$/g, '');
                    }

                    variables[varName] = {
                        initial: value,
                        type: typeof value,
                        description: `Imported from Twine (${format})`
                    };
                }
            }
        });

        return variables;
    }

    /**
     * Generate Whisker-style passage IDs from Twine names
     * @param {string} name - Twine passage name
     * @returns {string} Whisker passage ID
     */
    static generatePassageId(name) {
        return name
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '_')
            .replace(/^_+|_+$/g, '')
            .substring(0, 50) // Limit length
            || 'passage_' + Math.random().toString(36).substr(2, 9);
    }

    /**
     * Detect Twine story format
     * @param {string} formatString - Format attribute value
     * @returns {string} Normalized format name
     */
    static detectFormat(formatString) {
        const lower = formatString.toLowerCase();

        if (lower.includes('harlowe')) return 'harlowe';
        if (lower.includes('sugarcube')) return 'sugarcube';
        if (lower.includes('snowman')) return 'snowman';
        if (lower.includes('chapbook')) return 'chapbook';

        return 'unknown';
    }

    /**
     * Decode HTML entities to get original Twine syntax
     * @param {string} html - HTML string with entities
     * @returns {string} Decoded string
     */
    static decodeHTMLEntities(html) {
        if (!html) return '';

        // Decode HTML entities only - do NOT use DOMParser as it will
        // parse << >> as HTML tags again!
        let decoded = html
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&amp;/g, '&')
            .replace(/&quot;/g, '"')
            .replace(/&#39;/g, "'")
            .replace(/&nbsp;/g, ' ');

        return decoded;
    }

    /**
     * Extract passage content from raw HTML before DOM parsing
     * This avoids jsdom mangling <<>> macros
     * @param {string} rawHTML - Original HTML string
     * @param {string} pid - Passage ID
     * @param {string} name - Passage name
     * @returns {string|null} Passage content or null if not found
     */
    static extractPassageContentFromRaw(rawHTML, pid, name) {
        if (!rawHTML) return null;

        // Try to find passage by pid first (more reliable)
        let regex = new RegExp(
            `<tw-passagedata[^>]*pid="${pid}"[^>]*>([\\s\\S]*?)<\\/tw-passagedata>`,
            'i'
        );
        let match = rawHTML.match(regex);

        if (!match) {
            // Fallback: try to find by name (escape special regex chars in name)
            const escapedName = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            regex = new RegExp(
                `<tw-passagedata[^>]*name="${escapedName}"[^>]*>([\\s\\S]*?)<\\/tw-passagedata>`,
                'i'
            );
            match = rawHTML.match(regex);
        }

        if (match && match[1]) {
            // Decode HTML entities in the extracted content
            return this.decodeHTMLEntities(match[1]);
        }

        return null;
    }

    /**
     * Generate IFID (Interactive Fiction ID)
     * @returns {string} UUID-style IFID
     */
    static generateIFID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16).toUpperCase();
        });
    }
}

// Make available globally
if (typeof window !== 'undefined') {
    window.TwineParser = TwineParser;
}
