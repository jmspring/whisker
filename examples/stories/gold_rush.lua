-- examples/stories/gold_rush.lua
-- A story about a prospector seeking gold while a corrupt sheriff tries to distract him
-- Features branching choices with consequences

local Story = require("src.core.story")
local Passage = require("src.core.passage")
local Choice = require("src.core.choice")

-- Create the story
local story = Story.new({
    title = "Gold Rush Fever",
    author = "whisker",
    ifid = "GOLD-RUSH-001",
    version = "1.0"
})

-- Passage 1: Start
local start = Passage.new({
    id = "start",
    content = [[
You're Silas McCready, a weathered prospector who's spent three long months
searching for gold in the rugged hills outside Deadwood. Your supplies are running
low, but you've finally found a promising claim - a creek bed that sparkles with
golden flecks and a rocky outcrop that might contain a rich vein.

Today, you need to decide where to focus your efforts.
    ]]
})

start:add_choice(Choice.new({
    text = "Start panning in the creek",
    target = "creek_panning"
}))

start:add_choice(Choice.new({
    text = "Begin digging at the rocky outcrop",
    target = "rock_digging"
}))

start:add_choice(Choice.new({
    text = "Scout both locations first",
    target = "scouting"
}))

-- Passage 2: Creek Panning
local creek_panning = Passage.new({
    id = "creek_panning",
    content = [[
You wade into the cold creek, your pan in hand. The icy water numbs your legs
as you scoop up sediment and begin the rhythmic swirling motion. After an hour,
you've found several small flakes of gold - not a fortune, but promising.

As you work, you notice a rider approaching from town. It's Sheriff Blackwood,
a man known more for his greed than his justice. Behind him rides a woman in
a crimson dress - you recognize her as Ruby, one of the girls from the saloon.

"McCready!" the Sheriff calls out. "Working hard, I see. Mind if we have a word?"
    ]]
})

creek_panning:add_choice(Choice.new({
    text = "Keep working and ignore them",
    target = "ignore_sheriff_creek"
}))

creek_panning:add_choice(Choice.new({
    text = "Stop and talk to the Sheriff",
    target = "talk_to_sheriff"
}))

creek_panning:add_choice(Choice.new({
    text = "Ask what this is about",
    target = "confront_sheriff"
}))

-- Passage 3: Rock Digging
local rock_digging = Passage.new({
    id = "rock_digging",
    content = [[
You grab your pickaxe and head to the rocky outcrop. The stone here is hard
and unforgiving, but there's something about the quartz veining that suggests
gold might be trapped within.

After two hours of hard labor, you've made a promising excavation. You can see
flecks of gold embedded in the exposed rock face. This could be the motherlode!

As you swing your pickaxe for another strike, you hear horses approaching.
Sheriff Blackwood rides up with a beautiful woman in a red dress beside him.
You recognize her as Ruby from the Dusty Rose Saloon.

"McCready!" the Sheriff shouts. "That's mighty hard work you're doing. Ruby here
was just saying how she'd love some company. What say you take a break?"
    ]]
})

rock_digging:add_choice(Choice.new({
    text = "Keep digging and wave them off",
    target = "ignore_sheriff_dig"
}))

rock_digging:add_choice(Choice.new({
    text = "Take a break and talk to them",
    target = "talk_to_sheriff"
}))

rock_digging:add_choice(Choice.new({
    text = "Demand to know what they want",
    target = "confront_sheriff"
}))

-- Passage 4: Scouting
local scouting = Passage.new({
    id = "scouting",
    content = [[
You decide to be methodical. You spend the morning examining both locations,
taking careful notes. The creek shows consistent gold flakes - a steady income
if you're patient. The rocky outcrop could contain a major vein, but it would
require hard labor to extract.

As you're comparing your options, Sheriff Blackwood rides up with a woman in
a striking red dress. You know Ruby from the saloon - she's smart and has
turned down more men than most.

"Well, well," the Sheriff says with a crooked smile. "Planning out your fortune,
McCready? Ruby here was just saying she'd never seen your claim. Thought maybe
you could show her around while I... inspect the area for claim jumping."
    ]]
})

scouting:add_choice(Choice.new({
    text = "Refuse and ask them to leave",
    target = "confront_sheriff"
}))

scouting:add_choice(Choice.new({
    text = "Agree to show Ruby around",
    target = "ruby_distraction"
}))

scouting:add_choice(Choice.new({
    text = "Suggest they all leave together",
    target = "talk_to_sheriff"
}))

