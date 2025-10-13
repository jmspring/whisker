-- examples/keep_on_the_borderlands.lua
-- A simplified solo adventure based on the classic D&D module B2
-- Designed for single-player exploration of the Caves of Chaos

local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

-- Create the story
local story = Story.new({
    title = "The Keep on the Borderlands",
    author = "Adapted from Gary Gygax's classic module",
    ifid = "KEEP-BORDERLANDS-001",
    version = "1.0",
    description = "A solo adventure in the legendary Caves of Chaos"
})

-- Initialize story variables
story.variables = {
    player_name = "Adventurer",
    health = 20,
    max_health = 20,
    gold = 50,
    has_sword = true,
    has_shield = false,
    has_healing_potion = false,
    has_rope = false,
    has_torch = true,
    explored_kobold_lair = false,
    explored_orc_lair = false,
    explored_goblin_lair = false,
    kobolds_defeated = false,
    found_secret_treasure = false,
    warned_by_merchant = false,
    reputation = 0
}

-- ============================================================================
-- START AND KEEP PASSAGES
-- ============================================================================

local start = Passage.new({
    id = "start",
    content = [[
**The Keep on the Borderlands**
*A Solo Adventure*

You are a young adventurer who has traveled many days to reach the Keep on the
Borderlands, a lonely fortress that stands between civilization and the wild,
untamed lands beyond.

Word has spread of the Caves of Chaos - a winding ravine filled with caves
inhabited by evil humanoids and worse. The Castellan offers rewards for those
brave enough to clear out these threats.

You stand at the gates of the Keep with {{gold}} gold pieces, a trusty sword,
and a burning desire for adventure.

**Health:** {{health}}/{{max_health}}
    ]],
    on_enter = [[
        if not game_state:get_variable("game_started") then
            game_state:set_variable("game_started", true)
        end
    ]]
})

start:add_choice(Choice.new({
    text = "Enter the Keep",
    target = "keep_entrance"
}))

start:add_choice(Choice.new({
    text = "Head directly to the Caves of Chaos",
    target = "to_caves_direct"
}))

-- ============================================================================
-- THE KEEP
-- ============================================================================

local keep_entrance = Passage.new({
    id = "keep_entrance",
    content = [[
You pass through the massive gates into the outer bailey of the Keep.
The courtyard buzzes with activity - guards patrol the walls, merchants
hawk their wares, and common folk go about their business.

Several buildings stand around you:
- The Travelers' Inn, where you can rest
- The Provisioner's shop, selling adventuring supplies
- The Tavern, where rumors and information flow freely
- The Chapel, offering blessings to those who fight evil

**Health:** {{health}}/{{max_health}} | **Gold:** {{gold}}
    ]]
})

keep_entrance:add_choice(Choice.new({
    text = "Visit the Provisioner",
    target = "provisioner"
}))

keep_entrance:add_choice(Choice.new({
    text = "Go to the Tavern",
    target = "tavern"
}))

keep_entrance:add_choice(Choice.new({
    text = "Rest at the Inn",
    target = "inn",
    condition = "health < max_health"
}))

keep_entrance:add_choice(Choice.new({
    text = "Visit the Chapel",
    target = "chapel"
}))

keep_entrance:add_choice(Choice.new({
    text = "Journey to the Caves of Chaos",
    target = "to_caves"
}))

-- Provisioner
local provisioner = Passage.new({
    id = "provisioner",
    content = [[
The Provisioner's shop is stocked with various adventuring supplies. The shopkeeper
eyes you carefully.

"What can I get for you, adventurer?"

Available items:
- Shield (20 gold) {{has_shield and "- PURCHASED" or ""}}
- Healing Potion (30 gold) {{has_healing_potion and "- PURCHASED" or ""}}
- Rope (15 gold) {{has_rope and "- PURCHASED" or ""}}

**Your gold:** {{gold}}
    ]]
})

provisioner:add_choice(Choice.new({
    text = "Buy a shield (20 gold)",
    target = "buy_shield",
    condition = "gold >= 20 and not has_shield"
}))

provisioner:add_choice(Choice.new({
    text = "Buy a healing potion (30 gold)",
    target = "buy_potion",
    condition = "gold >= 30 and not has_healing_potion"
}))

provisioner:add_choice(Choice.new({
    text = "Buy rope (15 gold)",
    target = "buy_rope",
    condition = "gold >= 15 and not has_rope"
}))

provisioner:add_choice(Choice.new({
    text = "Leave the shop",
    target = "keep_entrance"
}))

local buy_shield = Passage.new({
    id = "buy_shield",
    content = [[
You purchase a sturdy wooden shield. It will help protect you in battle!

**Shield acquired!**
**Gold remaining:** {{gold - 20}}
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") - 20)
        game_state:set_variable("has_shield", true)
    ]]
})

