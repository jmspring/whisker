# Shadows of Thornhaven - RPG Integration Plan

## Current Status (2025-10-13)

### ✅ COMPLETED
1. **Character Creation System** - Fully implemented (p099-p105)
   - 4 classes with unique stats and abilities
   - Proper stat distribution
   - Starting equipment

2. **Leveling System** - Fully implemented (p107-p112)
   - XP thresholds
   - Attribute increases
   - HP/Stamina scaling by class

3. **Skill System** - Fully implemented (p113-p119)
   - 6 skills with improvement interface
   - Skill points awarded on level-up

4. **Character Sheet** - Fully implemented (p106)
   - Complete stat display
   - Level-up notifications

5. **Quest Journal** - Fully implemented (p120)
   - Quest tracking
   - Alignment display

6. **Companion System** - Fully implemented (p121-p124)
   - Aldric the Warrior recruitment
   - Lyra the Elf recruitment
   - Companion stats and abilities

### 🔄 PARTIALLY COMPLETE

#### Skill Checks (Found: 2/10 needed)
**Already Implemented:**
- Bandit Camp (p028) - Stealth check to sneak past sentries
- General Store (p003) - Persuasion >= 3 gives 20% discount ✅ (JUST ADDED)

**Needs Addition:**
1. **Persuasion Checks** (Need 2-3 more):
   - Tavern - Convince NPCs to share information
   - Elder Hall - Negotiate better quest rewards
   - Bandit encounter - Talk your way out

2. **Perception Checks** (Need 2-3):
   - Wolf Den - Notice hidden treasure alcove
   - Tower Search - Spot the lockbox faster
   - Crypt - Find secret door

3. **Lockpicking Checks** (Need 1-2):
   - Merchant's lockbox - Pick it open if found locked
   - Treasure chests in loot areas

4. **Arcana Checks** (Need 1):
   - Shadow Temple - Understand dark magic symbols
   - Tower - Decipher mage's spellbook

5. **Medicine Checks** (Need 1):
   - Healing House - Assist Elara for discount/bonus

#### Combat Enhancement (Found: 0/15 needed)
**Current State:** Combat passages exist but lack:
- Stamina costs for special abilities
- Class-specific ability options
- Companion assistance in combat

**Combat Passages to Update:**
1. Wolf Den Fight (p024-p026)
2. Bandit Fight (p029)
3. Shadow Temple Fight (p032-p033)
4. Crypt Fight (p036)
5. Tower Fight (p040)

**Needed Enhancements:**
```
Fighter abilities:
- Power Strike (3 stamina): Double damage
- Second Wind (5 stamina): Heal self

Rogue abilities:
- Sneak Attack (2 stamina): Triple damage if undetected
- Quick Dodge (1 stamina): Avoid one attack

Cleric abilities:
- Turn Undead (4 stamina): Auto-win vs undead
- Divine Protection (2 stamina): +2 AC
- Healing Word (3 stamina): Heal mid-combat

Mage abilities:
- Magic Missile (3 stamina): Auto-hit damage
- Shield Spell (2 stamina): +4 AC
- Fireball (5 stamina): Massive damage

Companion abilities:
- If companion present, reduce damage taken
- Show companion health after combat
```

#### Alignment Tracking (Found: 3/8 needed)
**Already Tracking:**
- Bandit fight (p029) - +1 Good for stopping bandits
- Shadow fight (p033) - +3 Good for cleansing evil
- Tower fight (p040) - +2 Good for defeating shadows

**Needs Addition:**
1. Spare vs Kill choices:
   - After defeating bandits - spare leader (+2 Good) vs kill (-1 Evil)
   - Wolf den - mercy on wounded (+1 Good) vs finish off (-1 Evil)

2. Help vs Ignore:
   - Injured traveler encounter - help (+2 Good) vs rob (-3 Evil)
   - Village in need - donate gold (+1 Good) vs ignore

3. Lawful vs Chaotic:
   - Report findings to Elder (+1 Lawful) vs keep quiet
   - Follow rules vs take shortcuts (-1 Chaotic)

#### Quest Tracking (Found: Partial)
**Current:** Quests are defined, but some completion triggers missing

**Needs Addition:**
1. Merchant quest - Set quest_merchant_treasure to complete when lockbox returned
2. Healer quest - Set quest_healer_herbs to complete when herbs delivered
3. Elder quest - Already tracks (quest_clear_ruins counter)
4. Add XP rewards for quest completion