-- Passage 5: Ignore Sheriff at Creek
local ignore_sheriff_creek = Passage.new({
    id = "ignore_sheriff_creek",
    content = [[
"I'm busy, Sheriff," you call out, continuing to pan. "Got no time for socializing."

The Sheriff's face darkens. "Now that's mighty unfriendly, McCready. Here I am,
trying to ensure your claim is properly registered and protected, and you're
too busy to show respect?"

Ruby dismounts and walks to the creek's edge. "Silas," she says softly, using
your first name. "The Sheriff just wants to help. And I... I wanted to see you."

There's something in her eyes - a warning, perhaps? You notice the Sheriff's
hand resting on his pistol.
    ]]
})

ignore_sheriff_creek:add_choice(Choice.new({
    text = "Stay focused on panning, be respectful but firm",
    target = "stay_focused_creek"
}))

ignore_sheriff_creek:add_choice(Choice.new({
    text = "Talk to Ruby and see what she really wants",
    target = "ruby_warning"
}))

ignore_sheriff_creek:add_choice(Choice.new({
    text = "Confront the Sheriff's veiled threat",
    target = "confront_threat"
}))

-- Passage 6: Ignore Sheriff at Dig Site
local ignore_sheriff_dig = Passage.new({
    id = "ignore_sheriff_dig",
    content = [[
"Not interested, Sheriff!" you shout, swinging your pickaxe again. The clang
of metal on stone echoes across the hillside.

The Sheriff's expression hardens. "You know, McCready, I've been hearing
concerns about your claim. Some folks say you might be on land that belongs
to the mining company."

Ruby slides off her horse gracefully. "Silas," she calls sweetly, "why don't
you take a break? You look exhausted. I brought some fresh water and food
from town."

Something about this feels wrong. The Sheriff is smirking, and Ruby's smile
doesn't reach her eyes.
    ]]
})

ignore_sheriff_dig:add_choice(Choice.new({
    text = "Keep digging - you're close to something big",
    target = "stay_focused_dig"
}))

ignore_sheriff_dig:add_choice(Choice.new({
    text = "Accept Ruby's offer and talk to her",
    target = "ruby_warning"
}))

ignore_sheriff_dig:add_choice(Choice.new({
    text = "Challenge the Sheriff's claim about your land",
    target = "confront_threat"
}))

-- Passage 7: Talk to Sheriff
local talk_to_sheriff = Passage.new({
    id = "talk_to_sheriff",
    content = [[
You set down your tools and approach them. "What's this about, Sheriff?"

Blackwood grins. "Just being neighborly, McCready. Ruby here mentioned she'd
never seen a real mining operation. Thought maybe you could show her the ropes
while I... make sure everything's legal with your claim."

Ruby gives you an apologetic look. "I really am curious about prospecting,
Silas. The Sheriff was kind enough to offer me a ride out here."

The Sheriff dismounts and starts walking toward your equipment. "Mind if I
take a look at your papers? Just routine, you understand."
    ]]
})

talk_to_sheriff:add_choice(Choice.new({
    text = "Show Ruby around while the Sheriff checks papers",
    target = "ruby_distraction"
}))

talk_to_sheriff:add_choice(Choice.new({
    text = "Keep an eye on the Sheriff instead",
    target = "watch_sheriff"
}))

talk_to_sheriff:add_choice(Choice.new({
    text = "Refuse to let him search without proper authority",
    target = "stand_ground"
}))

-- Passage 8: Confront Sheriff
local confront_sheriff = Passage.new({
    id = "confront_sheriff",
    content = [[
"I know your game, Blackwood," you say firmly. "You're trying to distract me
so you can stake a claim to my find. Ruby, I don't know what he's promised you,
but you're better than being his pawn."

The Sheriff's hand moves to his gun. "Careful, McCready. That sounds like you're
accusing a lawman of corruption."

Ruby steps between you both. "Stop! Silas, you're right. He offered me money
to keep you busy while he... while he does something to your claim. But I couldn't
do it. I tried to warn you with my eyes."

"Ruby!" the Sheriff snarls. "You just cost yourself a month's wages!"
    ]]
})

confront_sheriff:add_choice(Choice.new({
    text = "Stand with Ruby against the Sheriff",
    target = "ally_with_ruby"
}))

confront_sheriff:add_choice(Choice.new({
    text = "Draw your weapon and defend your claim",
    target = "shootout"
}))

confront_sheriff:add_choice(Choice.new({
    text = "Propose a deal with the Sheriff",
    target = "negotiate"
}))

-- Passage 9: Ruby Distraction
local ruby_distraction = Passage.new({
    id = "ruby_distraction",
    content = [[
You walk Ruby toward the creek, explaining how to pan for gold. She's surprisingly
attentive, asking good questions. But you keep glancing back at the Sheriff,
who is examining your dig site very carefully - too carefully.

"Silas," Ruby whispers urgently, "he's planning to plant fake boundary markers
to claim part of your land. I tried to refuse to help him, but he threatened
to run me out of town. You need to stop him NOW."

You turn to see the Sheriff hammering something into the ground near your
richest vein of rock.
    ]]
})

