// passage-templates.js
// System for inserting reusable passage templates

class PassageTemplateSystem {
    constructor(editor) {
        this.editor = editor;
        this.templates = this.getBuiltInTemplates();
    }

    initialize() {
        console.log('[PassageTemplates] Initializing passage template system');
        this.loadCustomTemplates();
    }

    getBuiltInTemplates() {
        return {
            // Basic Templates
            'basic_choice': {
                name: 'Basic Choice',
                category: 'Basic',
                description: 'Simple branching passage with two choices',
                icon: '🔀',
                content: `You face a decision.

What will you do?

[[Option A->passage_a]]
[[Option B->passage_b]]`
            },

            'descriptive': {
                name: 'Descriptive Scene',
                category: 'Basic',
                description: 'Rich description with continue option',
                icon: '📝',
                content: `**[Scene Title]**

[Describe the environment, atmosphere, and important details here.]

[Add sensory details - what does the character see, hear, smell?]

[[Continue->next_passage]]`
            },

            // RPG Templates
            'combat_basic': {
                name: 'Basic Combat',
                category: 'RPG',
                description: 'Simple combat encounter with choices',
                icon: '⚔️',
                content: `**Combat: [Enemy Name]**

You face a [enemy description]. The creature notices you and prepares to attack!

**Your Health:** {{health}}/{{max_health}}
**Enemy Health:** [enemy_hp]

What do you do?

[[Attack->combat_attack]]
[[Defend->combat_defend]]
{{#if has_healing_potion}}[[Use Healing Potion->combat_heal]]{{/if}}
[[Try to flee->combat_flee]]`
            },

            'combat_advanced': {
                name: 'Advanced Combat',
                category: 'RPG',
                description: 'Combat with class abilities and stamina',
                icon: '⚔️',
                content: `**Combat: [Enemy Name]**

[Enemy description and tactics]

**Your Stats:**
- Health: {{health}}/{{max_health}}
- Stamina: {{stamina}}/{{max_stamina}}

**Enemy Stats:**
- Health: [enemy_hp]/[enemy_max_hp]
- Attack: [enemy_attack]

**Actions:**
[[Normal Attack->combat_normal]]
{{#if stamina >= 3 and class == "Fighter"}}[[Power Strike (3 stamina)->combat_power]]{{/if}}
{{#if stamina >= 2 and class == "Rogue"}}[[Sneak Attack (2 stamina)->combat_sneak]]{{/if}}
{{#if stamina >= 3 and class == "Cleric"}}[[Heal Self (3 stamina)->combat_heal_self]]{{/if}}
{{#if stamina >= 3 and class == "Mage"}}[[Magic Missile (3 stamina)->combat_magic]]{{/if}}
[[Defend->combat_defend]]`
            },

            'skill_check': {
                name: 'Skill Check',
                category: 'RPG',
                description: 'D20 skill check with pass/fail branches',
                icon: '🎲',
                content: `**[Skill Challenge Title]**

[Describe the challenge and what the character must do]

{{lua: local roll = math.random(1,20); local skill_bonus = game_state:get("skill_[skillname]") or 0; local total = roll + skill_bonus; game_state:set("last_roll", total) }}

You rolled: {{last_roll}}
Difficulty: [DC number]

{{#if last_roll >= [DC]}}
**Success!** [Describe successful outcome]
[[Continue->success_passage]]
{{else}}
**Failure.** [Describe failure outcome]
[[Continue->failure_passage]]
{{/if}}`
            },

            'level_up': {
                name: 'Level Up',
                category: 'RPG',
                description: 'Character level up with stat increases',
                icon: '⬆️',
                content: `**LEVEL UP!**

Congratulations! You've reached level {{level + 1}}!

**Benefits:**
- Max HP +[amount]
- Max Stamina +2
- +1 Skill Point
- Choose 2 attributes to increase by +1

{{lua:
    game_state:set("level", game_state:get("level") + 1);
    game_state:set("max_health", game_state:get("max_health") + [hp_gain]);
    game_state:set("health", game_state:get("max_health"));
    game_state:set("max_stamina", game_state:get("max_stamina") + 2);
    game_state:set("stamina", game_state:get("max_stamina"));
    game_state:set("skill_points", game_state:get("skill_points") + 1);
    game_state:set("experience", 0)
}}

**Choose your stat increases:**

[[Strength + Constitution->level_str_con]]
[[Dexterity + Wisdom->level_dex_wis]]
[[Intelligence + Charisma->level_int_cha]]`
            },

            'merchant': {
                name: 'Merchant/Shop',
                category: 'RPG',
                description: 'Shop with items to buy',
                icon: '🛒',
                content: `**[Merchant Name]'s Shop**

"[Merchant greeting dialogue]"

**Available Items:**
- [Item 1] ([cost] gold) {{#if has_[item1]}}✓ OWNED{{/if}}
- [Item 2] ([cost] gold) {{#if has_[item2]}}✓ OWNED{{/if}}
- [Item 3] ([cost] gold) {{#if has_[item3]}}✓ OWNED{{/if}}

**Your Gold:** {{gold}}

{{#if gold >= [cost] and not has_[item1]}}[[Buy [Item 1]->buy_item1]]{{/if}}
{{#if gold >= [cost] and not has_[item2]}}[[Buy [Item 2]->buy_item2]]{{/if}}
{{#if gold >= [cost] and not has_[item3]}}[[Buy [Item 3]->buy_item3]]{{/if}}
[[Leave->previous_location]]`
            },

            'loot': {
                name: 'Find Loot',
                category: 'RPG',
                description: 'Discover treasure or items',
                icon: '💎',
                content: `**[Location] - Search**

You search the area carefully...

{{#if skill_perception >= [required]}}
**Found:**
- [amount] gold
- [item name]
- [item name]

{{lua:
    game_state:set("gold", game_state:get("gold") + [amount]);
    game_state:set("has_[item]", true)
}}

Your keen perception reveals hidden treasures!
{{else}}
You find [smaller amount] gold, but nothing else of note.

{{lua: game_state:set("gold", game_state:get("gold") + [amount]) }}
{{/if}}

[[Continue->next_passage]]`
            },

            // Dialogue Templates
            'dialogue_branch': {
                name: 'Dialogue Branch',
                category: 'Dialogue',
                description: 'NPC conversation with multiple responses',
                icon: '💬',
                content: `**[NPC Name]**

"[NPC dialogue line]"

How do you respond?

[[Response 1->dialogue_option1]]
[[Response 2->dialogue_option2]]
[[Response 3->dialogue_option3]]
{{#if skill_persuasion >= 3}}[[Persuade them->dialogue_persuade]]{{/if}}
[[Say nothing->dialogue_silent]]`
            },

            'persuasion_check': {
                name: 'Persuasion Check',
                category: 'Dialogue',
                description: 'Persuasion attempt with skill check',
                icon: '🗣️',
                content: `**Attempting to Persuade [NPC Name]**

You make your case...

{{lua:
    local roll = math.random(1,20);
    local persuasion = game_state:get("skill_persuasion") or 0;
    local charisma_mod = math.floor((game_state:get("charisma") - 10) / 2);
    local total = roll + persuasion + charisma_mod;
    game_state:set("persuasion_result", total)
}}

Roll: {{persuasion_result}} (DC [difficulty])

{{#if persuasion_result >= [difficulty]}}
**Success!** [NPC is persuaded]
[[Continue->persuasion_success]]
{{else}}
**Failure.** [NPC is not convinced]
[[Continue->persuasion_failure]]
{{/if}}`
            },

            'quest_accept': {
                name: 'Accept Quest',
                category: 'Quests',
                description: 'NPC offers a quest',
                icon: '📜',
                content: `**[Quest Giver Name]**

"[Quest description and motivation]"

**Quest Objective:** [objective]
**Reward:** [reward]

{{lua: game_state:set("quest_[questname]", "active") }}

[[Accept the quest->quest_accepted]]
[[Decline->quest_declined]]`
            },

            'quest_complete': {
                name: 'Complete Quest',
                category: 'Quests',
                description: 'Turn in completed quest',
                icon: '✅',
                content: `**Quest Complete: [Quest Name]**

[Quest giver responds to your success]

**Rewards:**
- [amount] gold
- [amount] XP
- [item reward]

{{lua:
    game_state:set("quest_[questname]", "complete");
    game_state:set("gold", game_state:get("gold") + [amount]);
    game_state:set("experience", game_state:get("experience") + [xp]);
    game_state:set("has_[reward_item]", true)
}}

[[Continue->next_passage]]`
            },

            // Conditional Templates
            'conditional_path': {
                name: 'Conditional Path',
                category: 'Logic',
                description: 'Different paths based on variable',
                icon: '🔀',
                content: `**[Passage Title]**

[Shared description]

{{#if [condition]}}
[Text if condition is true]
[[Continue->path_a]]
{{else}}
[Text if condition is false]
[[Continue->path_b]]
{{/if}}`
            },

            'variable_check': {
                name: 'Variable Check',
                category: 'Logic',
                description: 'Multiple conditions with different outcomes',
                icon: '🔍',
                content: `**[Passage Title]**

[Description]

{{#if [condition1]}}
[Outcome 1]
[[Continue->outcome1]]
{{else if [condition2]}}
[Outcome 2]
[[Continue->outcome2]]
{{else if [condition3]}}
[Outcome 3]
[[Continue->outcome3]]
{{else}}
[Default outcome]
[[Continue->default]]
{{/if}}`
            },

            'timed_event': {
                name: 'Timed Event',
                category: 'Advanced',
                description: 'Track time or turns',
                icon: '⏱️',
                content: `**[Location/Scene]**

[Description]

{{lua:
    local turns = game_state:get("turn_counter") or 0;
    game_state:set("turn_counter", turns + 1)
}}

Time passed: {{turn_counter}} turns

{{#if turn_counter >= [threshold]}}
[Something happens after time passes]
[[React->timed_event_trigger]]
{{else}}
[Normal options]
[[Continue->next_passage]]
{{/if}}`
            },

            'random_encounter': {
                name: 'Random Encounter',
                category: 'Advanced',
                description: 'Random event with different outcomes',
                icon: '🎲',
                content: `**Random Encounter**

{{lua:
    local roll = math.random(1,100);
    game_state:set("encounter_roll", roll)
}}

{{#if encounter_roll <= 25}}
[Encounter type 1]
[[Deal with it->encounter1]]
{{else if encounter_roll <= 50}}
[Encounter type 2]
[[Deal with it->encounter2]]
{{else if encounter_roll <= 75}}
[Encounter type 3]
[[Deal with it->encounter3]]
{{else}}
Nothing happens. The path is quiet.
[[Continue->next_passage]]
{{/if}}`
            },

            // Exploration Templates
            'locked_door': {
                name: 'Locked Door',
                category: 'Exploration',
                description: 'Door requiring key or lockpicking',
                icon: '🔒',
                content: `**Locked Door**

You find a sturdy door blocking your path. It's locked.

{{#if has_[key]}}
You have the key!
[[Unlock the door->door_unlocked]]
{{else if skill_lockpicking >= 2}}
[[Pick the lock->attempt_lockpick]]
{{/if}}
[[Force the door->force_door]]
[[Leave it alone->previous_passage]]`
            },

            'treasure_chest': {
                name: 'Treasure Chest',
                category: 'Exploration',
                description: 'Chest with possible trap',
                icon: '📦',
                content: `**Treasure Chest**

You discover a chest!

{{#if skill_perception >= 3}}
[You notice it might be trapped]
[[Carefully open->open_carefully]]
[[Attempt to disarm trap->disarm_trap]]
{{else}}
[[Open the chest->open_chest]]
{{/if}}
[[Leave it alone->leave_chest]]`
            },

            'rest_point': {
                name: 'Rest/Camp',
                category: 'Exploration',
                description: 'Safe place to rest and recover',
                icon: '🏕️',
                content: `**[Rest Location]**

You find a safe place to rest.

**Current Status:**
- Health: {{health}}/{{max_health}}
- Stamina: {{stamina}}/{{max_stamina}}

{{#if health < max_health or stamina < max_stamina}}
[[Rest and recover->rest_recover]]
{{/if}}
[[Continue without resting->continue_journey]]

{{lua:
function rest_recover()
    game_state:set("health", game_state:get("max_health"));
    game_state:set("stamina", game_state:get("max_stamina"))
end
}}`
            }
        };
    }

