-- stories/examples/gold_rush_enhanced.lua
-- Enhanced story with saloon owner gambler, suit store owner, and native encounter
-- A story about a prospector seeking gold while dealing with various town characters

local Story = require("whisker.core.story")
local Passage = require("whisker.core.passage")
local Choice = require("whisker.core.choice")

-- Create the story
local story = Story.new({
    title = "Gold Rush Fever - Enhanced Edition",
    author = "whisker",
    ifid = "GOLD-RUSH-002",
    version = "2.0"
})

-- Passage 1: Start
local start = Passage.new({
    id = "start",
    content = [[
You're Silas McCready, a weathered prospector who's spent three long months
searching for gold in the rugged hills outside Deadwood. Your supplies are running
low, but you've finally found a promising claim - a creek bed that sparkles with
golden flecks and a rocky outcrop that might contain a rich vein.

Before heading out this morning, you need to decide your priorities.
    ]]
})

start:add_choice(Choice.new({
    text = "Head straight to your claim and start working",
    target = "morning_work"
}))

start:add_choice(Choice.new({
    text = "Stop by town first to gather supplies",
    target = "town_visit"
}))

start:add_choice(Choice.new({
    text = "Scout the area around your claim for signs of trouble",
    target = "morning_scout"
}))

-- NEW: Town Visit
local town_visit = Passage.new({
    id = "town_visit",
    content = [[
You ride into Deadwood as the sun climbs over the hills. The main street is already
bustling with activity. You tie your horse outside the general store.

As you step onto the boardwalk, "Big Jack" McKenzie stumbles out of the Dusty Rose
Saloon, even though it's barely past breakfast time. The massive saloon owner has
bleary eyes and whiskey on his breath.

"McCready!" he calls out, grabbing your arm. "Just the man I need! Listen, I had a
bad night at the poker table - real bad. Word is you found color out at your claim.
How about you stake me a small loan? I'm good for it, I swear!"

Across the street, you see Cornelius Pemberton arranging fancy suits in his shop
window, his own suit pressed to perfection despite the dusty frontier town.
    ]]
})

town_visit:add_choice(Choice.new({
    text = "Lend Big Jack some money - he's always been decent to you",
    target = "lend_money"
}))

town_visit:add_choice(Choice.new({
    text = "Politely decline and head to Pemberton's store",
    target = "suit_store"
}))

town_visit:add_choice(Choice.new({
    text = "Decline and quickly get supplies before heading to your claim",
    target = "quick_supplies"
}))

-- NEW: Lend Money
local lend_money = Passage.new({
    id = "lend_money",
    content = [[
"Alright, Jack," you sigh, pulling out a small pouch. "But this is the last time.
You need to get that gambling under control."

Big Jack's face lights up. "Bless you, McCready! I'll pay you back double when my
luck turns around. Say, you watch yourself out there. Sheriff Blackwood was asking
about you last night - seemed mighty interested in your claim."

He leans in closer, lowering his voice. "Between you and me, I saw him trying to
get Ruby involved in something. That girl's got a good heart, but Blackwood's been
pressuring her something fierce."

Before you can ask more, Jack hurries back toward the saloon, clutching your money.
    ]]
})

lend_money:add_choice(Choice.new({
    text = "Head to your claim immediately - you need to check on it",
    target = "morning_work"
}))

lend_money:add_choice(Choice.new({
    text = "Visit Pemberton's store first",
    target = "suit_store"
}))

lend_money:add_choice(Choice.new({
    text = "Try to find Ruby and warn her",
    target = "find_ruby"
}))

-- NEW: Suit Store
local suit_store = Passage.new({
    id = "suit_store",
    content = [[
You enter Cornelius Pemberton's "Fine Gentleman's Emporium." The fastidious
proprietor looks up from steaming a waistcoat, his own three-piece suit immaculate
despite the frontier dust that coats everything else in town.

"Mr. McCready!" Pemberton says, his Boston accent still strong after five years in
Deadwood. "I hear congratulations are in order. Found your color at last, have you?"

He sets down his iron carefully. "I hope you'll consider investing some of your
newfound wealth in proper attire. A successful businessman needs to look the part.
Why, I could fit you for a fine suit - only three hundred dollars."

He adjusts his spectacles. "Though I should mention - purely as a concerned citizen -
Sheriff Blackwood was in here yesterday, asking about land deeds and claim boundaries.
Seemed very interested in the northern hills. That's your area, isn't it?"
    ]]
})