ruby_distraction:add_choice(Choice.new({
    text = "Run back and stop the Sheriff",
    target = "stop_sheriff"
}))

ruby_distraction:add_choice(Choice.new({
    text = "Thank Ruby and witness what the Sheriff is doing",
    target = "witness_crime"
}))

ruby_distraction:add_choice(Choice.new({
    text = "Let him plant the marker and document it as evidence",
    target = "gather_evidence"
}))

-- Passage 10: Stay Focused Creek
local stay_focused_creek = Passage.new({
    id = "stay_focused_creek",
    content = [[
"Sheriff, I mean no disrespect, but this claim is legally mine and I'm working
it. If you have official business, come back with proper documentation."

You continue panning, and your persistence pays off. Your next pan contains
a nugget the size of your thumb! You carefully pocket it while trying to look
casual.

The Sheriff, seeing he's not making progress, grows angry. "Fine, McCready.
But don't come crying to me when claim jumpers show up. Ruby, we're leaving."

As they ride away, Ruby drops a small piece of paper. You retrieve it:
"He plans to report your claim as abandoned. File in town today! - R"
    ]]
})

stay_focused_creek:add_choice(Choice.new({
    text = "Ride to town immediately to protect your claim",
    target = "file_claim"
}))

stay_focused_creek:add_choice(Choice.new({
    text = "Keep working and gather more gold as evidence",
    target = "gather_gold"
}))

stay_focused_creek:add_choice(Choice.new({
    text = "Set a trap for claim jumpers",
    target = "set_trap"
}))

-- Passage 11: Stay Focused Dig
local stay_focused_dig = Passage.new({
    id = "stay_focused_dig",
    content = [[
You ignore them both and swing your pickaxe with renewed vigor. CRACK! The
rock face splits open, revealing a thick vein of gold-bearing quartz that
runs deep into the hillside.

"Holy Moses..." you breathe.

The Sheriff sees it too. His eyes widen with greed. "Now, McCready, let's talk
partnership. That's too much gold for one man to work. I could provide...
protection."

Ruby grabs the Sheriff's arm. "We should go, Sheriff. The man's clearly busy."

"Quiet!" he snaps at her, not taking his eyes off the gold.
    ]]
})

stay_focused_dig:add_choice(Choice.new({
    text = "Refuse and order them off your claim",
    target = "defend_claim"
}))

stay_focused_dig:add_choice(Choice.new({
    text = "Pretend the gold is less impressive than it is",
    target = "downplay_find"
}))

stay_focused_dig:add_choice(Choice.new({
    text = "Offer Ruby a share, not the Sheriff",
    target = "partner_with_ruby"
}))

-- Passage 12: Ruby Warning
local ruby_warning = Passage.new({
    id = "ruby_warning",
    content = [[
You climb out of the creek (or step away from your dig) and approach Ruby,
accepting the water she offers.

"Thank you, Ruby," you say quietly. "What's really going on here?"

She glances at the Sheriff, who's pretending to study the horizon. "He knows
you've found something valuable. He wants me to distract you while he tampers
with your claim markers or your equipment. Silas, I don't want any part of
his schemes. I came to warn you."

The Sheriff calls out, "Ruby! Stop boring the man with gossip and show him
that picnic basket!"

Ruby whispers, "There's a gun in the basket. I thought you might need it."
    ]]
})

ruby_warning:add_choice(Choice.new({
    text = "Take the gun and confront the Sheriff",
    target = "armed_confrontation"
}))

ruby_warning:add_choice(Choice.new({
    text = "Thank Ruby and send them both away",
    target = "dismiss_both"
}))

ruby_warning:add_choice(Choice.new({
    text = "Propose that Ruby stay and help you work the claim",
    target = "partner_with_ruby"
}))

-- Passage 13: Confront Threat
local confront_threat = Passage.new({
    id = "confront_threat",
    content = [[
"Are you threatening me, Sheriff? Because if you are, I'd remind you that
claim jumping is a hanging offense, even for lawmen who think they're above
the law."

The Sheriff's face flushes red. "Why you—"

"He's not here legally!" Ruby suddenly shouts. "Sheriff Blackwood was suspended
last week for extortion! The judge is coming to Deadwood tomorrow to investigate.
He's not even a real sheriff anymore!"

Blackwood wheels on her. "You little—"

"It's true," she continues, backing away from him. "I heard it from the
telegraph operator. You're finished, Blackwood. Leave this man alone."
    ]]
})

confront_threat:add_choice(Choice.new({
    text = "Order Blackwood off your claim immediately",
    target = "victory_order"
}))

confront_threat:add_choice(Choice.new({
    text = "Offer to forget this if he leaves quietly",
    target = "merciful_victory"
}))

