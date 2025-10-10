# Whisker Story Editor - Workflow Guide

## Complete Workflow: From Template to Export

This guide explains the complete workflow for creating and exporting a story using the Whisker Story Editor.

## Step-by-Step Workflow

### 1. Open the Editor

Open `editor/web/index.html` in your web browser (preferably Chrome, Firefox, or Safari).

### 2. Create a Project

You have three options to start:

#### Option A: Use a Template (Recommended for Beginners)
1. Click the **"New from Template"** button in the toolbar
2. Choose from available templates:
   - **Blank Story**: Single empty passage
   - **Simple Choice**: Basic branching story (4 passages)
   - **Complex Story**: Multi-branch story (8 passages)
   - **Game Template**: RPG-style with variables (6 passages)
   - **Quiz/Survey**: Question and answer format (5 passages)
   - **Interactive Tutorial**: Step-by-step structure (6 passages)
3. Enter a title for your story when prompted
4. The editor will load with your template

#### Option B: Create New Project
1. Click the **"New Project"** button
2. Enter a project title
3. Start with a single "Start" passage

#### Option C: Open Existing Project
1. Click the **"Open"** button
2. Select a `.whisker` or `.json` file from your computer

### 3. Edit Your Story

Once you have a project loaded:

#### Edit Passages
1. Click on a passage in the **left sidebar** to select it
2. Edit the **title** and **content** in the main editor
3. Use the **rich text toolbar** for formatting:
   - **B**: Bold text (`**text**`)
   - **I**: Italic text (`_text_`)
   - **</>**: Code (`\`code\``)
   - **H1/H2**: Headings
   - **List**: Create lists
   - **Link**: Add links

#### Add Choices
1. With a passage selected, scroll to the **Choices** section
2. Click **"+ Add Choice"**
3. Enter the choice text
4. Select the target passage from the dropdown
5. Repeat for additional choices

#### Add New Passages
1. Click **"+ Add"** button in the passage list
2. Enter a passage title
3. Edit the new passage content

#### Use Variables (Optional)
1. Open the **Variables panel** on the right
2. Click **"+ Add Variable"**
3. Define variable name, type (number/string/boolean), and initial value
4. Insert variables in passage content using `{{variableName}}`

### 4. View Your Story

You can view your story in two ways:

#### Graph View
- Click the **"Graph"** button at the top of the editor
- See a visual representation of your story structure
- Zoom, pan, and auto-layout available

#### Preview Panel
- Located on the right side
- Shows how the current passage will look to players
- Click choices to navigate through the story
- Click **"Restart"** to go back to the beginning

### 5. Export Your Story

**IMPORTANT**: You must have a project loaded before exporting!

1. **Verify you have a project loaded**:
   - You should see passages in the left sidebar
   - The editor panel should show passage content
   - If you see "Welcome to Whisker" screen, you don't have a project loaded yet

2. **Click the "Export ▾" button** in the toolbar

3. **Choose an export format**:
   - **Whisker JSON**: Standard format for web players
   - **Standalone HTML**: Self-contained HTML file (opens in any browser)
   - **Whisker Project**: Complete project file (can reopen in editor)
   - **Markdown**: Text-based documentation format
   - **Twine HTML**: Import into Twine 2

4. **Configure export options** (vary by format):
   - Include metadata
   - Include variables
   - Minify output
   - etc.

5. **Click the "Export" button**

6. **Your file will download automatically**

### 6. Save Your Work

To save your project for later editing:

1. Click the **"Save"** button in the toolbar
2. A `.whisker` file will download
3. You can reopen this file later using the **"Open"** button

## Troubleshooting Export Issues

### Export Button Does Nothing

**Check these items**:

1. **Do you have a project loaded?**
   - Look at the left sidebar - do you see passages?
   - If you see the welcome screen, create or open a project first

2. **Open Browser Console** (Press F12):
   - Look for error messages in red
   - Common errors:
     - "No project to export" → Create a project first
     - "Export modal not found" → Refresh the page
     - Other JavaScript errors → Report as a bug

3. **Try creating a simple project**:
   - Click "New Project"
   - Enter a title
   - Add one passage
   - Try exporting again

4. **Test with the test file**:
   - Open `editor/web/test_export.html` in your browser
   - Click "Test Export"
   - This verifies the export system works

### Export Format Not Working

- **Standalone HTML**: This creates a playable HTML file that works in any browser
- **Whisker JSON**: Use this with the web runtime players in `examples/web_runtime/`
- **Whisker Project**: This is for saving your work to reopen later

## Tips and Best Practices

1. **Save Often**: Use the "Save" button frequently to save your work as a `.whisker` file

2. **Use Templates**: Templates provide good starting structures that you can modify

3. **Test Your Story**: Use the Preview panel to test your story flow

4. **Organize Passages**: Give passages descriptive titles for easier navigation

5. **Use Variables**: For game mechanics, scores, or tracking player choices

6. **Export Multiple Formats**: 
   - Export as Whisker Project to continue editing later
   - Export as Standalone HTML to share with others

## Keyboard Shortcuts

- **Ctrl+Z**: Undo
- **Ctrl+Shift+Z**: Redo

## Need Help?

1. Check the browser console (F12) for error messages
2. Try the test file: `editor/web/test_export.html`
3. Open an issue on GitHub: https://github.com/jmspring/whisker/issues

## Example Workflow

Here's a complete example:

```
1. Open editor/web/index.html
2. Click "New from Template"
3. Choose "Simple Choice"
4. Enter title: "My Adventure"
5. Edit passages in the sidebar
6. Modify content and choices
7. Preview your story in the Preview panel
8. Click "Export ▾"
9. Select "Standalone HTML"
10. Click "Export"
11. Open the downloaded HTML file in your browser to play!
```

Your story is now ready to share with others!
