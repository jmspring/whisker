# Passage Templates

## Overview

Passage Templates allow you to quickly insert common passage patterns into your story, saving time and ensuring consistency. Instead of writing the same types of passages from scratch, you can select from a library of pre-built templates.

## How to Use

1. **Open a passage** in the editor
2. **Click the "📋 Insert Template" button** above the content area
3. **Browse or search** for the template you need
4. **Click a template card** to insert it at your cursor position

The template content will be inserted with placeholder text that you can customize for your story.

## Built-in Template Categories

### Basic Templates
- **Basic Choice** - Simple branching with two options
- **Descriptive Scene** - Rich environmental description

### RPG Templates
- **Basic Combat** - Simple combat encounter
- **Advanced Combat** - Combat with class abilities and stamina
- **Skill Check** - D20 skill roll with pass/fail branches
- **Level Up** - Character advancement with stat increases
- **Merchant/Shop** - Shop interface with buyable items
- **Find Loot** - Treasure discovery with perception checks

### Dialogue Templates
- **Dialogue Branch** - NPC conversation with multiple responses
- **Persuasion Check** - Charisma-based skill check

### Quest Templates
- **Accept Quest** - NPC offers a quest
- **Complete Quest** - Turn in finished quest for rewards

### Logic Templates
- **Conditional Path** - Branch based on variables
- **Variable Check** - Multiple conditions with different outcomes
- **Timed Event** - Track time or turn counts
- **Random Encounter** - Randomized events

### Exploration Templates
- **Locked Door** - Door requiring key or lockpicking
- **Treasure Chest** - Chest with possible traps
- **Rest/Camp** - Safe place to recover health/stamina

## Customizing Templates

After inserting a template, look for placeholder text in brackets like:
- `[Scene Title]` - Replace with your scene name
- `[Enemy Name]` - Replace with the enemy type
- `[cost]` - Replace with gold cost
- `[DC]` - Replace with difficulty class number

## Variable Placeholders

Templates use Whisker's templating syntax:
- `{{variable}}` - Display variable value
- `{{#if condition}}...{{/if}}` - Conditional content
- `{{lua: code }}` - Execute Lua code

## Creating Custom Templates

### Option 1: Save Your Own
After creating a passage you like, you can save it as a custom template:

```javascript
passageTemplates.saveCustomTemplate('my_template_id', {
    name: 'My Template',
    category: 'Custom',
    description: 'Description of what it does',
    icon: '🎯',
    content: `Your template content here`
});
```

### Option 2: Extend the System

Edit `js/passage-templates.js` and add to the `getBuiltInTemplates()` method:

```javascript
'my_new_template': {
    name: 'Template Name',
    category: 'Category Name',
    description: 'What this template does',
    icon: '🎯',  // Emoji icon
    content: `Template content with
multiple lines and
{{variables}}`
}
```

## Template Best Practices

### 1. Use Descriptive Placeholders
```whisker
// Good
**Combat: [Enemy Name]**
You face a [enemy description].

// Bad
**Combat: XXX**
You face a YYY.
```

### 2. Include Comments
```whisker
<!-- This passage handles the boss fight -->
**Boss Battle**
...
```

### 3. Consistent Variable Names
Follow your project's naming conventions:
- `quest_name_active` not `questNameActive`
- `has_item` not `item_acquired`

### 4. Test Your Templates
Before saving a custom template, test it in your story to ensure all variables and logic work correctly.

## Tips for RPG Templates

### Combat Templates
- Always show current health/stamina
- Include class-specific ability options
- Provide defensive options (defend, flee)
- Consider companion abilities

### Skill Check Templates
- Use math.random(1,20) for D20 rolls
- Add skill bonuses to rolls
- Set appropriate difficulty classes (DC)
- Provide meaningful success/failure branches

### Shop Templates
- Check if items are already owned
- Verify player has enough gold
- Use conditional display for affordable items
- Update gold after purchase

### Quest Templates
- Set quest status variables
- Track quest objectives
- Award appropriate XP and rewards
- Consider quest chains

## Advanced Features

### Search and Filter
Use the search box to find templates by:
- Template name
- Description text
- Category name

### Keyboard Shortcuts
- `Ctrl/Cmd + K` - Quick insert template (coming soon)
- `Esc` - Close template dialog

### Template Variables
Some templates include helper functions:

```lua
{{lua:
    -- Roll with advantage (take higher of 2 rolls)
    local roll1 = math.random(1,20);
    local roll2 = math.random(1,20);
    local roll = math.max(roll1, roll2);
    game_state:set("roll_result", roll)
}}
```

## Examples

### Example 1: Combat Encounter

Insert the "Advanced Combat" template, then customize:

```whisker
**Combat: Dire Wolf**

A massive dire wolf emerges from the shadows, its eyes gleaming with hunger.

**Your Stats:**
- Health: {{health}}/{{max_health}}
- Stamina: {{stamina}}/{{max_stamina}}

**Enemy Stats:**
- Health: 35/35
- Attack: +5

**Actions:**
[[Normal Attack->wolf_attack_normal]]
{{#if stamina >= 3 and class == "Fighter"}}[[Power Strike (3 stamina)->wolf_attack_power]]{{/if}}
{{#if stamina >= 2 and class == "Rogue"}}[[Sneak Attack (2 stamina)->wolf_attack_sneak]]{{/if}}
[[Defend->wolf_defend]]
```

### Example 2: Skill Check

Insert the "Skill Check" template and modify:

```whisker
**Ancient Runes**

You find strange runes carved into the stone. Your Arcana knowledge might help decipher them.

{{lua:
    local roll = math.random(1,20);
    local arcana = game_state:get("skill_arcana") or 0;
    local total = roll + arcana;
    game_state:set("arcana_check", total)
}}

Roll: {{arcana_check}} (DC 15)

{{#if arcana_check >= 15}}
**Success!** You decipher the ancient text. It speaks of a hidden chamber...
[[Investigate further->secret_chamber]]
{{else}}
**Failure.** The runes remain mysterious.
[[Move on->continue_exploration]]
{{/if}}
```

## Troubleshooting

### Template Won't Insert
- Make sure you're editing a passage
- Check that the content textarea is focused
- Try clicking the button again

### Variables Not Working
- Ensure variables are defined in your project
- Check spelling of variable names
- Use `{{variable}}` syntax correctly

### Lua Code Errors
- Verify Lua syntax is correct
- Test code snippets separately
- Check console for error messages

## Future Enhancements

Planned features:
- Import/export template packs
- Community template marketplace
- Visual template editor
- Template categories customization
- Multi-select template insertion
- Template variables with type checking

## Contributing Templates

Have a great template to share? Consider:
1. Testing it thoroughly in your stories
2. Adding clear placeholder text
3. Including helpful comments
4. Submitting it to the Whisker community

---

For more information, see:
- [Whisker Documentation](../README.md)
- [Templating Guide](TEMPLATING.md)
- [RPG Systems Guide](RPG_SYSTEMS.md)