confront_threat:add_choice(Choice.new({
    text = "Detain him until the real law arrives",
    target = "citizens_arrest"
}))

-- Passage 14: Watch Sheriff
local watch_sheriff = Passage.new({
    id = "watch_sheriff",
    content = [[
"Ruby, I appreciate the visit, but I need to keep an eye on my equipment.
Sheriff, I'll come with you while you check those papers."

The Sheriff frowns but can't refuse without revealing his true intentions.
You stay close as he makes a show of examining your claim documents.

Meanwhile, Ruby quietly scoops up a pan of creek sediment and swirls it. Her
eyes widen - she's found gold on her first try!

"Silas," she says excitedly, "is this...?"

The Sheriff sees it too, and his expression darkens. "McCready, I'm going to
need to see your claim boundaries. There might be... irregularities."
    ]]
})

watch_sheriff:add_choice(Choice.new({
    text = "Show him the boundaries, you know they're correct",
    target = "show_boundaries"
}))

watch_sheriff:add_choice(Choice.new({
    text = "Refuse until he gets a proper warrant",
    target = "stand_ground"
}))

watch_sheriff:add_choice(Choice.new({
    text = "Offer to show Ruby how to pan instead",
    target = "teach_ruby"
}))

-- Passage 15: Stand Ground
local stand_ground = Passage.new({
    id = "stand_ground",
    content = [[
"Sheriff, unless you have a warrant or a court order, you're going to have to
leave my claim. This is private property, legally registered and properly marked."

Blackwood's hand hovers over his pistol. "You refusing a lawful order, boy?"

"I'm refusing an illegal search," you reply calmly. "Ruby is witness to this
conversation. If anything happens to me or my claim, she knows exactly what
you threatened."

Ruby nods nervously. "It's true, Sheriff. Maybe we should just go."

The Sheriff glares at both of you, calculating his options. After a long moment,
he spits on the ground.

"This ain't over, McCready. Not by a long shot." He mounts his horse.

Ruby starts to follow, then turns back. "I'm not going with you, Blackwood.
I'll walk back to town."
    ]]
})

stand_ground:add_choice(Choice.new({
    text = "Offer to escort Ruby back to town safely",
    target = "escort_ruby"
}))

stand_ground:add_choice(Choice.new({
    text = "Invite Ruby to stay and learn prospecting",
    target = "teach_ruby"
}))

stand_ground:add_choice(Choice.new({
    text = "Return to work, let Ruby make her own way",
    target = "work_alone"
}))

-- ENDINGS

-- Ending 1: Ally with Ruby
local ally_with_ruby = Passage.new({
    id = "ally_with_ruby",
    content = [[
"Ruby's right," you say firmly. "And I'm grateful she chose honesty over your
blood money, Sheriff. Now get off my claim before I report you to the territorial
marshal."

Blackwood realizes he's cornered. With Ruby as a witness to his attempted fraud,
he can't risk violence. He mounts his horse in fury.

"You'll both regret this," he snarls before riding off.

Ruby looks at you with relief. "Thank you for believing me, Silas."

Over the following weeks, you and Ruby work the claim together. She proves to be
a quick learner and hard worker. The gold you extract is enough to buy a proper
mining operation.

When the territorial judge arrives and arrests Blackwood on multiple charges,
Ruby's testimony is crucial. As a reward, the judge validates your claim boundaries.

Two years later, the McCready-Ruby Mining Company is one of the most successful
operations in the territory, and your partnership has become something more...

**THE BEST ENDING - You found gold and true partnership!**

*THE END*
    ]]
})

-- Ending 2: Shootout
local shootout = Passage.new({
    id = "shootout",
    content = [[
You reach for your pistol, but Blackwood is faster. The corrupt sheriff has
drawn his gun before your hand touches the grip.

"Don't be a fool, McCready," he warns.

Ruby screams and tackles the Sheriff's arm just as he fires. The shot goes wide,
giving you time to dive behind a rock. Return fire echoes across the hills.

The gunfight is brief but intense. In the end, you manage to wound Blackwood in
the shoulder. He drops his gun and surrenders.

When the territorial marshal arrives to investigate the gunshots, Ruby testifies
to Blackwood's corruption. The former sheriff is arrested and you keep your claim.

However, the violence attracts unwanted attention. Other prospectors and mining
companies take interest in your claim, and you spend years fighting legal battles
instead of mining gold.

**ENDING - Justice served, but at a cost.**

*THE END*
    ]]
})

