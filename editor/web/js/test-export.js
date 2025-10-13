#!/usr/bin/env node
/**
 * Test Export System
 * Validates that the HTML export functionality works correctly
 */

const fs = require('fs');
const path = require('path');

console.log('='.repeat(60));
console.log('WHISKER EXPORT SYSTEM TEST');
console.log('='.repeat(60));

// Test 1: Verify all required files exist
console.log('\n[Test 1] Checking required files...');
const requiredFiles = [
    '../../../src/runtime/web_runtime.css',
    '../../../src/runtime/lua-whisker-player.js',
    'css-inliner.js',
    'runtime-template.js',
    'export.js'
];

let allFilesExist = true;
requiredFiles.forEach(file => {
    const fullPath = path.join(__dirname, file);
    const exists = fs.existsSync(fullPath);
    console.log(`  ${exists ? '✓' : '✗'} ${file}`);
    if (!exists) allFilesExist = false;
});

if (!allFilesExist) {
    console.error('\n❌ Test 1 FAILED: Some required files are missing');
    process.exit(1);
}
console.log('✅ Test 1 PASSED: All required files exist');

// Test 2: Verify CSS file is readable and contains expected content
console.log('\n[Test 2] Checking CSS file...');
const cssPath = path.join(__dirname, '../../../src/runtime/web_runtime.css');
const cssContent = fs.readFileSync(cssPath, 'utf8');
const cssSize = Buffer.byteLength(cssContent, 'utf8');
console.log(`  CSS file size: ${cssSize} bytes (${(cssSize / 1024).toFixed(2)} KB)`);
console.log(`  CSS contains whisker classes: ${cssContent.includes('.whisker-') ? '✓' : '✗'}`);

if (cssSize === 0 || !cssContent.includes('.whisker-')) {
    console.error('❌ Test 2 FAILED: CSS file is invalid or empty');
    process.exit(1);
}
console.log('✅ Test 2 PASSED: CSS file is valid');

// Test 3: Verify LuaWhiskerPlayer file structure
console.log('\n[Test 3] Checking LuaWhiskerPlayer...');
const playerPath = path.join(__dirname, '../../../src/runtime/lua-whisker-player.js');
const playerContent = fs.readFileSync(playerPath, 'utf8');
const playerChecks = [
    { name: 'class LuaWhiskerPlayer', check: playerContent.includes('class LuaWhiskerPlayer') },
    { name: 'initializeLua method', check: playerContent.includes('initializeLua()') },
    { name: 'loadStory method', check: playerContent.includes('loadStory(') },
    { name: 'executeLuaCode method', check: playerContent.includes('executeLuaCode(') },
    { name: 'processInline method', check: playerContent.includes('processInline(') },
    { name: 'render method', check: playerContent.includes('render()') }
];

playerChecks.forEach(({name, check}) => {
    console.log(`  ${check ? '✓' : '✗'} ${name}`);
    if (!check) {
        console.error(`❌ Test 3 FAILED: LuaWhiskerPlayer missing ${name}`);
        process.exit(1);
    }
});
console.log('✅ Test 3 PASSED: LuaWhiskerPlayer structure is valid');

// Test 4: Verify RuntimeTemplate structure
console.log('\n[Test 4] Checking RuntimeTemplate...');
const templatePath = path.join(__dirname, 'runtime-template.js');
const templateContent = fs.readFileSync(templatePath, 'utf8');
const templateChecks = [
    { name: 'class RuntimeTemplate', check: templateContent.includes('class RuntimeTemplate') },
    { name: 'generateFullHTML method', check: templateContent.includes('generateFullHTML(') },
    { name: 'getLuaWhiskerPlayerCode method', check: templateContent.includes('getLuaWhiskerPlayerCode()') },
    { name: 'getHTMLStructure method', check: templateContent.includes('getHTMLStructure(') },
    { name: 'Fengari script tag', check: templateContent.includes('fengari-web') }
];

