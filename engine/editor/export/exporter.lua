-- whisker/src/editor/export/exporter.lua
-- Export Module for Multiple Formats

local Exporter = {}

function Exporter.new(project)
    return {
        project = project
    }
end

function Exporter:exportWhiskerJSON()
    local story = {
        format = "whisker",
        version = "1.0.0",
        metadata = self.project.metadata,
        variables = self.project.variables,
        passages = self.project.passages,
        startPassage = self.project.startPassage
    }

    local json = require('json')
    return json.encode(story, {indent = true})
end

function Exporter:exportHTML()
    local html = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>]] .. self.project.metadata.title .. [[</title>
    <style>
        body {
            font-family: Georgia, serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background: #f5f5f5;
            color: #333;
        }
        .passage {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        h1 { margin-bottom: 20px; color: #2c3e50; }
        .choices { margin-top: 20px; }
        .choice {
            display: block;
            margin: 10px 0;
            padding: 12px 20px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background 0.3s;
        }
        .choice:hover { background: #2980b9; }
        .variables {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 20px;
            padding: 10px;
            background: #ecf0f1;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div id="story"></div>
    <script>
        const story = ]] .. self:exportWhiskerJSON() .. [[;
        let variables = {};
        let currentPassage = story.startPassage;

        // Initialize variables
        for (let varName in story.variables) {
            variables[varName] = story.variables[varName].initial;
        }

        function showPassage(passageId) {
            const passage = story.passages.find(p => p.id === passageId);
            if (!passage) return;

            currentPassage = passageId;

            // Execute passage script
            if (passage.script) {
                try {
                    eval(passage.script);
                } catch (e) {
                    console.error('Script error:', e);
                }
            }

            // Render passage
            let html = `<div class="passage">`;
            html += `<h1>${passage.title}</h1>`;
            html += `<div>${processContent(passage.content)}</div>`;

            // Render choices
            if (passage.choices.length > 0) {
                html += `<div class="choices">`;
                passage.choices.forEach((choice, idx) => {
                    // Check condition
                    let show = true;
                    if (choice.condition) {
                        try {
                            show = eval(choice.condition);
                        } catch (e) {
                            console.error('Condition error:', e);
                        }
                    }

                    if (show) {
                        html += `<a href="#" class="choice" onclick="makeChoice(${idx}); return false;">${choice.text}</a>`;
                    }
                });
                html += `</div>`;
            }

            // Show variables (debug)
            html += `<div class="variables">Variables: ${JSON.stringify(variables)}</div>`;
            html += `</div>`;

            document.getElementById('story').innerHTML = html;
        }

        function makeChoice(choiceIdx) {
            const passage = story.passages.find(p => p.id === currentPassage);
            const choice = passage.choices[choiceIdx];

            if (choice.script) {
                try {
                    eval(choice.script);
                } catch (e) {
                    console.error('Choice script error:', e);
                }
            }

            if (choice.target) {
                showPassage(choice.target);
            }
        }

        function processContent(text) {
            // Simple variable replacement
            return text.replace(/\$(\w+)/g, (match, varName) => {
                return variables[varName] !== undefined ? variables[varName] : match;
            });
        }

        // Start story
        showPassage(story.startPassage);
    </script>
</body>
</html>
]]
    return html
end

function Exporter:exportMarkdown()
    local md = "# " .. self.project.metadata.title .. "\n\n"
    md = md .. "**Author:** " .. self.project.metadata.author .. "\n\n"
    md = md .. "---\n\n"

    for _, passage in ipairs(self.project.passages) do
        md = md .. "## " .. passage.title
        if passage.id == self.project.startPassage then
            md = md .. " (START)"
        end
        md = md .. "\n\n"

        if #passage.tags > 0 then
            md = md .. "*Tags: " .. table.concat(passage.tags, ", ") .. "*\n\n"
        end

        md = md .. passage.content .. "\n\n"

        if #passage.choices > 0 then
            md = md .. "**Choices:**\n\n"
            for _, choice in ipairs(passage.choices) do
                local targetPassage = self.project:getPassage(choice.target)
                local targetTitle = targetPassage and targetPassage.title or "???"
                md = md .. "- " .. choice.text .. " → " .. targetTitle
                if choice.condition and choice.condition ~= "" then
                    md = md .. " *[if " .. choice.condition .. "]*"
                end
                md = md .. "\n"
            end
        end

        md = md .. "\n---\n\n"
    end

    return md
end

return Exporter