-- Ending 3: Negotiate
local negotiate = Passage.new({
    id = "negotiate",
    content = [[
"Sheriff, let's be reasonable men. I'll give you 10% of what I find if you
provide legitimate protection and keep claim jumpers away."

Blackwood considers this, his greed warring with his pride. "Twenty percent."

"Fifteen, and that's my final offer."

"Deal," he agrees.

Ruby looks disappointed. "Silas, you can't trust him..."

Over the next few months, the arrangement works - barely. Blackwood does keep
other thieves away, but he constantly tries to renegotiate for a bigger share.
The gold you find is substantial, but you're always looking over your shoulder.

Eventually, you sell the claim to a mining company and leave the territory,
reasonably wealthy but without peace of mind.

**ENDING - Compromise brings gold but not satisfaction.**

*THE END*
    ]]
})

-- Ending 4: Stop Sheriff
local stop_sheriff = Passage.new({
    id = "stop_sheriff",
    content = [[
You sprint back to the dig site, Ruby running beside you.

"Blackwood! Step away from my claim!"

The Sheriff whirls around, a stake in his hand. "Just marking some boundaries,
McCready. Nothing illegal about that."

"Those aren't the real boundaries and you know it!"

Ruby points at the stake. "I can testify to exactly where he's placing that
marker. That's fraud, Sheriff!"

Caught in the act with a witness, Blackwood has no choice but to drop the stake
and leave. He rides off cursing, but his plan is foiled.

You thank Ruby profusely and offer her a job as your partner. Together, you work
the claim properly and file all the correct documentation in town.

The gold deposit proves to be modestly profitable - enough to set you both up
with a comfortable life, if not spectacular riches.

**GOOD ENDING - Honesty and vigilance pay off.**

*THE END*
    ]]
})

-- Ending 5: Witness Crime
local witness_crime = Passage.new({
    id = "witness_crime",
    content = [[
"Ruby, watch carefully and remember exactly what you see."

Together, you observe as Blackwood hammers in a false boundary marker, placing
it deliberately within your claimed territory to create a dispute he can exploit.

"Got it," Ruby whispers. "I can testify to this."

When Blackwood finishes and turns around smugly, you're both standing there
with arms crossed.

"Enjoy your little project, Sheriff?" you ask.

His face pales when he realizes you both watched everything.

You ride to town that same day and report his actions to the territorial marshal.
With Ruby's testimony and the physical evidence of the fraudulent marker, Blackwood
is arrested.

Your claim is fully validated, and you find enough gold to live comfortably. You
offer Ruby a share of the profits for her help, which she gratefully accepts.

**VERY GOOD ENDING - Justice triumphs through smart planning.**

*THE END*
    ]]
})

-- Ending 6: Gather Evidence
local gather_evidence = Passage.new({
    id = "gather_evidence",
    content = [[
"Let him do it," you whisper to Ruby. "But you're my witness to exactly what
he's doing and where."

Ruby nods, understanding your plan.

The Sheriff plants his false marker and even takes a moment to rough it up so
it looks old. You both watch silently from a distance.

Later that day, you ride to town and file a formal complaint with detailed
measurements and Ruby's sworn testimony. When the territorial judge investigates,
he finds Blackwood's marker is brand new and in the wrong location.

Blackwood is arrested for fraud and attempted claim jumping. The judge is so
impressed by your careful evidence gathering that he offers you a position as
a mining claims inspector.

You accept, and Ruby becomes your assistant. You both earn steady income while
still working your claim in your spare time.

**EXCELLENT ENDING - Patience and evidence collection win the day.**

*THE END*
    ]]
})

-- Ending 7: File Claim
local file_claim = Passage.new({
    id = "file_claim",
    content = [[
You immediately pack up your most valuable tools and the gold you've found,
then ride hard to Deadwood.

At the claims office, you find that Blackwood has indeed tried to file a false
report of abandonment - dated for tomorrow. You're just in time to prevent it!

You file a formal complaint and show your gold samples as proof of active mining.
The clerk validates your claim and notes Blackwood's attempted fraud.

When the territorial marshal hears about this, Blackwood is arrested. Your claim
is secure.

You return to find your camp untouched - Ruby apparently warned off any claim
jumpers Blackwood might have sent.

The gold deposit proves to be excellent. You strike it rich and eventually thank
Ruby by funding her own business - a respectable boarding house in town.

**EXCELLENT ENDING - Quick action saves your fortune!**

*THE END*
    ]]
})

-- Ending 8: Gather Gold
local gather_gold = Passage.new({
    id = "gather_gold",
    content = [[
You decide the best evidence is gold itself. You work the creek with intense
focus for the next three days, collecting nuggets and flakes.

On the third day, a gang of claim jumpers arrives - clearly sent by Blackwood.
But your camp is well-prepared, and you defend it successfully.

When you finally ride to town with a pouch full of gold, Blackwood's fraud is
obvious - no abandoned claim produces this much wealth!

However, the delay costs you. The claim jumpers damaged some of your equipment,
and legal fees to prosecute Blackwood eat into your profits.

You end up with a moderate fortune - comfortable but not wealthy.

**GOOD ENDING - You got gold, but timing matters.**

*THE END*
    ]]
})

