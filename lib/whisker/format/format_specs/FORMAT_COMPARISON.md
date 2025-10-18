# Twine Format Comparison Guide

A comprehensive comparison of all major Twine story formats and how they relate to Whisker.

## Quick Reference Table

| Format | Syntax Style | Complexity | Best For | Variables | JavaScript |
|--------|-------------|-----------|----------|-----------|------------|
| **Whisker** | Templates `{{...}}` | Medium | All users | Direct | Lua |
| **Harlowe** | Macros `(...)` | Medium | Writers | `$var` | Limited |
| **SugarCube** | Macros `<<...>>` | High | Programmers | `$var` | Full |
| **Chapbook** | Modifiers `[...]` | Low | Beginners | `{var}` | Limited |
| **Snowman** | JavaScript `<% %>` | Medium | JS developers | `s.var` | Full |

## Detailed Format Comparison

### Variable Syntax

```
Whisker:   {{playerName}}
Harlowe:   $playerName
SugarCube: $playerName
Chapbook:  {playerName}
Snowman:   <%= s.playerName %>
```

### Variable Assignment

```
Whisker:   {{health = 100}}
Harlowe:   (set: $health to 100)
SugarCube: <<set $health to 100>>
Chapbook:  health: 100
Snowman:   <% s.health = 100; %>
```

### Conditional Statements

**Simple If:**
```
Whisker:   {{if health > 50 then}}Strong{{end}}
Harlowe:   (if: $health > 50)[Strong]
SugarCube: <<if $health > 50>>Strong<<endif>>
Chapbook:  [if health > 50]
           Strong
           [continued]
Snowman:   <% if (s.health > 50) { %>Strong<% } %>
```

**If-Else:**
```
Whisker:   {{if hasKey then}}Open{{else}}Locked{{end}}
Harlowe:   (if: $hasKey)[Open](else:)[Locked]
SugarCube: <<if $hasKey>>Open<<else>>Locked<<endif>>
Chapbook:  [if hasKey]
           Open
           [else]
           Locked
           [continued]
Snowman:   <% if (s.hasKey) { %>Open<% } else { %>Locked<% } %>
```

### Links

**Basic Links:**
```
Whisker:   [[Next Room]]
Harlowe:   [[Next Room]]
SugarCube: [[Next Room]]
Chapbook:  [[Next Room]]
Snowman:   [[Next Room]]
```

**Links with Different Text:**
```
Whisker:   [[Go to the castle|Castle]]
Harlowe:   [[Go to the castle|Castle]]
SugarCube: [[Go to the castle|Castle]]
Chapbook:  [[Go to the castle->Castle]]
Snowman:   [[Go to the castle|Castle]]
```

### Loops

**Iterate Over Array:**
```
Whisker:   {{for item in inventory do}}
           * {{item}}
           {{end}}

Harlowe:   (for: each _item in $inventory)[
           * _item
           ]

SugarCube: <<for _item in $inventory>>
           * _item
           <</for>>

Chapbook:  [JavaScript]
           inventory.forEach(item => {
             write('* ' + item + '\n');
           });
           [continued]

Snowman:   <% s.inventory.forEach(function(item) { %>
           * <%= item %>
           <% }); %>
```

**Numeric Range:**
```
Whisker:   {{for i = 1, 5 do}}
           Step {{i}}
           {{end}}

Harlowe:   (for: each _i in (range: 1, 5))[
           Step _i
           ]

SugarCube: <<for _i range 1 5>>
           Step _i
           <</for>>

Chapbook:  [JavaScript]
           for (let i = 1; i <= 5; i++) {
             write('Step ' + i + '\n');
           }
           [continued]

Snowman:   <% for (let i = 1; i <= 5; i++) { %>
           Step <%= i %>
           <% } %>
```

## Feature Comparison Matrix

### Core Features