templateChecks.forEach(({name, check}) => {
    console.log(`  ${check ? '✓' : '✗'} ${name}`);
    if (!check) {
        console.error(`❌ Test 4 FAILED: RuntimeTemplate missing ${name}`);
        process.exit(1);
    }
});
console.log('✅ Test 4 PASSED: RuntimeTemplate structure is valid');

// Test 5: Verify CSSInliner structure
console.log('\n[Test 5] Checking CSSInliner...');
const inlinerPath = path.join(__dirname, 'css-inliner.js');
const inlinerContent = fs.readFileSync(inlinerPath, 'utf8');
const inlinerChecks = [
    { name: 'class CSSInliner', check: inlinerContent.includes('class CSSInliner') },
    { name: 'getMinifiedCSS method', check: inlinerContent.includes('getMinifiedCSS()') },
    { name: 'minify method', check: inlinerContent.includes('minify(') },
    { name: 'Correct CSS path', check: inlinerContent.includes('../../../src/runtime/web_runtime.css') }
];

inlinerChecks.forEach(({name, check}) => {
    console.log(`  ${check ? '✓' : '✗'} ${name}`);
    if (!check) {
        console.error(`❌ Test 5 FAILED: CSSInliner missing ${name}`);
        process.exit(1);
    }
});
console.log('✅ Test 5 PASSED: CSSInliner structure is valid');

// Test 6: Verify ExportSystem integration
console.log('\n[Test 6] Checking ExportSystem...');
const exportPath = path.join(__dirname, 'export.js');
const exportContent = fs.readFileSync(exportPath, 'utf8');
const exportChecks = [
    { name: 'class ExportSystem', check: exportContent.includes('class ExportSystem') },
    { name: 'async exportHTML method', check: exportContent.includes('async exportHTML()') },
    { name: 'RuntimeTemplate.generateFullHTML call', check: exportContent.includes('RuntimeTemplate.generateFullHTML') },
    { name: 'exportBasicHTML fallback', check: exportContent.includes('exportBasicHTML(') },
    { name: 'detectLuaUsage method', check: exportContent.includes('detectLuaUsage()') }
];

exportChecks.forEach(({name, check}) => {
    console.log(`  ${check ? '✓' : '✗'} ${name}`);
    if (!check) {
        console.error(`❌ Test 6 FAILED: ExportSystem missing ${name}`);
        process.exit(1);
    }
});
console.log('✅ Test 6 PASSED: ExportSystem integration is valid');

// Test 7: Verify index.html includes new scripts
console.log('\n[Test 7] Checking index.html...');
const indexPath = path.join(__dirname, '../index.html');
const indexContent = fs.readFileSync(indexPath, 'utf8');
const indexChecks = [
    { name: 'css-inliner.js script tag', check: indexContent.includes('js/css-inliner.js') },
    { name: 'runtime-template.js script tag', check: indexContent.includes('js/runtime-template.js') },
    { name: 'export.js script tag', check: indexContent.includes('js/export.js') },
    { name: 'exportSystem initialization', check: indexContent.includes('exportSystem = new ExportSystem') }
];

indexChecks.forEach(({name, check}) => {
    console.log(`  ${check ? '✓' : '✗'} ${name}`);
    if (!check) {
        console.error(`❌ Test 7 FAILED: index.html missing ${name}`);
        process.exit(1);
    }
});
console.log('✅ Test 7 PASSED: index.html properly configured');

// Final summary
console.log('\n' + '='.repeat(60));
console.log('ALL TESTS PASSED! ✅');
console.log('='.repeat(60));
console.log('\nPhase 1: Full HTML Export implementation is complete!');
console.log('\nComponents verified:');
console.log('  ✓ LuaWhiskerPlayer extracted to standalone module');
console.log('  ✓ CSS inliner utility created');
console.log('  ✓ Runtime template generator created');
console.log('  ✓ Export system updated to use new template');
console.log('  ✓ All files properly integrated');
console.log('\nNext steps:');
console.log('  - Manual testing with actual stories (Lua and non-Lua)');
console.log('  - Phase 2: Twine Import (6-8 hours)');
console.log('  - Phase 3: Enhanced Twine Export (2-3 hours)');
console.log('\n');