buy_shield:add_choice(Choice.new({
    text = "Continue shopping",
    target = "provisioner"
}))

buy_shield:add_choice(Choice.new({
    text = "Leave",
    target = "keep_entrance"
}))

local buy_potion = Passage.new({
    id = "buy_potion",
    content = [[
You purchase a healing potion in a small glass vial. It glows with a soft red light.

"This will restore 10 health when you drink it," the shopkeeper says.

**Healing Potion acquired!**
**Gold remaining:** {{gold - 30}}
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") - 30)
        game_state:set_variable("has_healing_potion", true)
    ]]
})

buy_potion:add_choice(Choice.new({
    text = "Continue shopping",
    target = "provisioner"
}))

buy_potion:add_choice(Choice.new({
    text = "Leave",
    target = "keep_entrance"
}))

local buy_rope = Passage.new({
    id = "buy_rope",
    content = [[
You purchase 50 feet of strong rope. It might come in handy for climbing!

**Rope acquired!**
**Gold remaining:** {{gold - 15}}
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") - 15)
        game_state:set_variable("has_rope", true)
    ]]
})

buy_rope:add_choice(Choice.new({
    text = "Continue shopping",
    target = "provisioner"
}))

buy_rope:add_choice(Choice.new({
    text = "Leave",
    target = "keep_entrance"
}))

-- Tavern
local tavern = Passage.new({
    id = "tavern",
    content = [[
The tavern is warm and crowded. The smell of ale and roasted meat fills the air.
You find a seat at the bar.

The barkeeper leans in. "First time here? You look like you're heading to those
cursed caves. Let me give you some advice..."

"The kobolds have the lowest caves - they're weak but numerous. The orcs and
goblins are always fighting each other. And whatever you do, stay away from the
shrine at the far end of the ravine. Dark magic there."

{{warned_by_merchant and "A traveling merchant in the corner waves at you." or ""}}

**Health:** {{health}}/{{max_health}} | **Gold:** {{gold}}
    ]],
    on_enter = [[
        if not game_state:get_variable("heard_rumors") then
            game_state:set_variable("heard_rumors", true)
        end
    ]]
})

tavern:add_choice(Choice.new({
    text = "Talk to the merchant",
    target = "merchant",
    condition = "not warned_by_merchant"
}))

tavern:add_choice(Choice.new({
    text = "Buy a drink and listen for more rumors (5 gold)",
    target = "tavern_rumors",
    condition = "gold >= 5"
}))

tavern:add_choice(Choice.new({
    text = "Leave the tavern",
    target = "keep_entrance"
}))

local merchant = Passage.new({
    id = "merchant",
    content = [[
The merchant gestures for you to sit. He's a portly man with nervous eyes.

"Listen friend," he whispers, "I was ambushed near the caves last week. Lost
most of my goods. But I managed to hide a sack of coins in a hollow tree just
outside the ravine - southeast of the main entrance. If you find it, it's yours.
Consider it payment for avenging me."

He sketches a rough map on a napkin.

**You've learned the location of hidden treasure!**
    ]],
    on_enter = [[
        game_state:set_variable("warned_by_merchant", true)
    ]]
})

merchant:add_choice(Choice.new({
    text = "Thank him and return to the bar",
    target = "tavern"
}))

local tavern_rumors = Passage.new({
    id = "tavern_rumors",
    content = [[
You buy a round of ale and listen to the chatter. You pick up several useful
pieces of information:

- "Someone said there's a mad hermit in the woods. Dangerous fellow."
- "The bugbears are the strongest in the caves, but they keep to themselves."
- "If you can turn the tribes against each other, they'll do your work for you."

**Gold:** {{gold - 5}}
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") - 5)
    ]]
})

tavern_rumors:add_choice(Choice.new({
    text = "Leave the tavern",
    target = "keep_entrance"
}))

-- Inn
local inn = Passage.new({
    id = "inn",
    content = [[
You rent a room at the Travelers' Inn for the night. The bed is simple but clean,
and you sleep soundly.

In the morning, you feel refreshed and ready for adventure!

**Health fully restored!**
**Gold:** {{gold - 10}}
    ]],
    on_enter = [[
        game_state:set_variable("health", game_state:get_variable("max_health"))
        game_state:set_variable("gold", game_state:get_variable("gold") - 10)
    ]]
})

inn:add_choice(Choice.new({
    text = "Leave the inn",
    target = "keep_entrance"
}))