| Feature | Whisker | Harlowe | SugarCube | Chapbook | Snowman |
|---------|---------|---------|-----------|----------|---------|
| Variables | ✅ | ✅ | ✅ | ✅ | ✅ |
| Conditionals | ✅ | ✅ | ✅ | ✅ | ✅ |
| Loops | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| Functions | ✅ | ⚠️ | ✅ | ⚠️ | ✅ |
| Arrays | ✅ | ✅ | ✅ | ✅ | ✅ |
| Objects | ✅ | ✅ | ✅ | ✅ | ✅ |

### Advanced Features

| Feature | Whisker | Harlowe | SugarCube | Chapbook | Snowman |
|---------|---------|---------|-----------|----------|---------|
| JavaScript | Lua | Limited | ✅ Full | Limited | ✅ Full |
| Save System | Custom | Auto | ✅ Built-in | Auto | Manual |
| Custom Macros | ✅ | ❌ | ✅ | ❌ | ❌ |
| Multimedia | ✅ | Limited | ✅ Full | Limited | ✅ |
| CSS Styling | ✅ | Enchantments | ✅ | ✅ | ✅ |
| Markdown | ✅ | ✅ | ❌ | ✅ Full | ❌ |

### Developer Features

| Feature | Whisker | Harlowe | SugarCube | Chapbook | Snowman |
|---------|---------|---------|-----------|----------|---------|
| API Access | ✅ | Limited | ✅ Extensive | Limited | ✅ Full |
| State Access | ✅ | Auto | ✅ Direct | Auto | ✅ Direct |
| History Control | ✅ | Auto | ✅ Full | Auto | Manual |
| DOM Access | ✅ | Limited | ✅ | Limited | ✅ Full |
| Custom Widgets | ✅ | ❌ | ✅ | ❌ | ❌ |

## Syntax Complexity Comparison

### Learning Curve

```
Chapbook    █░░░░░░░░░ Easiest
Harlowe     ███░░░░░░░ Easy-Medium
Whisker     ████░░░░░░ Medium
Snowman     █████░░░░░ Medium
SugarCube   ███████░░░ Advanced
```

### Example: Complete Inventory System

**Whisker:**
```
{{inventory = inventory or {}}}

Your inventory:
{{if #inventory > 0 then}}
  {{for item in inventory do}}
  * {{item}}
  {{end}}
{{else}}
  Empty
{{end}}

[[Pick up sword->PickupSword]]
```

**Harlowe:**
```
(set: $inventory to (a:))

Your inventory:
(if: $inventory's length > 0)[
  (for: each _item in $inventory)[
    * _item
  ]
](else:)[
  Empty
]

[[Pick up sword->PickupSword]]
```

**SugarCube:**
```
<<set $inventory to []>>

Your inventory:
<<if $inventory.length > 0>>
  <<for _item in $inventory>>
    * _item
  <</for>>
<<else>>
  Empty
<</if>>

[[Pick up sword->PickupSword]]
```

**Chapbook:**
```
inventory: []

Your inventory:
[if inventory.length > 0]
[JavaScript]
inventory.forEach(item => write('* ' + item + '\n'));
[continued]
[else]
Empty
[continued]

[[Pick up sword->PickupSword]]
```

**Snowman:**
```
<% s.inventory = s.inventory || []; %>

Your inventory:
<% if (s.inventory.length > 0) { %>
  <% s.inventory.forEach(function(item) { %>
    * <%= item %>
  <% }); %>
<% } else { %>
  Empty
<% } %>

[[Pick up sword->PickupSword]]
```

## Conversion Difficulty

### Easy Conversions (90%+ Automated)

✅ **Whisker ↔ Chapbook**
- Similar template syntax
- Simple variable handling
- Straightforward conditionals

✅ **Harlowe ↔ SugarCube**
- Both use macro systems
- Similar variable prefixes
- Compatible link syntax

### Medium Conversions (70-90% Automated)