suit_store:add_choice(Choice.new({
    text = "Order a suit - it's good to look successful",
    target = "buy_suit"
}))

suit_store:add_choice(Choice.new({
    text = "Decline politely and ask more about Blackwood",
    target = "pemberton_info"
}))

suit_store:add_choice(Choice.new({
    text = "Thank him and leave immediately for your claim",
    target = "morning_work"
}))

-- NEW: Buy Suit
local buy_suit = Passage.new({
    id = "buy_suit",
    content = [[
"You know what, Pemberton? You're right. I'll take that suit."

The tailor's eyes light up as he begins taking your measurements with practiced
precision. "Excellent choice, sir! You'll be the talk of the territory. Though..."
he pauses, "...given the Sheriff's interest in your claim, you might want to have
some legal documentation handy. Looking prosperous is one thing, but protecting
what's yours is another."

He lowers his voice. "I also do a side business in document preparation - deeds,
contracts, that sort of thing. Very official looking. Could help if someone tries
to dispute your claim..."

As he finishes measuring, you see through the window that it's getting late morning.
Your claim awaits.
    ]]
})

buy_suit:add_choice(Choice.new({
    text = "Ask Pemberton to prepare protective documents for your claim",
    target = "legal_docs"
}))

buy_suit:add_choice(Choice.new({
    text = "Just take the suit order and head to your claim",
    target = "morning_work"
}))

-- NEW: Legal Documents
local legal_docs = Passage.new({
    id = "legal_docs",
    content = [[
Pemberton smiles. "Wise decision, Mr. McCready. For a small additional fee, I can
have ironclad documentation ready by this afternoon. Stop by on your way back to
town and you'll be legally protected."

He hands you a receipt. "Now, best you get to that claim. And McCready? Keep an
eye out. I saw some Lakota scouts passing through yesterday morning, heading north.
They're usually peaceful, but with all the prospecting pushing into their hunting
grounds, tensions are high."

You nod and head out, the morning already half gone.
    ]]
})

legal_docs:add_choice(Choice.new({
    text = "Ride quickly to your claim",
    target = "afternoon_arrival"
}))

-- NEW: Pemberton Info
local pemberton_info = Passage.new({
    id = "pemberton_info",
    content = [[
"What exactly was Blackwood asking about?" you press.

Pemberton adjusts his collar nervously. "Well, he wanted to know about the legal
requirements for filing abandonment claims. Said he might know of some properties
that had been... neglected. Had a very particular interest in claims in the northern
hills."

He glances out the window. "Look, I shouldn't speak ill of a lawman, but Blackwood
owes Big Jack five hundred dollars from a card game last month. And when Jack tried
to collect, Blackwood threatened to shut down the Dusty Rose for 'illegal gambling.'
The man's as crooked as a dog's hind leg."

"I'd watch yourself, McCready. And maybe file some additional paperwork at the land
office, just to be safe."
    ]]
})

pemberton_info:add_choice(Choice.new({
    text = "Go to the land office to secure your claim",
    target = "land_office"
}))

pemberton_info:add_choice(Choice.new({
    text = "Head to your claim immediately",
    target = "morning_work"
}))

-- NEW: Find Ruby
local find_ruby = Passage.new({
    id = "find_ruby",
    content = [[
You find Ruby sweeping the porch of the Dusty Rose Saloon. When she sees you, her
face shows a mix of relief and worry.

"Silas," she says quietly, glancing around. "You shouldn't be seen talking to me
right now. Blackwood's watching. He... he wants me to do something. Something
involving you and your claim."

She hands you the broom as if you're just a customer. "He's planning to ride out
there today with me. Says I'm supposed to keep you distracted while he does
'business.' But Silas, I don't want any part of cheating an honest man."

Big Jack leans out from the saloon door. "Ruby! Get in here! Got customers!"

She whispers quickly, "Be careful today. And if you see us coming, know that I'm
trying to help you, not hurt you."
    ]]
})

find_ruby:add_choice(Choice.new({
    text = "Thank Ruby and rush to your claim",
    target = "morning_work"
}))

find_ruby:add_choice(Choice.new({
    text = "Ask Ruby to meet you later to plan a defense",
    target = "plan_with_ruby"
}))