-- Chapel
local chapel = Passage.new({
    id = "chapel",
    content = [[
You enter the chapel. A priest in simple robes greets you with a warm smile.

"Welcome, child. Are you heading into danger? Let me offer you a blessing."

He places his hand on your forehead and speaks a prayer. You feel a warm
sensation flow through you.

**Maximum health increased by 5!**
**Current health restored!**
    ]],
    on_enter = [[
        if not game_state:get_variable("received_blessing") then
            game_state:set_variable("max_health", game_state:get_variable("max_health") + 5)
            game_state:set_variable("health", game_state:get_variable("max_health"))
            game_state:set_variable("received_blessing", true)
        end
    ]]
})

chapel:add_choice(Choice.new({
    text = "Thank the priest and leave",
    target = "keep_entrance"
}))

-- ============================================================================
-- JOURNEY TO CAVES
-- ============================================================================

local to_caves_direct = Passage.new({
    id = "to_caves_direct",
    content = [[
You set off immediately toward the Caves of Chaos, confident in your abilities.

The journey takes most of the day. As the sun begins to set, you emerge from
the dark forest into a rocky ravine. Cave mouths dot the cliff walls on both
sides, like the eyes of some great beast.

The air is thick with menace. Bones litter the ground - some human, some animal.

You've found the Caves of Chaos.

**Health:** {{health}}/{{max_health}} | **Gold:** {{gold}}
    ]]
})

to_caves_direct:add_choice(Choice.new({
    text = "Explore the lower caves",
    target = "cave_entrance"
}))

to_caves_direct:add_choice(Choice.new({
    text = "Look for the merchant's hidden treasure",
    target = "no_map",
    condition = "not warned_by_merchant"
}))

to_caves_direct:add_choice(Choice.new({
    text = "Return to the Keep",
    target = "keep_entrance"
}))

local to_caves = Passage.new({
    id = "to_caves",
    content = [[
You leave the safety of the Keep and journey through the wilderness. The road
gradually becomes a narrow trail, then disappears entirely as you enter dark,
twisted woods.

After several hours, you emerge into a ravine. Before you lies the Caves of
Chaos - a maze of cave entrances set into rocky cliffs. Bones and debris scatter
the ground.

{{warned_by_merchant and "You remember the merchant's directions to the hidden treasure." or ""}}

**Health:** {{health}}/{{max_health}} | **Gold:** {{gold}}
    ]]
})

to_caves:add_choice(Choice.new({
    text = "Look for the merchant's hidden treasure",
    target = "find_treasure",
    condition = "warned_by_merchant and not found_secret_treasure"
}))

to_caves:add_choice(Choice.new({
    text = "Explore the lower caves",
    target = "cave_entrance"
}))

to_caves:add_choice(Choice.new({
    text = "Return to the Keep",
    target = "keep_entrance"
}))

local no_map = Passage.new({
    id = "no_map",
    content = [[
You search the area for hidden treasure, but without any directions, you find
nothing but rocks and bones.

It would help to have more information.
    ]]
})

no_map:add_choice(Choice.new({
    text = "Enter the caves",
    target = "cave_entrance"
}))

no_map:add_choice(Choice.new({
    text = "Return to the Keep",
    target = "keep_entrance"
}))

local find_treasure = Passage.new({
    id = "find_treasure",
    content = [[
Following the merchant's directions, you search southeast of the ravine entrance.
After some searching, you find a hollow tree!

Inside is a leather sack containing gold coins!

**You found 100 gold pieces!**
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") + 100)
        game_state:set_variable("found_secret_treasure", true)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 1)
    ]]
})

find_treasure:add_choice(Choice.new({
    text = "Continue to the caves",
    target = "cave_entrance"
}))

find_treasure:add_choice(Choice.new({
    text = "Return to the Keep with your find",
    target = "keep_entrance"
}))

-- ============================================================================
-- CAVE EXPLORATION
-- ============================================================================

local cave_entrance = Passage.new({
    id = "cave_entrance",
    content = [[
You stand at the entrance to the ravine. Several cave mouths are visible:

To your left, a low cave entrance has strange markings carved around it.
{{explored_kobold_lair and "(You've already explored the kobold lair)" or ""}}

Higher up, you can see two larger cave entrances - likely the orc and goblin lairs
the barkeeper mentioned.
{{explored_orc_lair and "(You've already explored the orc lair)" or ""}}
{{explored_goblin_lair and "(You've already explored the goblin lair)" or ""}}

At the far end of the ravine, you can make out a dark cave with an ominous aura.

**Health:** {{health}}/{{max_health}} | **Gold:** {{gold}}
{{has_healing_potion and "**Items:** Healing Potion" or ""}}
    ]]
})

cave_entrance:add_choice(Choice.new({
    text = "Explore the low cave (Kobold Lair)",
    target = "kobold_cave",
    condition = "not explored_kobold_lair"
}))