-- Ending 9: Set Trap
local set_trap = Passage.new({
    id = "set_trap",
    content = [[
You prepare for claim jumpers by setting up camp in a more defensible position
and rigging some warning systems with bells and tripwires.

Sure enough, three nights later, a gang of men arrives to "claim" your abandoned
site. Your warning bells give you time to prepare.

You fire warning shots and shout that you're defending your legal claim. The
jumpers, realizing you're not absent, retreat.

However, in your focus on defense, you don't realize Blackwood has filed false
paperwork in town. When you finally return to Deadwood, your claim has been
awarded to a mining company that paid Blackwood a bribe.

Legal battles ensue. You eventually win, but years have passed and much of the
gold has been extracted by others.

**MIXED ENDING - You protected your claim but lost your fortune.**

*THE END*
    ]]
})

-- Ending 10: Defend Claim
local defend_claim = Passage.new({
    id = "defend_claim",
    content = [[
"This is my claim, legally filed and registered. Neither of you have any right
to be here. Sheriff, that includes you. Now get off my land."

Blackwood's face darkens. "You're making a mistake, McCready."

"The only mistake would be letting a corrupt lawman steal my claim. Ruby, you're
welcome to stay if you want to learn honest prospecting. Blackwood, you're not."

The Sheriff realizes he can't do anything with Ruby as a witness. He rides off
in fury.

Ruby stays and helps you work the claim. The vein you discovered is incredibly
rich - one of the biggest strikes in the territory's history.

With Ruby as your business partner, you establish a legitimate mining operation.
When Blackwood tries to cause trouble later, Ruby's testimony to the territorial
marshal gets him arrested.

You both become wealthy and respected members of the community.

**BEST ENDING - You stood your ground and won everything!**

*THE END*
    ]]
})

-- Ending 11: Downplay Find
local downplay_find = Passage.new({
    id = "downplay_find",
    content = [[
You shrug. "Looks better than it is. Probably just gold plate, not a true vein.
I've been fooled before."

Blackwood squints at the rock. "Let me be the judge of that."

He dismounts and approaches your excavation. As he does, you notice Ruby
subtly shaking her head at you - trying to warn you of something.

The Sheriff examines the vein and realizes you're lying. "This is pure gold,
McCready. And you're a fool if you think I'll let you keep it."

He draws his gun. Ruby screams.

You have no choice but to fight. The struggle is desperate, and while you
eventually overcome Blackwood, the violence attracts attention from other
prospectors who swarm the area.

Your claim becomes contested by dozens of parties. The legal mess takes years
to resolve, and by the time you win, the gold is largely gone.

**BAD ENDING - Deception backfired.**

*THE END*
    ]]
})

-- Ending 12: Partner with Ruby
local partner_with_ruby = Passage.new({
    id = "partner_with_ruby",
    content = [[
You look at Ruby. "You tried to warn me. You came here to help when you could
have just gone along with his scheme. Ruby, how would you like to be my partner?
Fifty-fifty split of whatever we find."

Ruby's eyes widen. "Are you serious?"

"Dead serious. I need someone I can trust, and you've proven you're honest."

The Sheriff sputters. "Now wait just a minute—"

"You have no claim here, Blackwood. Ruby does. She helped me see through your
scheme, and she'll help me work this claim. Now leave."

Faced with two witnesses who know his plans, Blackwood has no choice but to
retreat.

You and Ruby work the claim together. Her sharp mind and your prospecting skills
make a formidable team. The gold you find makes you both wealthy.

You establish the town's first woman-owned mining company, with Ruby as president.
It becomes a model for fair labor practices and community investment.

Years later, your partnership becomes a marriage, and you build a life together
built on mutual respect and honesty.

**BEST ENDING - Partnership, prosperity, and true love!**

*THE END*
    ]]
})

-- Ending 13: Armed Confrontation
local armed_confrontation = Passage.new({
    id = "armed_confrontation",
    content = [[
You discreetly take the gun from the basket and tuck it into your belt.

"Sheriff," you say loudly, "I know what you're planning. Ruby's told me everything.
You need to leave now."

Blackwood's eyes narrow as he notices the gun. "So it's like that, is it?"

"It is. I'm defending my legal claim. If you try anything, Ruby's my witness."

The Sheriff calculates his odds. With Ruby clearly on your side and you now armed,
he can't risk violence. He'd lose either way.

"Fine," he spits. "But this territory ain't big enough for both of us, McCready."

He rides off, leaving Ruby behind.

You thank Ruby and offer her a job helping with the claim. She accepts. Together
you work the site and find substantial gold.

Blackwood eventually gets arrested for other crimes. You and Ruby remain friends
and business partners for years, both prospering from the honest work.

**VERY GOOD ENDING - Strength and allies secure your future.**

*THE END*
    ]]
})