    showDialog() {
        const modal = this.createTemplateDialog();
        document.body.appendChild(modal);
        modal.classList.remove('hidden');
    }

    hideDialog() {
        const modal = document.getElementById('passageTemplateModal');
        if (modal) {
            modal.classList.add('hidden');
            setTimeout(() => modal.remove(), 300);
        }
    }

    createTemplateDialog() {
        const modal = document.createElement('div');
        modal.id = 'passageTemplateModal';
        modal.className = 'templates-modal';
        modal.innerHTML = `
            <div class="templates-dialog" style="max-width: 900px;">
                <div class="templates-dialog-header">
                    <h2>Insert Passage Template</h2>
                    <button class="close-modal" onclick="passageTemplates.hideDialog()">×</button>
                </div>
                <div class="passage-template-filter" style="padding: 15px; border-bottom: 1px solid var(--border-color);">
                    <input type="text" id="templateSearch" placeholder="Search templates..."
                           style="width: 100%; padding: 8px; border: 1px solid var(--border-color); border-radius: 4px;"
                           oninput="passageTemplates.filterTemplates(this.value)">
                </div>
                <div class="templates-content" style="max-height: 500px; overflow-y: auto;">
                    <div class="passage-template-categories" id="templateCategories">
                        ${this.renderTemplateCategories()}
                    </div>
                </div>
            </div>
        `;
        return modal;
    }