cave_entrance:add_choice(Choice.new({
    text = "Climb to the orc lair",
    target = "orc_cave",
    condition = "not explored_orc_lair"
}))

cave_entrance:add_choice(Choice.new({
    text = "Investigate the goblin lair",
    target = "goblin_cave",
    condition = "not explored_goblin_lair"
}))

cave_entrance:add_choice(Choice.new({
    text = "Approach the dark shrine (dangerous!)",
    target = "evil_shrine"
}))

cave_entrance:add_choice(Choice.new({
    text = "Return to the Keep to rest and resupply",
    target = "keep_entrance"
}))

-- ============================================================================
-- KOBOLD LAIR
-- ============================================================================

local kobold_cave = Passage.new({
    id = "kobold_cave",
    content = [[
You enter the low cave, having to crouch to fit through the entrance. The smell
of unwashed bodies and rotting meat assaults your nose.

As your eyes adjust to the darkness, you see movement ahead - small, dog-like
humanoids with scaly skin. Kobolds!

Three kobolds notice you and let out high-pitched yips of alarm, drawing crude
weapons!

**Health:** {{health}}/{{max_health}}
{{has_shield and "Your shield is ready!" or ""}}
    ]]
})

kobold_cave:add_choice(Choice.new({
    text = "Fight the kobolds!",
    target = "fight_kobolds"
}))

kobold_cave:add_choice(Choice.new({
    text = "Try to scare them with a fierce battle cry",
    target = "scare_kobolds"
}))

kobold_cave:add_choice(Choice.new({
    text = "Retreat from the cave",
    target = "cave_entrance"
}))

local fight_kobolds = Passage.new({
    id = "fight_kobolds",
    content = [[
You charge into battle! Your sword flashes in the dim light as you strike at
the kobolds.

The creatures fight back ferociously, but they're weak and poorly armed.
{{has_shield and "Your shield deflects several blows!" or "Without a shield, you take several cuts and scrapes."}}

After a brief but intense fight, the three kobolds lie defeated. The others flee
deeper into the caves, yipping in terror.

**Damage taken:** {{has_shield and "5" or "10"}} health
**Kobolds defeated!**

Searching the room, you find {{kobolds_defeated and "nothing more of value" or "a small pouch with 20 gold pieces and a rusty dagger"}}!
    ]],
    on_enter = [[
        local damage = game_state:get_variable("has_shield") and 5 or 10
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - damage))

        if not game_state:get_variable("kobolds_defeated") then
            game_state:set_variable("gold", game_state:get_variable("gold") + 20)
            game_state:set_variable("kobolds_defeated", true)
            game_state:set_variable("explored_kobold_lair", true)
            game_state:set_variable("reputation", game_state:get_variable("reputation") + 2)
        end
    ]]
})

fight_kobolds:add_choice(Choice.new({
    text = "Use your healing potion",
    target = "use_potion_kobolds",
    condition = "has_healing_potion and health < max_health"
}))

fight_kobolds:add_choice(Choice.new({
    text = "You've been defeated...",
    target = "death",
    condition = "health <= 0"
}))

fight_kobolds:add_choice(Choice.new({
    text = "Explore deeper into the kobold lair",
    target = "kobold_deeper"
}))

fight_kobolds:add_choice(Choice.new({
    text = "Leave and return to the ravine",
    target = "cave_entrance",
    condition = "health > 0"
}))

local scare_kobolds = Passage.new({
    id = "scare_kobolds",
    content = [[
You raise your sword high and let out a terrifying war cry!

The kobolds freeze, their eyes wide with fear. These creatures are natural
cowards, and your display of confidence unnerves them.

After a moment of hesitation, all three kobolds drop their weapons and flee
deeper into the caves, yipping in panic!

**No damage taken!**
**The kobolds are scattered!**

You've earned a reputation for fierceness.
    ]],
    on_enter = [[
        game_state:set_variable("kobolds_defeated", true)
        game_state:set_variable("explored_kobold_lair", true)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 1)
    ]]
})

scare_kobolds:add_choice(Choice.new({
    text = "Explore deeper into the kobold lair",
    target = "kobold_deeper"
}))

scare_kobolds:add_choice(Choice.new({
    text = "Leave while they're scattered",
    target = "cave_entrance"
}))

local kobold_deeper = Passage.new({
    id = "kobold_deeper",
    content = [[
You venture deeper into the kobold warren. The passages are cramped and twist
in confusing patterns.

In a larger chamber, you find the kobolds' storage area. Most of it is worthless
junk and rotting food, but you do find some items of value.

**You found:**
- 30 gold pieces
- A silver dagger (worth 20 gold)
- Torches and supplies

The kobolds have fled, and you've cleared this lair!
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") + 50)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 1)
    ]]
})