-- Ending 14: Dismiss Both
local dismiss_both = Passage.new({
    id = "dismiss_both",
    content = [[
"Thank you for the warning, Ruby, and for the... insurance," you say quietly,
leaving the gun in the basket. "But I handle my problems my own way. You should
both leave before this gets uglier."

Ruby looks hurt. "I was trying to help..."

"I know, and I appreciate it. But I work alone."

She nods sadly and remounts her horse. The Sheriff, sensing his plan has failed,
follows her back to town.

You return to your work with renewed vigor. Over the following months, you
successfully extract a good amount of gold - not a fortune, but enough to be
comfortable.

However, you always wonder what might have been if you'd trusted Ruby and let
her help. You hear she started her own successful business in town, and you
occasionally regret being so independent.

**DECENT ENDING - You succeeded alone, but missed out on something more.**

*THE END*
    ]]
})

-- Ending 15: Victory Order
local victory_order = Passage.new({
    id = "victory_order",
    content = [[
"You heard the lady, Blackwood - or should I just call you Mister Blackwood now?
You're not a sheriff anymore. You're just a criminal trespassing on my claim.
Get out before I exercise my legal right to defend my property."

Blackwood's bluster deflates. Without his badge, he's just another crook, and
Ruby's revelation has stripped away his authority.

"You'll pay for this," he mutters, but he mounts his horse and rides away.

Ruby stays to help you. "I couldn't stand by and watch him steal from honest
people anymore."

Together, you work the claim and strike a significant amount of gold. When the
territorial judge arrives, Ruby's testimony not only gets Blackwood arrested but
also earns you both a reputation for integrity.

Your mining operation flourishes, and you become respected pillars of the community.

**EXCELLENT ENDING - Justice and fortune both achieved!**

*THE END*
    ]]
})

-- Ending 16: Merciful Victory
local merciful_victory = Passage.new({
    id = "merciful_victory",
    content = [[
"Blackwood, I don't want trouble. If you ride out now and never come back to my
claim, I'll forget this happened. Ruby and I won't testify about what you tried
to do here. You can leave the territory with your reputation intact."

The former sheriff glares at you, then at Ruby. "You're letting me go?"

"I'm giving you a chance to start over somewhere else. Take it."

After a long moment, Blackwood nods curtly and rides away.

Ruby watches him go. "That was generous of you, Silas. Maybe too generous."

"Maybe. But I'd rather mine gold than fight legal battles."

You and Ruby work the claim together. The gold you find is substantial, and
without Blackwood's interference, you can focus on honest work.

Your mercy proves wise - Blackwood never returns, and the territorial judge never
investigates your claim. You and Ruby build a prosperous mining operation in peace.

**VERY GOOD ENDING - Mercy and wisdom bring lasting success.**

*THE END*
    ]]
})

-- Ending 17: Citizens Arrest
local citizens_arrest = Passage.new({
    id = "citizens_arrest",
    content = [[
"Ruby, help me secure him. As a citizen of this territory, I'm placing this
man under arrest for attempted fraud and corruption."

Blackwood struggles, but without his authority and with Ruby helping you, you
manage to restrain him.

"You can't do this!" he shouts.

"I just did. Ruby, ride to town and bring back the territorial marshal."

Ruby gallops off while you guard Blackwood at gunpoint. It's a tense wait, but
she returns within hours with the marshal and two deputies.

The marshal is impressed by your citizen's arrest. "Not many men would have the
courage to arrest a corrupt lawman, even a suspended one."

Blackwood is taken away to face trial. Your claim is fully validated, and the
territorial government offers you a reward for exposing corruption.

The gold you mine makes you comfortable, but the reward and Ruby's testimony
make you both heroes in the territory. You're eventually elected as a territorial
representative, bringing honest governance to the region.

**EXCELLENT ENDING - Justice, gold, and civic honor!**

*THE END*
    ]]
})

-- Ending 18: Show Boundaries
local show_boundaries = Passage.new({
    id = "show_boundaries",
    content = [[
"Come on, Sheriff. I'll show you every boundary marker. They're all legal and
properly placed."

You walk him around the claim, pointing out each registered marker. As you do,
Ruby quietly pans the creek and collects several small nuggets as evidence.

The Sheriff can't find any fault with your boundaries - they're perfect. He
grows increasingly frustrated.

"Seems like everything's in order," you say pleasantly. "Anything else?"

Blackwood glares at you, knowing he's been outmaneuvered. "No. I suppose not."

As they prepare to leave, Ruby shows you her pan. "I found these in just a
few minutes, Silas. This is a rich claim!"

The Sheriff overhears and his face darkens, but there's nothing he can do.

After they leave, you find that Ruby dropped her nuggets on purpose - to show
you and frustrate Blackwood simultaneously.

You work the claim successfully and strike modest riches. Ruby visits often,
and eventually you offer her a partnership in the operation.

**GOOD ENDING - Preparation and cleverness win the day.**

*THE END*
    ]]
})