    renderTemplateCategories() {
        const categories = {};

        // Group templates by category
        Object.entries(this.templates).forEach(([id, template]) => {
            if (!categories[template.category]) {
                categories[template.category] = [];
            }
            categories[template.category].push({ id, ...template });
        });

        // Render each category
        return Object.entries(categories).map(([category, templates]) => `
            <div class="template-category" data-category="${category}">
                <h3 style="padding: 15px; margin: 0; background: var(--bg-tertiary); border-bottom: 1px solid var(--border-color);">
                    ${category}
                </h3>
                <div class="template-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 15px; padding: 15px;">
                    ${templates.map(t => this.renderTemplateCard(t)).join('')}
                </div>
            </div>
        `).join('');
    }

    renderTemplateCard(template) {
        return `
            <div class="template-card"
                 data-template-id="${template.id}"
                 onclick="passageTemplates.insertTemplate('${template.id}')"
                 style="
                     border: 1px solid var(--border-color);
                     border-radius: 8px;
                     padding: 15px;
                     cursor: pointer;
                     transition: all 0.2s;
                     background: var(--bg-secondary);
                 "
                 onmouseover="this.style.borderColor='var(--accent-color)'; this.style.transform='translateY(-2px)'"
                 onmouseout="this.style.borderColor='var(--border-color)'; this.style.transform='translateY(0)'">
                <div style="font-size: 32px; margin-bottom: 10px;">${template.icon}</div>
                <h4 style="margin: 0 0 8px 0;">${template.name}</h4>
                <p style="font-size: 13px; color: var(--text-secondary); margin: 0;">
                    ${template.description}
                </p>
            </div>
        `;
    }