kobold_deeper:add_choice(Choice.new({
    text = "Return to the ravine entrance",
    target = "cave_entrance"
}))

local use_potion_kobolds = Passage.new({
    id = "use_potion_kobolds",
    content = [[
You drink the healing potion. A warm sensation flows through your body as your
wounds begin to close.

**Health restored by 10!**
**Health:** {{health + 10}}/{{max_health}}
    ]],
    on_enter = [[
        local health = game_state:get_variable("health")
        local max_health = game_state:get_variable("max_health")
        game_state:set_variable("health", math.min(max_health, health + 10))
        game_state:set_variable("has_healing_potion", false)
    ]]
})

use_potion_kobolds:add_choice(Choice.new({
    text = "Continue exploring",
    target = "kobold_deeper"
}))

use_potion_kobolds:add_choice(Choice.new({
    text = "Return to the ravine",
    target = "cave_entrance"
}))

-- ============================================================================
-- ORC LAIR
-- ============================================================================

local orc_cave = Passage.new({
    id = "orc_cave",
    content = [[
You climb the rocky slope to reach a larger cave entrance. As you approach, you
hear guttural voices speaking in a harsh tongue.

Peering around the corner, you see two orc guards standing watch. They're larger
and tougher than the kobolds, with tusked faces and battle-scarred armor.

Beyond them, you can hear more orcs - perhaps half a dozen in the main chamber.

This will be a serious fight.

**Health:** {{health}}/{{max_health}}
    ]]
})

orc_cave:add_choice(Choice.new({
    text = "Attack the guards directly",
    target = "fight_orc_guards"
}))

orc_cave:add_choice(Choice.new({
    text = "Try to sneak past the guards",
    target = "sneak_orcs"
}))

orc_cave:add_choice(Choice.new({
    text = "This seems too dangerous - retreat",
    target = "cave_entrance"
}))

local fight_orc_guards = Passage.new({
    id = "fight_orc_guards",
    content = [[
You charge at the orc guards with your sword raised!

The orcs react quickly, drawing their weapons. The battle is fierce and brutal.
These creatures are far stronger than kobolds!

{{has_shield and "Your shield saves you from several crushing blows!" or "Without a shield, you take heavy damage from their axes!"}}

After a desperate fight, you manage to defeat both guards, but at a cost. The
sounds of battle have alerted the other orcs inside!

**Damage taken:** {{has_shield and "12" or "18"}} health
**Orc guards defeated!**

You hear heavy footsteps approaching - more orcs are coming!
    ]],
    on_enter = [[
        local damage = game_state:get_variable("has_shield") and 12 or 18
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - damage))
    ]]
})

fight_orc_guards:add_choice(Choice.new({
    text = "You've been defeated...",
    target = "death",
    condition = "health <= 0"
}))

fight_orc_guards:add_choice(Choice.new({
    text = "Use your healing potion quickly!",
    target = "use_potion_orcs",
    condition = "has_healing_potion and health > 0 and health < 15"
}))

fight_orc_guards:add_choice(Choice.new({
    text = "Stand and fight the reinforcements!",
    target = "fight_orc_horde",
    condition = "health > 0 and health >= 15"
}))

fight_orc_guards:add_choice(Choice.new({
    text = "Retreat while you still can!",
    target = "orc_retreat",
    condition = "health > 0 and health < 15"
}))

local use_potion_orcs = Passage.new({
    id = "use_potion_orcs",
    content = [[
You quickly drink your healing potion as the orc reinforcements approach!

The warm magic flows through you, healing your wounds just in time.

**Health restored by 10!**
**Health:** {{health + 10}}/{{max_health}}

Now you must face the orc war party!
    ]],
    on_enter = [[
        local health = game_state:get_variable("health")
        local max_health = game_state:get_variable("max_health")
        game_state:set_variable("health", math.min(max_health, health + 10))
        game_state:set_variable("has_healing_potion", false)
    ]]
})

use_potion_orcs:add_choice(Choice.new({
    text = "Fight the orc war party!",
    target = "fight_orc_horde"
}))

