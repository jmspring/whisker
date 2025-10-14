#!/usr/bin/env node
/**
 * Sync Player Code to RuntimeTemplate
 * Reads lua-whisker-player.js and updates RuntimeTemplate's embedded code
 */

const fs = require('fs');
const path = require('path');

console.log('Syncing LuaWhiskerPlayer code to RuntimeTemplate...\n');

// Read the fixed lua-whisker-player.js
const playerPath = path.join(__dirname, '../../../src/runtime/lua-whisker-player.js');
const playerContent = fs.readFileSync(playerPath, 'utf8');

// Extract just the class code (remove header comment and module.exports)
const lines = playerContent.split('\n');

// Find where class starts (after the header comment)
let classStart = 0;
for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('class LuaWhiskerPlayer')) {
        classStart = i;
        break;
    }
}

// Find where class ends (before module.exports)
let classEnd = lines.length;
for (let i = lines.length - 1; i >= 0; i--) {
    if (lines[i].includes('}') && !lines[i].includes('module.exports')) {
        // Find the closing brace of the class
        if (i > classStart + 10) { // Make sure it's not an early brace
            classEnd = i + 1;
            break;
        }
    }
}

// Extract class code
const classCode = lines.slice(classStart, classEnd).join('\n');

console.log(`Extracted ${classEnd - classStart} lines of class code`);
console.log(`Class starts at line ${classStart + 1}, ends at line ${classEnd}`);

// Escape the code for embedding in a template literal
// We need to escape backticks and ${ }
const escapedCode = classCode
    .replace(/\\/g, '\\\\')      // Escape backslashes first
    .replace(/`/g, '\\`')          // Escape backticks
    .replace(/\${/g, '\\${');      // Escape template literal syntax

// Read RuntimeTemplate
const templatePath = path.join(__dirname, 'runtime-template.js');
const templateContent = fs.readFileSync(templatePath, 'utf8');

// Find the getLuaWhiskerPlayerCode method and replace its content
const methodStart = templateContent.indexOf('static getLuaWhiskerPlayerCode()');
if (methodStart === -1) {
    console.error('❌ Could not find getLuaWhiskerPlayerCode method in RuntimeTemplate');
    process.exit(1);
}

// Find the closing of this method (look for the next method)
const methodEnd = templateContent.indexOf('\n    /**', methodStart + 50);
if (methodEnd === -1) {
    console.error('❌ Could not find end of getLuaWhiskerPlayerCode method');
    process.exit(1);
}

// Create the new method content
const newMethodContent = `static getLuaWhiskerPlayerCode() {
        // AUTO-GENERATED: Synced from lua-whisker-player.js
        // DO NOT EDIT MANUALLY - Run sync-player-code.js to update
        return \`
${escapedCode}\`;
    }`;

// Replace the method
const newTemplateContent =
    templateContent.substring(0, methodStart) +
    newMethodContent +
    templateContent.substring(methodEnd);

// Write back to RuntimeTemplate
fs.writeFileSync(templatePath, newTemplateContent, 'utf8');

console.log('\n✅ Successfully synced player code to RuntimeTemplate');
console.log(`✅ Updated ${templatePath}`);
console.log('\nTo apply fixes, run: node editor/web/js/sync-player-code.js');