    filterTemplates(searchTerm) {
        const categories = document.querySelectorAll('.template-category');
        const term = searchTerm.toLowerCase();

        categories.forEach(category => {
            const cards = category.querySelectorAll('.template-card');
            let visibleCount = 0;

            cards.forEach(card => {
                const templateId = card.dataset.templateId;
                const template = this.templates[templateId];
                const matches =
                    template.name.toLowerCase().includes(term) ||
                    template.description.toLowerCase().includes(term) ||
                    template.category.toLowerCase().includes(term);

                card.style.display = matches ? 'block' : 'none';
                if (matches) visibleCount++;
            });

            // Hide category if no visible cards
            category.style.display = visibleCount > 0 ? 'block' : 'none';
        });
    }

    insertTemplate(templateId) {
        const template = this.templates[templateId];
        if (!template) return;

        // Get current passage content
        const contentArea = document.getElementById('passageContent');
        if (!contentArea) return;

        // Insert template at cursor position or append
        const cursorPos = contentArea.selectionStart;
        const textBefore = contentArea.value.substring(0, cursorPos);
        const textAfter = contentArea.value.substring(cursorPos);

        // Add newlines for spacing
        const prefix = textBefore && !textBefore.endsWith('\n') ? '\n\n' : '';
        const suffix = textAfter && !textAfter.startsWith('\n') ? '\n\n' : '';

        contentArea.value = textBefore + prefix + template.content + suffix + textAfter;

        // Update the editor
        if (this.editor && this.editor.updateCurrentPassage) {
            this.editor.updateCurrentPassage();
        }

        // Close dialog
        this.hideDialog();

        // Focus back on content area and position cursor
        contentArea.focus();
        const newPos = cursorPos + prefix.length + template.content.length;
        contentArea.setSelectionRange(newPos, newPos);

        // Show success message
        if (this.editor && this.editor.setStatus) {
            this.editor.setStatus(`Inserted template: ${template.name}`);
        }
    }

    loadCustomTemplates() {
        // Load custom templates from localStorage
        try {
            const custom = localStorage.getItem('whisker_custom_passage_templates');
            if (custom) {
                const customTemplates = JSON.parse(custom);
                Object.assign(this.templates, customTemplates);
                console.log('[PassageTemplates] Loaded custom templates:', Object.keys(customTemplates).length);
            }
        } catch (e) {
            console.warn('[PassageTemplates] Error loading custom templates:', e);
        }
    }

    saveCustomTemplate(id, template) {
        try {
            const custom = JSON.parse(localStorage.getItem('whisker_custom_passage_templates') || '{}');
            custom[id] = template;
            localStorage.setItem('whisker_custom_passage_templates', JSON.stringify(custom));
            this.templates[id] = template;
            console.log('[PassageTemplates] Saved custom template:', id);
        } catch (e) {
            console.error('[PassageTemplates] Error saving custom template:', e);
        }
    }
}

// Make available globally
let passageTemplates;