-- NEW: Plan with Ruby
local plan_with_ruby = Passage.new({
    id = "plan_with_ruby",
    content = [[
"Meet me at my claim at sunset," you whisper. "We'll figure this out together."

Ruby nods. "I'll try. But if Blackwood forces me to come earlier, I'll leave signs
- a red ribbon on the trail. That means danger's coming."

She heads inside, and you mount your horse. The morning is spent, but you're forewarned.
    ]]
})

plan_with_ruby:add_choice(Choice.new({
    text = "Ride to your claim",
    target = "afternoon_arrival"
}))

-- NEW: Quick Supplies
local quick_supplies = Passage.new({
    id = "quick_supplies",
    content = [[
You avoid both Jack and Pemberton, quickly gathering supplies at the general store.
As you're loading your saddlebags, you overhear two miners talking.

"Heard tell some Lakota were spotted north of Deadwood yesterday. Probably just
passing through, but with all the claim jumping lately, folks are nervous."

You head out, keeping alert.
    ]]
})

quick_supplies:add_choice(Choice.new({
    text = "Ride to your claim",
    target = "morning_work"
}))

-- NEW: Morning Scout
local morning_scout = Passage.new({
    id = "morning_scout",
    content = [[
You decide to scout the area around your claim before starting work. Riding the
perimeter, you notice fresh horse tracks that aren't yours - at least two horses,
from yesterday evening.

More concerning, you find a small cairn of stones that wasn't there before. It's
near the boundary of your claim, and placed in a way that could mark territorial
notice. The arrangement looks like Lakota work - respectful but clear.

In the distance, you see thin smoke from what might be a camp, several miles north.
    ]]
})

morning_scout:add_choice(Choice.new({
    text = "Approach the distant camp peacefully to introduce yourself",
    target = "native_encounter"
}))

morning_scout:add_choice(Choice.new({
    text = "Return to your claim and start working",
    target = "creek_panning"
}))

morning_scout:add_choice(Choice.new({
    text = "Investigate the horse tracks first",
    target = "investigate_tracks"
}))

-- NEW: Native Encounter
local native_encounter = Passage.new({
    id = "native_encounter",
    content = [[
You ride slowly toward the smoke, hands visible and relaxed on the reins. As you
approach, three Lakota men step out from the trees. The eldest has gray in his hair
and carries himself with quiet authority.

He speaks in accented but clear English. "You are the one who digs in the earth by
the singing creek."

It's a statement, not a question. You nod carefully.

"This land..." he gestures broadly, "...was promised to us by treaty. The white
father in Washington said the Black Hills would be ours forever. But 'forever' is
a short time in white man's words."

The younger men behind him watch you carefully but without hostility.

"We do not stop you," the elder continues. "We cannot stop the river of gold-seekers.
But we ask: when you find what you seek, will you take only what you need? Or will
you take everything, like the others?"

There's a long pause. "And there is something else. Yesterday, a white man with a
star on his chest was near here, placing markers. He did not ask permission. He did
not even see us, though we were close. Be careful of men who take without asking."
    ]]
})

native_encounter:add_choice(Choice.new({
    text = "Promise to take only what you need and respect the land",
    target = "respectful_promise"
}))

native_encounter:add_choice(Choice.new({
    text = "Ask them about the man with the star (Sheriff Blackwood)",
    target = "ask_about_sheriff"
}))

native_encounter:add_choice(Choice.new({
    text = "Thank them and return to your claim",
    target = "creek_panning"
}))

-- NEW: Respectful Promise
local respectful_promise = Passage.new({
    id = "respectful_promise",
    content = [[
"I give you my word," you say sincerely. "I'll take what I need to live well, but
I won't scar this land. And..." you hesitate, then continue, "...if I do find gold,
I'll remember who was here first. Perhaps there's a way we can help each other."

The elder regards you for a long moment, then nods slowly. "Words are wind unless
they become actions. But your eyes are honest. We will watch, and we will remember
your promise."

He gestures to one of the younger men, who hands you a small leather pouch. "Pemmican.
The work you do is hard. You will need strength."

As you turn to leave, the elder adds, "The man with the star is coming to your claim
today. He brings a woman in red. Be wise, Silas McCready."

The fact that he knows your name sends a chill down your spine, but not an unfriendly one.
    ]]
})

