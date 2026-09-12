/mob/living/basic/npc/civilian
	name = "Civilian"
	possible_outfits = list(
		/datum/outfit/trainstation_civilian,
		/datum/outfit/trainstation_civilian/style_1,
		/datum/outfit/trainstation_civilian/style_2,
		/datum/outfit/trainstation_civilian/style_3,
		/datum/outfit/trainstation_civilian/style_4,
	)

	speech_phrases = list(
		NPC_TALK_KEY_IDLE = list(
			"Feels strangely quiet today.",
			"I wonder when the next train is coming.",
			"I've got a bad feeling about this place.",
			"Could use a cup of coffee right now.",
			"I hate when it's this quiet.",
			"Something feels off.",
			"Just another day at the station.",
			"I should probably head home.",
			"Did anyone else hear that?",
			"Maybe I'm just imagining things."
		),

		NPC_TALK_KEY_TARGET = list(
			"Hey, %MOBNAME%, watch where you're going.",
			"%MOBNAME%, you looking for someone?",
			"I don't like the way %MOBNAME% is looking at us.",
			"Can you keep %MOBNAME% away from me?",
			"%MOBNAME% better have a good reason for being here.",
			"I think %MOBNAME% is following us.",
			"Who is %MOBNAME%?",
			"Something about %MOBNAME% bothers me.",
			"Don't take your eyes off %MOBNAME%.",
			"%MOBNAME%, I really don't want any trouble."
		),

		NPC_TALK_KEY_INJURED = list(
			"Ow... that hurts.",
			"I think I'm bleeding.",
			"I've had better days.",
			"That was not supposed to happen.",
			"I need to sit down for a minute.",
			"Easy... easy...",
			"I'll be fine. Probably.",
			"Does anyone have a medkit?",
			"I really hope that's not broken.",
			"I can't keep doing this..."
		),

		NPC_TALK_KEY_LOWHEALTH = list(
			"I'm not going to make it like this.",
			"Someone... help me.",
			"I need a medic. Now.",
			"I can barely stand...",
			"This is bad. This is really bad.",
			"I don't think I have much left.",
			"Get me somewhere safe.",
			"Please... somebody help.",
			"I'm losing too much blood.",
			"Stay back. I can't protect you."
		),

		NPC_TALK_KEY_ENEMY_NEARBY = list(
			"Uh... we've got company.",
			"There's someone over there.",
			"Hey, who is that?",
			"Keep your distance.",
			"I don't think they're friendly.",
			"Something's wrong.",
			"Don't make any sudden moves.",
			"Who's that approaching?",
			"Stay alert.",
			"That doesn't look good."
		),

		NPC_TALK_KEY_ENEMY_CROWD_NEARBY = list(
			"There's a whole group of them!",
			"That's way too many people.",
			"We need to get out of here.",
			"Why are there so many of them?",
			"Everybody move!",
			"Get inside, now!",
			"We're seriously outnumbered.",
			"Don't stay out in the open!",
			"There's no way we're taking them head-on.",
			"Run. Just run."
		),

		NPC_TALK_KEY_IN_DANGER = list(
			"Everybody stay calm!",
			"Get down!",
			"Find cover!",
			"Something is very wrong here.",
			"We need to move!",
			"Don't just stand there!",
			"Get behind something!",
			"Where are the security officers?",
			"Somebody call for help!",
			"Move, move, move!"
		)
	)

/mob/living/basic/npc/civilian/human
	species = /datum/species/human

/mob/living/basic/npc/civilian/vulpkanin
	species = /datum/species/vulpkanin
	randomize_mutant_colors = TRUE

/mob/living/basic/npc/civilian/tajaran
	species = /datum/species/tajaran
	randomize_mutant_colors = TRUE

/mob/living/basic/npc/civilian/lizard
	species = /datum/species/lizard
	randomize_mutant_colors = TRUE

/mob/living/basic/npc/civilian/teshari
	species = /datum/species/teshari
	randomize_mutant_colors = TRUE
	add_hair = FALSE