-- Ending 19: Teach Ruby
local teach_ruby = Passage.new({
    id = "teach_ruby",
    content = [[
"Sheriff, your 'inspection' can wait. Ruby, would you like to learn how to
actually pan for gold instead of just watching?"

Ruby's face lights up. "I'd love to!"

You show her the proper technique - how to swirl the pan, how to identify
gold versus pyrite, how to read the creek bed. She's a natural student.

Blackwood, seeing his plan failing, grows impatient. "I don't have time for
this nonsense!"

"Then leave," you suggest. "Your 'inspection' was never official anyway."

Frustrated and outmaneuvered, the Sheriff rides off alone.

Ruby stays for several hours, learning and finding small amounts of gold. "This
is wonderful! I've never done anything like this."

You see an opportunity. "How would you like a job? I could use a partner who's
smart and trustworthy."

Ruby accepts enthusiastically. Together, you build a successful mining operation.
She proves to be excellent at the business side, while you handle the prospecting.

**VERY GOOD ENDING - Teaching and trust create lasting partnership.**

*THE END*
    ]]
})

-- Ending 20: Escort Ruby
local escort_ruby = Passage.new({
    id = "escort_ruby",
    content = [[
"Ruby, it's not safe for you to walk back alone. Let me saddle up and escort
you to town. I need to file some papers anyway."

She smiles gratefully. "Thank you, Silas."

On the ride to town, you learn more about Ruby. She's smart, ambitious, and
tired of working in the saloon. She dreams of opening a legitimate business.

"What if," you propose, "you became my business partner? I need someone to
handle the town side of things - registrations, supplies, selling the gold.
I'd give you a percentage."

Ruby's eyes widen. "You'd trust me with that?"

"You stood up to Blackwood for me. Yes, I trust you."

She accepts. Your partnership thrives. Ruby handles all the town business with
sharp negotiating skills, while you work the claim. The gold you find makes
you both prosperous.

Within a year, Ruby has opened her own assay office in town, with your mining
operation as her primary client. You've both achieved your dreams.

**EXCELLENT ENDING - Partnership and mutual support bring success to both!**

*THE END*
    ]]
})

-- Ending 21: Work Alone
local work_alone = Passage.new({
    id = "work_alone",
    content = [[
Ruby walks back to town alone while you return to your work. You're a solitary
man by nature, and you prefer it that way.

Over the following months, you work the claim diligently. The gold you find is
decent - enough to live comfortably, though not enough to be truly wealthy.

You hear news from town occasionally. Ruby left the saloon and started a
boarding house, which is doing well. Blackwood was eventually arrested for
other crimes and run out of the territory.

You sometimes wonder if you should have taken Ruby up on her offer of friendship
or partnership. But you have your independence, your claim, and enough gold to
be content.

It's a solitary life, but it's yours.

**DECENT ENDING - Independence brings modest success and solitude.**

*THE END*
    ]]
})

-- Add all passages to the story
story:add_passage(start)
story:add_passage(creek_panning)
story:add_passage(rock_digging)
story:add_passage(scouting)
story:add_passage(ignore_sheriff_creek)
story:add_passage(ignore_sheriff_dig)
story:add_passage(talk_to_sheriff)
story:add_passage(confront_sheriff)
story:add_passage(ruby_distraction)
story:add_passage(stay_focused_creek)
story:add_passage(stay_focused_dig)
story:add_passage(ruby_warning)
story:add_passage(confront_threat)
story:add_passage(watch_sheriff)
story:add_passage(stand_ground)

-- Add all ending passages
story:add_passage(ally_with_ruby)
story:add_passage(shootout)
story:add_passage(negotiate)
story:add_passage(stop_sheriff)
story:add_passage(witness_crime)
story:add_passage(gather_evidence)
story:add_passage(file_claim)
story:add_passage(gather_gold)
story:add_passage(set_trap)
story:add_passage(defend_claim)
story:add_passage(downplay_find)
story:add_passage(partner_with_ruby)
story:add_passage(armed_confrontation)
story:add_passage(dismiss_both)
story:add_passage(victory_order)
story:add_passage(merciful_victory)
story:add_passage(citizens_arrest)
story:add_passage(show_boundaries)
story:add_passage(teach_ruby)
story:add_passage(escort_ruby)
story:add_passage(work_alone)

-- Set the starting passage
story:set_start_passage("start")

-- Return the story
return story