⚠️ **Whisker ↔ Harlowe**
- Macro conversion needed
- Hook system differences
- Enchantment mapping

⚠️ **Whisker ↔ SugarCube**
- Extensive macro library
- JavaScript integration
- Widget conversion

### Complex Conversions (50-70% Automated)

⚠️ **Whisker ↔ Snowman**
- JavaScript ↔ Lua translation
- State object differences
- Template syntax differences

## Operator Comparison

### Logical Operators

| Operation | Whisker | Harlowe | SugarCube | Chapbook | Snowman |
|-----------|---------|---------|-----------|----------|---------|
| AND | `and` | `and` | `and` or `&&` | `&&` | `&&` |
| OR | `or` | `or` | `or` or `\|\|` | `\|\|` | `\|\|` |
| NOT | `not` | `not` | `not` or `!` | `!` | `!` |

### Comparison Operators

| Operation | Whisker | Harlowe | SugarCube | Chapbook | Snowman |
|-----------|---------|---------|-----------|----------|---------|
| Equals | `==` | `is` | `eq` or `===` | `===` | `===` |
| Not Equals | `~=` | `is not` | `neq` or `!==` | `!==` | `!==` |
| Greater | `>` | `>` | `gt` or `>` | `>` | `>` |
| Less | `<` | `<` | `lt` or `<` | `<` | `<` |

## Choosing the Right Format

### Use Whisker When:
- ✅ Building a new story from scratch
- ✅ Want a balance of power and simplicity
- ✅ Prefer Lua over JavaScript
- ✅ Need format independence
- ✅ Want full control over the system

### Use Harlowe When:
- ✅ You're a writer, not a programmer
- ✅ Want the default Twine experience
- ✅ Like natural-language macros
- ✅ Don't need JavaScript
- ✅ Want good documentation

### Use SugarCube When:
- ✅ You're comfortable with programming
- ✅ Need advanced features
- ✅ Want extensive macro library
- ✅ Need custom save system
- ✅ Building complex games

### Use Chapbook When:
- ✅ You're new to Twine
- ✅ Want simplicity above all
- ✅ Like Markdown
- ✅ Don't need complex logic
- ✅ Focus on story, not code

### Use Snowman When:
- ✅ You're a JavaScript developer
- ✅ Want minimal abstraction
- ✅ Need direct DOM access
- ✅ Prefer code over macros
- ✅ Want full control

## Migration Paths

### From Twine to Whisker

1. **Harlowe → Whisker** (Recommended)
   - Similar complexity level
   - Smooth transition
   - Good documentation

2. **SugarCube → Whisker** (Advanced)
   - More features to map
   - JavaScript → Lua learning
   - Widget conversion needed

3. **Chapbook → Whisker** (Easy)
   - Similar simplicity
   - Easy syntax mapping
   - Quick migration

4. **Snowman → Whisker** (Medium)
   - JavaScript → Lua translation
   - State management changes
   - Template syntax similar

### From Whisker to Twine

Best target depends on your needs:
- **For writers:** Whisker → Harlowe
- **For programmers:** Whisker → SugarCube
- **For beginners:** Whisker → Chapbook
- **For JS devs:** Whisker → Snowman

## Resources

- [Harlowe Documentation](https://twine2.neocities.org/)
- [SugarCube Documentation](https://www.motoslave.net/sugarcube/2/)
- [Chapbook Documentation](https://klembot.github.io/chapbook/)
- [Snowman Documentation](https://github.com/klembot/snowman)
- [Whisker Documentation](../README.md)

## Conclusion

Each format has its strengths:

- **Whisker**: Balanced, format-independent
- **Harlowe**: Writer-friendly, natural language
- **SugarCube**: Powerful, feature-rich
- **Chapbook**: Simple, accessible
- **Snowman**: Code-first, minimal

Choose based on your needs, skill level, and project requirements. Whisker provides the best of all worlds with conversion support for interoperability.