local fight_orc_horde = Passage.new({
    id = "fight_orc_horde",
    content = [[
Six more orcs pour out of the cave! This is madness - you're outnumbered!

But something amazing happens. Your fierce battle cry and the sight of their
fallen comrades causes the orcs to hesitate. You press the advantage, fighting
with desperate strength!

{{reputation >= 3 and "Your reputation precedes you - some of the orcs actually look frightened!" or ""}}

The battle is brutal and exhausting. One by one, the orcs fall before your blade.
When the last orc collapses, you stand victorious but barely able to stand.

**This is your greatest victory!**
**Damage taken:** {{has_shield and "10" or "15"}} more health

You find significant treasure in the orc lair:
- 150 gold pieces
- A silver war horn
- Various weapons and armor

**The orc lair is cleared!**
    ]],
    on_enter = [[
        local damage = game_state:get_variable("has_shield") and 10 or 15
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - damage))
        game_state:set_variable("gold", game_state:get_variable("gold") + 150)
        game_state:set_variable("explored_orc_lair", true)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 5)
    ]]
})

fight_orc_horde:add_choice(Choice.new({
    text = "You've been defeated at the moment of victory...",
    target = "death",
    condition = "health <= 0"
}))

fight_orc_horde:add_choice(Choice.new({
    text = "Return to the Keep to rest and celebrate",
    target = "keep_entrance",
    condition = "health > 0"
}))

fight_orc_horde:add_choice(Choice.new({
    text = "Continue exploring despite your wounds",
    target = "cave_entrance",
    condition = "health > 5"
}))

local sneak_orcs = Passage.new({
    id = "sneak_orcs",
    content = [[
You attempt to sneak past the guards while they're distracted...

Unfortunately, you knock a loose stone with your foot! The guards whirl around
and spot you immediately.

"INTRUDER!" one of them roars.

You're forced into combat in a bad position!

**Surprise attack!**
**Damage taken: 15 health**
    ]],
    on_enter = [[
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - 15))
    ]]
})

sneak_orcs:add_choice(Choice.new({
    text = "You've been defeated...",
    target = "death",
    condition = "health <= 0"
}))

sneak_orcs:add_choice(Choice.new({
    text = "Fight back!",
    target = "fight_orc_guards",
    condition = "health > 0"
}))

sneak_orcs:add_choice(Choice.new({
    text = "Flee!",
    target = "orc_retreat",
    condition = "health > 0"
}))

local orc_retreat = Passage.new({
    id = "orc_retreat",
    content = [[
You turn and run from the orc lair! The orcs chase you for a while, hurling
insults and throwing rocks, but eventually give up the pursuit.

You've escaped alive, but the orcs remain a threat.

**Health:** {{health}}/{{max_health}}
    ]]
})

orc_retreat:add_choice(Choice.new({
    text = "Return to the Keep to heal",
    target = "keep_entrance"
}))

orc_retreat:add_choice(Choice.new({
    text = "Try a different cave",
    target = "cave_entrance",
    condition = "health > 10"
}))

-- ============================================================================
-- GOBLIN LAIR
-- ============================================================================

local goblin_cave = Passage.new({
    id = "goblin_cave",
    content = [[
You approach another cave entrance. This one shows signs of more organized
habitation - there's a crude wooden door partially covering the entrance.

As you get closer, you hear goblin voices arguing inside. They seem to be
fighting among themselves!

{{explored_orc_lair and "Perhaps you could use the rivalry between the orcs and goblins to your advantage?" or ""}}

**Health:** {{health}}/{{max_health}}
    ]]
})

goblin_cave:add_choice(Choice.new({
    text = "Attack while they're distracted",
    target = "attack_goblins"
}))

goblin_cave:add_choice(Choice.new({
    text = "Try to trick them by claiming the orcs sent you",
    target = "trick_goblins",
    condition = "explored_orc_lair"
}))

goblin_cave:add_choice(Choice.new({
    text = "Leave them alone for now",
    target = "cave_entrance"
}))

local attack_goblins = Passage.new({
    id = "attack_goblins",
    content = [[
You burst into the goblin lair! Four goblins are standing around a fire, arguing.
They're caught completely by surprise!

You strike down two before they even realize what's happening. The other two
grab weapons and fight back, but they're panicked and disorganized.

After a quick battle, all four goblins lie defeated.

**Damage taken:** {{has_shield and "6" or "10"}} health

Searching the lair, you find:
- 80 gold pieces
- A well-made dagger
- Stolen supplies from the Keep

**The goblin scouts are defeated!**
    ]],
    on_enter = [[
        local damage = game_state:get_variable("has_shield") and 6 or 10
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - damage))
        game_state:set_variable("gold", game_state:get_variable("gold") + 80)
        game_state:set_variable("explored_goblin_lair", true)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 3)
    ]]
})

attack_goblins:add_choice(Choice.new({
    text = "You've been defeated...",
    target = "death",
    condition = "health <= 0"
}))

attack_goblins:add_choice(Choice.new({
    text = "Return to the ravine",
    target = "cave_entrance",
    condition = "health > 0"
}))