respectful_promise:add_choice(Choice.new({
    text = "Return to your claim and prepare for Blackwood",
    target = "creek_panning"
}))

respectful_promise:add_choice(Choice.new({
    text = "Ask if they would witness what Blackwood does",
    target = "native_alliance"
}))

-- NEW: Native Alliance
local native_alliance = Passage.new({
    id = "native_alliance",
    content = [[
"If the Sheriff tries to steal my claim," you say carefully, "would you be willing
to testify to what you've seen? The false markers he placed?"

The elder considers this. "White man's courts do not value our words. But..." he
smiles slightly, "...the judge who comes to Deadwood next week is different. He
learned our language when he was young. He listens."

"If you protect this land as you promise, we will speak for you if needed. But
remember - we will also speak against you if you break the earth carelessly."

One of the younger men adds, "We will be near today. If there is trouble with
the star-man, signal with smoke. Three quick fires."

You nod, grateful for unexpected allies.
    ]]
})

native_alliance:add_choice(Choice.new({
    text = "Return to your claim with renewed confidence",
    target = "creek_panning"
}))

-- NEW: Ask About Sheriff
local ask_about_sheriff = Passage.new({
    id = "ask_about_sheriff",
    content = [[
"This man with the star - the Sheriff - what exactly was he doing?"

The elder points toward your claim area. "He was placing wooden sticks with markings,
moving your boundary stones. He thought no one watched, but the earth has many eyes."

One of the younger men speaks up in Lakota, and the elder translates: "He also
dropped a piece of paper. We did not touch it, but we saw it had drawings of the
land and writing."

"We do not interfere in white man's disputes," the elder says. "But we do not like
thieves, whatever their color or star. What is stolen from you today may be stolen
from us tomorrow."
    ]]
})

ask_about_sheriff:add_choice(Choice.new({
    text = "Ask them to show you where the false markers are",
    target = "find_markers"
}))

ask_about_sheriff:add_choice(Choice.new({
    text = "Thank them and hurry to your claim",
    target = "creek_panning"
}))

-- NEW: Find Markers
local find_markers = Passage.new({
    id = "find_markers",
    content = [[
The younger Lakota man leads you to three new wooden stakes, each placed deliberately
inside your legitimate claim boundary. They're weathered to look old, but you can
tell they're recent.

"Smart," you mutter. "He's creating evidence that my boundaries are wrong."

The Lakota scout nods. "Do you remove them now, or leave them for others to see
his dishonesty?"

It's a good question.
    ]]
})

find_markers:add_choice(Choice.new({
    text = "Leave them as evidence and document their locations",
    target = "document_fraud"
}))

find_markers:add_choice(Choice.new({
    text = "Remove them immediately",
    target = "remove_markers"
}))

-- Continue with original passages but modified to incorporate new characters...

-- Passage: Morning Work (connects to original story)
local morning_work = Passage.new({
    id = "morning_work",
    content = [[
You arrive at your claim and immediately get to work. The morning sun glints off
the creek as you wade in with your pan.

After an hour of panning, you've found several promising flakes. But you also notice
fresh horse tracks near your camp - someone was here recently.
    ]]
})

morning_work:add_choice(Choice.new({
    text = "Continue panning despite the tracks",
    target = "creek_panning"
}))

morning_work:add_choice(Choice.new({
    text = "Investigate the tracks thoroughly",
    target = "investigate_tracks"
}))

-- NEW: Investigate Tracks
local investigate_tracks = Passage.new({
    id = "investigate_tracks",
    content = [[
You examine the tracks carefully. Two horses, one carrying a heavy rider, stopped
here yesterday evening. One set of prints circles your boundary markers. The other
stays by the equipment.

More disturbing - one of your boundary stakes has been pulled up slightly and reset
in a different spot, about three feet inward from where you placed it.

Someone's already started tampering with your claim.
    ]]
})

investigate_tracks:add_choice(Choice.new({
    text = "Reset your boundary marker and reinforce all of them",
    target = "secure_boundaries"
}))

investigate_tracks:add_choice(Choice.new({
    text = "Leave everything as is and start panning - you'll deal with it later",
    target = "creek_panning"
}))