#### Equipment Progression
**Current:** Some equipment upgrades found in loot

**Needs Addition:**
1. **General Store Enhancement:**
   - Add better weapons:
     * Steel Longsword (80 gold, +2 damage)
     * Masterwork Bow (100 gold, +3 damage)
   - Add better armor:
     * Chainmail (120 gold, AC 16)
     * Plate Armor (200 gold, AC 18)

2. **Treasure Enhancement:**
   - More magical items in final areas
   - Ring of Protection in crypt ✅ (already added)
   - Amulet in temple ✅ (already added)
   - Add +1 weapons as rare drops

## Implementation Priority

### Phase 1: Combat Enhancement (HIGH PRIORITY)
**Time: 2-3 hours**
- Update all 5 combat passages
- Add stamina costs and class abilities
- Add companion combat assistance
- This dramatically improves gameplay

### Phase 2: Skill Checks (HIGH PRIORITY)
**Time: 1-2 hours**
- Add 10 skill check opportunities
- Makes skills actually useful
- Encourages diverse character builds

### Phase 3: Alignment & Quest Tracking (MEDIUM PRIORITY)
**Time: 1 hour**
- Add 5 more alignment choices
- Fix quest completion triggers
- Add quest completion XP rewards

### Phase 4: Equipment Progression (MEDIUM PRIORITY)
**Time: 30-45 minutes**
- Enhance general store inventory
- Add better loot drops
- Balance pricing

### Phase 5: Testing (HIGH PRIORITY)
**Time: 2-3 hours**
- Test all 4 character classes
- Test level-up progression
- Test quest completion
- Test combat with abilities
- Test skill checks

## Total Estimated Time: 7-10 hours

## Testing Checklist

### Character Creation
- [ ] Create Fighter - verify stats, equipment, HP
- [ ] Create Rogue - verify skills, equipment, HP
- [ ] Create Cleric - verify abilities, equipment, HP
- [ ] Create Mage - verify spells, equipment, HP, stamina

### Combat System
- [ ] Test Fighter Power Strike ability
- [ ] Test Rogue Sneak Attack
- [ ] Test Cleric Turn Undead vs shadows/undead
- [ ] Test Mage Magic Missile
- [ ] Test stamina depletion and recovery
- [ ] Test companion damage reduction

### Skill System
- [ ] Test Persuasion check with low skill (fail)
- [ ] Test Persuasion check with high skill (success)
- [ ] Test Perception check finding hidden items
- [ ] Test Lockpicking check
- [ ] Test Stealth check at bandit camp
- [ ] Test Arcana check
- [ ] Test Medicine check

### Progression
- [ ] Earn 100 XP and level up to 2
- [ ] Test attribute increases
- [ ] Test skill point spending
- [ ] Test HP/stamina increases by class

### Quests
- [ ] Complete merchant lockbox quest
- [ ] Complete healer herb quest
- [ ] Complete elder main quest (all 5 sites)
- [ ] Verify quest journal updates
- [ ] Verify XP rewards

### Alignment
- [ ] Make good choices - verify Good alignment
- [ ] Make evil choices - verify Evil alignment
- [ ] Make lawful choices - verify Lawful alignment
- [ ] Make chaotic choices - verify Chaotic alignment

### Companions
- [ ] Recruit Aldric - verify stats
- [ ] Test Aldric in combat
- [ ] Recruit Lyra - verify stats (if possible to change)
- [ ] Test companion loyalty system

### Equipment
- [ ] Buy shield from store
- [ ] Find masterwork sword in loot
- [ ] Test AC calculations
- [ ] Test attack/damage bonuses

### Victory Condition
- [ ] Clear all 5 locations
- [ ] Return to Elder
- [ ] Verify victory screen with stats

## Notes

- Story is 945 lines, 124 passages
- All RPG system infrastructure is in place
- Main work is integrating systems into story passages
- Template processor is working correctly
- Character creation is mandatory (redirects if not created)
- Variables are properly initialized

## Next Session Plan

1. **Start with combat enhancement** - Most impactful
2. **Add skill checks** - Makes skills useful
3. **Test thoroughly** - Ensure balance
4. **Commit and PR** - Get it merged