attack_goblins:add_choice(Choice.new({
    text = "Explore deeper into the goblin territory",
    target = "goblin_deeper",
    condition = "health > 10"
}))

local trick_goblins = Passage.new({
    id = "trick_goblins",
    content = [[
You bang on the door and shout in your best orcish accent: "Message from the orc
chief! He demands tribute!"

The goblins stop arguing. After a moment, one calls back: "The orcs can go eat
rocks! We're done paying them!"

Your trick backfires - they're not falling for it. But you've learned that the
orcs and goblins are bitter enemies!

Now the goblins know someone is outside...
    ]]
})

trick_goblins:add_choice(Choice.new({
    text = "Attack while they're confused",
    target = "attack_goblins"
}))

trick_goblins:add_choice(Choice.new({
    text = "Retreat",
    target = "cave_entrance"
}))

local goblin_deeper = Passage.new({
    id = "goblin_deeper",
    content = [[
You press deeper into the goblin warren and discover their main chamber. Several
goblins cower in the corner - they've heard of your victories and are terrified!

They beg for mercy, offering you information: "The evil shrine at the end of the
ravine - it's where the real evil is! Dark priests and undead! We're just trying
to survive!"

You can spare them or finish them off.
    ]]
})

goblin_deeper:add_choice(Choice.new({
    text = "Spare them and leave",
    target = "spare_goblins"
}))

goblin_deeper:add_choice(Choice.new({
    text = "Finish them off",
    target = "slay_goblins"
}))

local spare_goblins = Passage.new({
    id = "spare_goblins",
    content = [[
You spare the remaining goblins. They're so grateful they give you what treasure
they have left and promise to leave the area.

"You're a true hero," one says. "Not like those evil priests!"

**You gained:**
- 50 gold pieces
- The respect of even your enemies
- Information about the evil shrine

**Reputation increased!**
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") + 50)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 2)
    ]]
})

spare_goblins:add_choice(Choice.new({
    text = "Return to the ravine",
    target = "cave_entrance"
}))

local slay_goblins = Passage.new({
    id = "slay_goblins",
    content = [[
You show no mercy to the goblins. They were enemies, after all.

You find their treasure hoard and take it all.

**You gained:**
- 100 gold pieces
- Various weapons and equipment

**The goblin lair is completely cleared.**
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") + 100)
    ]]
})

slay_goblins:add_choice(Choice.new({
    text = "Return to the ravine",
    target = "cave_entrance"
}))

-- ============================================================================
-- EVIL SHRINE (Final Challenge)
-- ============================================================================

local evil_shrine = Passage.new({
    id = "evil_shrine",
    content = [[
You approach the dark cave at the far end of the ravine. The air grows cold, and
an evil presence weighs on your spirit.

The entrance is carved with blasphemous symbols. Inside, you can see flickering
torchlight and hear chanting in a foul tongue.

This is the shrine of evil chaos - the source of the darkness in these caves.

{{reputation >= 5 and "Your victories have made you strong enough to face this challenge!" or "Are you truly ready for this?"}}

**Health:** {{health}}/{{max_health}}
**Reputation:** {{reputation}}
    ]]
})

evil_shrine:add_choice(Choice.new({
    text = "Enter the shrine and face the evil within",
    target = "face_evil",
    condition = "reputation >= 5"
}))

evil_shrine:add_choice(Choice.new({
    text = "You're not ready for this yet",
    target = "shrine_retreat",
    condition = "reputation < 5"
}))

evil_shrine:add_choice(Choice.new({
    text = "Retreat - this is too dangerous",
    target = "cave_entrance"
}))

local shrine_retreat = Passage.new({
    id = "shrine_retreat",
    content = [[
You sense that you're not yet strong enough to face the evil in this shrine.

Perhaps if you had defeated more enemies and gained more experience, you would
be ready for this final challenge.

**You need a reputation of at least 5 to face the shrine.**
**Current reputation: {{reputation}}**

Consider exploring the other caves first.
    ]]
})

shrine_retreat:add_choice(Choice.new({
    text = "Return to the ravine",
    target = "cave_entrance"
}))

local face_evil = Passage.new({
    id = "face_evil",
    content = [[
You stride into the shrine with determination. The walls are covered in profane
symbols, and a dark altar stands in the center of the chamber.

An evil priest in black robes turns to face you, surrounded by undead zombies!

"Foolish mortal!" he shrieks. "You dare enter the shrine of chaos?"

The zombies lurch toward you, and the priest begins chanting a dark spell!

This is the final battle!

**Health:** {{health}}/{{max_health}}
    ]]
})

face_evil:add_choice(Choice.new({
    text = "Fight with everything you have!",
    target = "final_battle"
}))