-- MODIFIED: Creek Panning (enhanced with new context)
local creek_panning = Passage.new({
    id = "creek_panning",
    content = [[
You wade into the cold creek, your pan in hand. The icy water numbs your legs
as you scoop up sediment and begin the rhythmic swirling motion. After an hour,
you've found several small flakes of gold - not a fortune, but promising.

As you work, you notice riders approaching from town. It's Sheriff Blackwood,
a man known more for his greed than his justice. Behind him rides a woman in
a crimson dress - Ruby, from the Dusty Rose Saloon.

You remember Big Jack's warning about Blackwood asking questions, and the Lakota
elder's mention of a man with a star and a woman in red.

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
    text = "Confront him about the false markers you know he planted",
    target = "confront_markers"
}))

-- [Include all the original passages from the first version here, but I'll add a few new enhanced endings]

-- I'll add the key original passages that connect to the new content:

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

-- NEW: Confront Markers
local confront_markers = Passage.new({
    id = "confront_markers",
    content = [[
You climb out of the creek and walk directly toward Blackwood, water dripping from
your boots.

"Interesting thing, Sheriff. I found some new boundary markers on my claim this
morning. Funny thing is, they weren't there two days ago, and they're weathered to
look old. Almost like someone's trying to create a false boundary dispute."

Blackwood's eyes narrow. "You accusing me of something, McCready?"

"I'm saying I've got witnesses who saw a man with a star placing fake markers
yesterday. The Lakota don't miss much in these hills."

The Sheriff's hand moves toward his gun, but Ruby quickly steps between you. "Silas,
the Sheriff was just telling me about claim jumpers operating in the area. He's
trying to help you!"

But her eyes are signaling you frantically - danger.
    ]]
})

confront_markers:add_choice(Choice.new({
    text = "Back down and apologize - you may have been too aggressive",
    target = "tactical_retreat"
}))

confront_markers:add_choice(Choice.new({
    text = "Stand your ground and threaten to report him",
    target = "confront_threat"
}))

confront_markers:add_choice(Choice.new({
    text = "Signal for help - the Lakota said they'd be watching",
    target = "native_intervention"
}))

-- NEW: Native Intervention
local native_intervention = Passage.new({
    id = "native_intervention",
    content = [[
You casually walk to your campfire and kick dirt over it three times in quick
succession, making three separate smoke clouds rise.

Blackwood watches, confused. "What in tarnation are you doing?"

Within minutes, the three Lakota men emerge from the tree line, walking calmly but
deliberately toward your group. The elder speaks clearly.

"Sheriff with the star. We have watched you. Yesterday you placed false markers on
this man's land. We saw. We remember. We will tell the judge who speaks our language."

Blackwood's face goes pale, then red with anger. "You got no authority here!"

"No," the elder agrees. "But we have eyes. And truth. Take your woman and leave this
place."

The Sheriff realizes he's outnumbered and outmaneuvered. He spits on the ground.
"This ain't over, McCready." He mounts his horse and rides off.

Ruby stays behind, looking at you with respect and relief.
    ]]
})

native_intervention:add_choice(Choice.new({
    text = "Thank the Lakota men and invite them to share your campfire",
    target = "alliance_ending"
}))

native_intervention:add_choice(Choice.new({
    text = "Thank them and turn your attention to Ruby",
    target = "ruby_partnership"
}))

-- NEW ENDINGS

-- NEW ENDING: Alliance Ending
local alliance_ending = Passage.new({
    id = "alliance_ending",
    content = [[
The Lakota elder accepts your invitation, and the three men join you at your fire.
Ruby, nervous at first, relaxes as conversation flows.

Over the following months, an unusual but powerful alliance forms. The Lakota help
you identify the richest mineral deposits using their knowledge of the land. You
work your claim carefully, taking only what you need and leaving the land as unmarked
as possible.

Ruby becomes your business partner, handling sales in town. When Big Jack falls on
hard times again, you help him restructure his saloon's business, and he becomes
your best customer for gold dust - paying miners always drink more.

Even Cornelius Pemberton gets involved, handling your legal documentation and
ensuring everything is properly registered.

When the territorial judge arrives, the Lakota's testimony not only clears you of
any boundary disputes but also leads to Blackwood's arrest for fraud. The judge,
impressed by the peaceful cooperation, establishes your claim as a model for
respectful prospecting.

Your mining operation becomes moderately successful, but more importantly, you've
built something rare in the frontier - a community based on mutual respect rather
than exploitation.

Years later, when the gold runs out, you stay in the area. The land you protected
becomes valuable for other reasons, and the relationships you built prove worth
far more than gold.

**BEST ENDING - Respect, cooperation, and lasting community!**

*THE END*
    ]]
})

-- NEW ENDING: Ruby Partnership
local ruby_partnership = Passage.new({
    id = "ruby_partnership",
    content = [[
"Ruby," you say after the Lakota men leave, "I need someone I can trust. Someone
smart, brave, and honest. How would you like to be my partner? Equal shares."

Ruby's eyes widen. "Equal? Silas, I'm just a saloon girl—"

"You're a woman who stood up to a corrupt sheriff when you could have looked the
other way. That makes you the right kind of partner."

She accepts.

Together, you build a successful operation. Ruby proves brilliant at business,
negotiating with Big Jack to supply food and equipment, and even getting Cornelius
Pemberton to reduce his prices in exchange for first pick of any gold jewelry you
produce.

When Big Jack hits another gambling low, Ruby helps him see he has a problem. With
her encouragement, he stops gambling and focuses on making the Dusty Rose the finest
saloon in the territory. He never forgets her kindness.

The Lakota elder occasionally visits, and you always honor your promise to work
respectfully. Sometimes they guide you to good deposits; sometimes they ask you to
avoid certain areas for their hunts. You always agree.

Two years later, McCready-Ruby Mining Company is the most respected operation in the
Black Hills, known for fair dealing and ethical practices.

And somewhere along the way, partnership became friendship, friendship became love,
and love became marriage.

**BEST ENDING - True partnership in business and life!**

*THE END*
    ]]
})

-- Add more original passages with some modifications for continuity
local talk_to_sheriff = Passage.new({
    id = "talk_to_sheriff",
    content = [[
You set down your tools and approach them. "What's this about, Sheriff?"

Blackwood grins. "Just being neighborly, McCready. Ruby here mentioned she'd
never seen a real mining operation. Thought maybe you could show her the ropes
while I... make sure everything's legal with your claim."

Ruby gives you an apologetic look, and you remember her warning if you spoke with
her in town.

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

local ruby_warning = Passage.new({
    id = "ruby_warning",
    content = [[
You approach Ruby, accepting the water she offers.

"Thank you, Ruby," you say quietly. "What's really going on here?"

She glances at the Sheriff, who's pretending to study the horizon. "He knows
you've found something valuable. He wants me to distract you while he tampers
with your claim markers or your equipment. Silas, I don't want any part of
his schemes. I came to warn you."

The Sheriff calls out, "Ruby! Stop boring the man with gossip!"

Ruby whispers, "Big Jack told me to help you if I could. He says you're one of
the good ones. Be careful."
    ]]
})

ruby_warning:add_choice(Choice.new({
    text = "Thank Ruby and send them both away",
    target = "dismiss_both"
}))

ruby_warning:add_choice(Choice.new({
    text = "Propose that Ruby stay and help you work the claim",
    target = "partner_with_ruby"
}))

ruby_warning:add_choice(Choice.new({
    text = "Confront the Sheriff with Ruby's warning",
    target = "confront_threat"
}))

local confront_threat = Passage.new({
    id = "confront_threat",
    content = [[
"I know your game, Blackwood," you say firmly. "You're trying to steal my claim.
Ruby already told me everything."

The Sheriff's hand moves to his gun. "Careful, McCready. That sounds like you're
accusing a lawman of corruption."

Ruby steps between you both. "Stop! Silas, you're right. He threatened to run me
out of town if I didn't help him. But I can't do it. I can't help steal from an
honest man."

"Ruby!" the Sheriff snarls. "You just cost yourself everything!"

From the tree line, you see movement - the Lakota scouts are watching, just as they
promised.
    ]]
})

confront_threat:add_choice(Choice.new({
    text = "Stand with Ruby against the Sheriff",
    target = "ally_with_ruby"
}))

confront_threat:add_choice(Choice.new({
    text = "Signal the Lakota for help",
    target = "native_intervention"
}))

confront_threat:add_choice(Choice.new({
    text = "Propose a deal with the Sheriff",
    target = "negotiate"
}))

local ally_with_ruby = Passage.new({
    id = "ally_with_ruby",
    content = [[
"Ruby's right," you say firmly. "Now get off my claim, Blackwood, before I report
you to the territorial marshal."

Blackwood realizes he's cornered. With Ruby as a witness, he can't risk violence.
He mounts his horse in fury and rides off.

Ruby looks at you with relief. "Thank you for believing me, Silas."

Over the following weeks, you work the claim together. Big Jack, grateful that you
protected Ruby, sends supplies at cost. Pemberton handles your legal documentation
for free, impressed by your integrity. The Lakota elder visits once, nods in approval
at your respectful work, and leaves a deer carcass as a gift.

When the territorial judge arrives and arrests Blackwood on multiple charges based
on Lakota testimony, Ruby's account is crucial. Your claim is validated, and the
community rallies around you both.

Two years later, the McCready-Ruby Mining Company is one of the most successful
operations in the territory.

**EXCELLENT ENDING - Integrity, courage, and community support!**

*THE END*
    ]]
})

local partner_with_ruby = Passage.new({
    id = "partner_with_ruby",
    content = [[
You look at Ruby. "You tried to warn me when you could have stayed silent. That
takes courage. Ruby, how would you like to be my partner? Fifty-fifty split."

Ruby's eyes widen. "Are you serious?"

"Dead serious. I need someone I can trust, and you've proven yourself."

She accepts. Together, you build something special. Ruby's connections to Big Jack
and his saloon create a ready market for your gold. Pemberton becomes your attorney,
drawn by Ruby's charm and your fair dealing.

The Lakota elder, hearing of your partnership with Ruby and your respectful approach
to the land, ensures no one disturbs your operation.

When Blackwood tries to cause trouble, he finds himself opposed by the entire
community - even other miners respect how you do business.

Years later, your partnership becomes a marriage, built on mutual respect and trust.

**BEST ENDING - True partnership transforms everything!**

*THE END*
    ]]
})

-- Simpler endings for quick paths
local dismiss_both = Passage.new({
    id = "dismiss_both",
    content = [[
You thank Ruby but send them both away. Working alone, you successfully mine
a moderate amount of gold over the next year.

You occasionally see Ruby in town - she opened her own boarding house with help
from Big Jack. Blackwood eventually got arrested for other crimes.

You did well, but sometimes wonder what might have been if you'd trusted more.

**DECENT ENDING - Independence brings modest success.**

*THE END*
    ]]
})

local negotiate = Passage.new({
    id = "negotiate",
    content = [[
You negotiate a protection deal with Blackwood - 15% of your take. It works, barely,
but you're always looking over your shoulder.

Eventually you sell out and leave the territory with moderate wealth but no peace.

**MIXED ENDING - Compromise brings gold but not satisfaction.**

*THE END*
    ]]
})

local ruby_distraction = Passage.new({
    id = "ruby_distraction",
    content = [[
As you show Ruby the creek, she whispers urgently, "He's planting false markers.
Stop him now!"

You turn to see Blackwood hammering stakes into the ground.
    ]]
})

ruby_distraction:add_choice(Choice.new({
    text = "Confront him immediately",
    target = "confront_markers"
}))

ruby_distraction:add_choice(Choice.new({
    text = "Signal for the Lakota witnesses",
    target = "native_intervention"
}))

-- Additional supporting passages
local watch_sheriff = Passage.new({
    id = "watch_sheriff",
    content = [[
You keep your eyes on Blackwood, who grows frustrated that he can't tamper with
your claim. Eventually he gives up and leaves.

Your vigilance pays off, and you successfully work your claim.

**GOOD ENDING - Vigilance protects what's yours.**

*THE END*
    ]]
})

local stand_ground = Passage.new({
    id = "stand_ground",
    content = [[
"Sheriff, unless you have a warrant, you need to leave. This is private property."

Blackwood's hand hovers over his pistol, but Ruby steps between you. "Maybe we
should just go, Sheriff."

After a tense moment, he leaves. Your firm stand protects your claim.

**GOOD ENDING - Standing firm works.**

*THE END*
    ]]
})

local stay_focused_creek = Passage.new({
    id = "stay_focused_creek",
    content = [[
You continue working, ignoring their attempts at distraction. Eventually they leave,
and you find a large nugget in your next pan!

Your focus and determination pay off with significant gold finds.

**GOOD ENDING - Focus and hard work succeed.**

*THE END*
    ]]
})

-- Additional new passages for other paths
local afternoon_arrival = Passage.new({
    id = "afternoon_arrival",
    content = [[
You arrive at your claim in early afternoon. The tracks you saw this morning are
still there, and now you notice someone has been inside your tent.

As you investigate, you hear horses approaching - it's Blackwood and Ruby.
    ]]
})

afternoon_arrival:add_choice(Choice.new({
    text = "Confront them about the intrusion",
    target = "confront_markers"
}))

afternoon_arrival:add_choice(Choice.new({
    text = "Act like nothing's wrong and see what they want",
    target = "talk_to_sheriff"
}))

local land_office = Passage.new({
    id = "land_office",
    content = [[
You spend the morning at the land office, filing additional documentation. The
clerk, a friend of Pemberton's, makes everything official and timestamped.

When you finally reach your claim in the afternoon, you find evidence that
Blackwood was here but couldn't do much without being caught.

Your paperwork protects you, and you mine successfully.

**GOOD ENDING - Preparation and documentation win.**

*THE END*
    ]]
})

local document_fraud = Passage.new({
    id = "document_fraud",
    content = [[
With the Lakota as witnesses, you carefully document the false marker locations,
take measurements, and note everything in your journal.

This evidence later proves crucial in getting Blackwood arrested. Your methodical
approach impresses the judge, who validates your claim permanently.

**EXCELLENT ENDING - Evidence and witnesses triumph!**

*THE END*
    ]]
})

local remove_markers = Passage.new({
    id = "remove_markers",
    content = [[
You remove the false markers, but without witnesses to the original fraud, it
becomes he-said-she-said when Blackwood later claims you moved YOUR markers.

Legal battles follow, eating up your time and gold.

**MIXED ENDING - Acting too quickly causes problems.**

*THE END*
    ]]
})

local secure_boundaries = Passage.new({
    id = "secure_boundaries",
    content = [[
You spend the morning carefully documenting and reinforcing all your boundary
markers, using techniques Pemberton suggested.

When Blackwood arrives later, he finds everything documented and can't make his
scheme work. Frustrated, he leaves.

**GOOD ENDING - Preparation prevents fraud.**

*THE END*
    ]]
})

local tactical_retreat = Passage.new({
    id = "tactical_retreat",
    content = [[
You apologize and back down, but privately you note everything. Later, with proper
legal help from Pemberton and witness statements from the Lakota, you build an
unassailable case.

Blackwood gets arrested, and your claim is secured.

**GOOD ENDING - Tactical patience wins.**

*THE END*
    ]]
})

-- Add all passages to the story
story:add_passage(start)
story:add_passage(town_visit)
story:add_passage(lend_money)
story:add_passage(suit_store)
story:add_passage(buy_suit)
story:add_passage(legal_docs)
story:add_passage(pemberton_info)
story:add_passage(find_ruby)
story:add_passage(plan_with_ruby)
story:add_passage(quick_supplies)
story:add_passage(morning_scout)
story:add_passage(native_encounter)
story:add_passage(respectful_promise)
story:add_passage(native_alliance)
story:add_passage(ask_about_sheriff)
story:add_passage(find_markers)
story:add_passage(morning_work)
story:add_passage(investigate_tracks)
story:add_passage(creek_panning)
story:add_passage(ignore_sheriff_creek)
story:add_passage(confront_markers)
story:add_passage(native_intervention)
story:add_passage(talk_to_sheriff)
story:add_passage(ruby_warning)
story:add_passage(confront_threat)
story:add_passage(ruby_distraction)
story:add_passage(watch_sheriff)
story:add_passage(stand_ground)
story:add_passage(stay_focused_creek)
story:add_passage(afternoon_arrival)
story:add_passage(land_office)
story:add_passage(document_fraud)
story:add_passage(remove_markers)
story:add_passage(secure_boundaries)
story:add_passage(tactical_retreat)

-- Add ending passages
story:add_passage(alliance_ending)
story:add_passage(ruby_partnership)
story:add_passage(ally_with_ruby)
story:add_passage(partner_with_ruby)
story:add_passage(dismiss_both)
story:add_passage(negotiate)

-- Set the starting passage
story:set_start_passage("start")

-- Return the story
return story