face_evil:add_choice(Choice.new({
    text = "Try to disrupt the priest's spell",
    target = "disrupt_spell"
}))

local final_battle = Passage.new({
    id = "final_battle",
    content = [[
You charge into battle against impossible odds!

The zombies claw at you, but your sword flashes, cutting them down one by one.
Your victories in the caves have made you a true warrior!

{{has_shield and "Your shield turns aside deathly blows!" or "You take several wounds from the undead!"}}

Finally, only the evil priest remains. He raises his staff to cast a final spell,
but you're faster - your blade strikes true!

The priest falls with a scream, and the shrine begins to shake. Dark energy
dissipates, and you feel the evil presence lift from the ravine.

**VICTORY!**

**You have cleansed the Caves of Chaos!**

**Final damage:** {{has_shield and "15" or "20"}} health
**Health:** {{health - (has_shield and 15 or 20)}}/{{max_health}}
    ]],
    on_enter = [[
        local damage = game_state:get_variable("has_shield") and 15 or 20
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - damage))
    ]]
})

final_battle:add_choice(Choice.new({
    text = "You've been defeated at the last moment...",
    target = "death",
    condition = "health <= 0"
}))

final_battle:add_choice(Choice.new({
    text = "Claim your victory!",
    target = "victory",
    condition = "health > 0"
}))

local disrupt_spell = Passage.new({
    id = "disrupt_spell",
    content = [[
You throw your sword at the priest, disrupting his spell!

The dark energy backfires, destroying the priest and several of his zombie
servants in a blast of dark fire!

The remaining zombies collapse as the evil magic controlling them dissipates.

You retrieve your sword and claim victory with minimal injury!

**Clever strategy!**
**Damage taken: 8 health**
    ]],
    on_enter = [[
        local health = game_state:get_variable("health")
        game_state:set_variable("health", math.max(0, health - 8))
    ]]
})

disrupt_spell:add_choice(Choice.new({
    text = "Claim your victory!",
    target = "victory"
}))

-- ============================================================================
-- ENDINGS
-- ============================================================================

local victory = Passage.new({
    id = "victory",
    content = [[
**VICTORY!**

You have cleansed the Caves of Chaos and defeated the shrine of evil!

Searching the shrine, you find considerable treasure:
- 500 gold pieces
- A magic sword +1
- Various gems and jewelry
- Ancient scrolls

**Total gold: {{gold + 500}}**

You return to the Keep as a hero! The Castellan personally thanks you and grants
you a noble title. The villagers celebrate your victory, and bards will sing of
your deeds for years to come!

**YOUR ADVENTURE IS COMPLETE!**

Final Statistics:
- Health: {{health}}/{{max_health}}
- Gold: {{gold + 500}}
- Reputation: {{reputation + 10}}
- Status: **HERO OF THE BORDERLANDS**

*THE END*
    ]],
    on_enter = [[
        game_state:set_variable("gold", game_state:get_variable("gold") + 500)
        game_state:set_variable("reputation", game_state:get_variable("reputation") + 10)
    ]]
})

local death = Passage.new({
    id = "death",
    content = [[
**YOU HAVE FALLEN**

Your adventure ends here in the darkness of the Caves of Chaos. Your body will
join the countless bones that litter the ravine.

Perhaps another hero will succeed where you failed...

Final Statistics:
- Health: 0
- Gold: {{gold}}
- Reputation: {{reputation}}
- Caves explored: {{(explored_kobold_lair and 1 or 0) + (explored_orc_lair and 1 or 0) + (explored_goblin_lair and 1 or 0)}}

{{reputation >= 3 and "You fought bravely and earned glory, even in defeat." or "Perhaps better preparation would have served you well."}}

**GAME OVER**

*THE END*
    ]]
})

-- ============================================================================
-- BUILD THE STORY
-- ============================================================================

-- Add all passages
local passages = {
    start, keep_entrance, provisioner, buy_shield, buy_potion, buy_rope,
    tavern, merchant, tavern_rumors, inn, chapel,
    to_caves_direct, to_caves, no_map, find_treasure,
    cave_entrance, kobold_cave, fight_kobolds, scare_kobolds, kobold_deeper,
    use_potion_kobolds, orc_cave, fight_orc_guards, use_potion_orcs,
    fight_orc_horde, sneak_orcs, orc_retreat, goblin_cave, attack_goblins,
    trick_goblins, goblin_deeper, spare_goblins, slay_goblins,
    evil_shrine, shrine_retreat, face_evil, final_battle, disrupt_spell,
    victory, death
}

for _, passage in ipairs(passages) do
    story:add_passage(passage)
end

-- Set starting passage
story:set_start_passage("start")

-- Return the story
return story
