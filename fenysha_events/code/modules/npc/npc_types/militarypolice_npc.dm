/mob/living/basic/npc/police
	health = 250
	maxHealth = 250
	faction = list(FACTION_CIVILIAN, FACTION_POLICE, FACTION_NEUTRAL)
	join_text = "You are a police officer. Maintain order in your zone and protect civilians."
	important_text = "Do not attack players without reason, and do not leave your city!"
	melee_damage_lower = 15
	melee_damage_upper = 30
	melee_damage_type = BRUTE

	ai_controller = null

	possible_outfits = list(
		/datum/outfit/trainstation_civilian/police,
		/datum/outfit/trainstation_civilian/police/alt,
	)

	speech_phrases = list(
		NPC_TALK_KEY_IDLE = list(
			"Everything seems quiet.",
			"Keep an eye on the street.",
			"Another quiet shift.",
			"I've got paperwork waiting for me.",
			"Stay alert.",
			"I don't trust this silence.",
			"Check the area again.",
			"Nothing unusual so far.",
			"I hope it stays that way.",
			"We've had enough trouble today."
		),

		NPC_TALK_KEY_TARGET = list(
			"%MOBNAME%, stop right there.",
			"%MOBNAME%, keep your hands where I can see them.",
			"I need to speak with you, %MOBNAME%.",
			"%MOBNAME%, step away from the area.",
			"Do not make any sudden moves, %MOBNAME%.",
			"%MOBNAME%, you're making this difficult.",
			"Sir, I'm asking you to cooperate.",
			"Ma'am, step back.",
			"%MOBNAME%, this is your final warning.",
			"Identify yourself, %MOBNAME%."
		),

		NPC_TALK_KEY_INJURED = list(
			"I'm hit.",
			"That one got through.",
			"I need medical attention.",
			"I'm hurt, but I'm still standing.",
			"Requesting assistance.",
			"Patch me up when you get a chance.",
			"That's going to leave a mark.",
			"I'm bleeding.",
			"Keep pressure on it.",
			"I'll be fine. Keep moving."
		),

		NPC_TALK_KEY_LOWHEALTH = list(
			"Officer down! I need assistance!",
			"I'm badly hurt!",
			"Get a medic here!",
			"I can't hold this position!",
			"Request immediate medical assistance!",
			"I need backup now!",
			"I'm losing blood!",
			"Get me out of here!",
			"I can barely stay on my feet.",
			"Don't leave me here!"
		),

		NPC_TALK_KEY_ENEMY_NEARBY = list(
			"Unidentified individual approaching.",
			"Stay where you are.",
			"Possible hostile ahead.",
			"Keep your distance.",
			"Everyone stay calm.",
			"Do not escalate this.",
			"Hands where I can see them.",
			"We have a situation.",
			"Stay behind me.",
			"Watch that individual."
		),

		NPC_TALK_KEY_ENEMY_CROWD_NEARBY = list(
			"Multiple hostiles approaching!",
			"Too many targets!",
			"Fall back to a defensible position!",
			"We need additional units!",
			"Keep the civilians behind cover!",
			"Do not let them through!",
			"Move the civilians inside!",
			"We are heavily outnumbered!",
			"Hold the line!",
			"Call for backup!"
		),

		NPC_TALK_KEY_IN_DANGER = list(
			"Take cover!",
			"Contact!",
			"Stay down!",
			"Move!",
			"Get behind cover!",
			"Keep your head down!",
			"Watch your flank!",
			"Incoming!",
			"Hold position!",
			"Do not panic!"
		)
	)


/mob/living/basic/npc/police/generate_name()
	var/static/ranks = list(
		"Officer",
		"Corporal",
		"Sergeant",
		"Lieutenant",
	)
	var/base = ..()
	return "[pick(ranks)] [base]"


/mob/living/basic/npc/police/baton
	attack_sound = 'sound/items/weapons/egloves.ogg'
	item_r_hand = /obj/item/melee/baton/security
	melee_damage_lower = 40
	melee_damage_upper = 40
	melee_attack_cooldown = 3 SECONDS
	melee_damage_type = STAMINA

/mob/living/basic/npc/police/baton/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	do_sparks(1, TRUE, src)


/mob/living/basic/npc/police/disabler
	attack_sound = 'sound/items/weapons/egloves.ogg'
	melee_damage_lower = 40
	melee_damage_upper = 40
	melee_attack_cooldown = 3 SECONDS
	ai_controller = null

	ranged = TRUE
	item_r_hand = /obj/item/gun/energy/disabler
	projectilesound = 'sound/items/weapons/taser2.ogg'
	casingtype = /obj/projectile/beam/disabler
	burst_shots = 2



/mob/living/basic/npc/military
	health = 300
	maxHealth = 300
	faction = list(FACTION_MILITARY, FACTION_NEUTRAL)
	join_text = "You are a soldier. You must maintain order in your zone and protect civilians."
	melee_damage_lower = 15
	melee_damage_upper = 30
	melee_damage_type = BRUTE
	ai_controller = /datum/ai_controller/basic_controller/npc_military
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5


	ranged = TRUE
	item_r_hand = /obj/item/gun/ballistic/automatic/m90
	projectilesound = 'sound/items/weapons/gun/smg/shot_alt.ogg'
	casingtype = /obj/item/ammo_casing/c38
	burst_shots = 3

	possible_outfits = list(/datum/outfit/trainstation_military)
	inante_abilities = list(
		/datum/action/cooldown/mob_cooldown/knockdown_target = BB_BASIC_MOB_ABILITY_KNOCKDOWN,
		/datum/action/cooldown/mob_cooldown/throw_grenade = BB_BASIC_MOB_ABILITY_THROW_GRENADE,
	)

	speech_phrases = list(
		NPC_TALK_KEY_IDLE = list(
			"Area appears secure.",
			"Maintain your position.",
			"Stay alert.",
			"Keep your weapon ready.",
			"Sector looks clear.",
			"Continue patrol.",
			"Watch the perimeter.",
			"Report anything unusual.",
			"Hold your position.",
			"Do not get complacent."
		),

		NPC_TALK_KEY_TARGET = list(
			"%MOBNAME%, halt.",
			"%MOBNAME%, identify yourself.",
			"Unknown contact, state your intentions.",
			"%MOBNAME%, keep your hands visible.",
			"Do not advance.",
			"%MOBNAME%, step away from the restricted area.",
			"You are entering a controlled zone.",
			"%MOBNAME%, this is your only warning.",
			"Unknown target in the perimeter.",
			"Maintain visual contact with %MOBNAME%."
		),

		NPC_TALK_KEY_INJURED = list(
			"I'm hit.",
			"Taking damage.",
			"Minor injury. I can continue.",
			"I need a medic.",
			"Armor took most of it.",
			"Pressure on the wound.",
			"I'm still combat effective.",
			"Keep moving. I'll manage.",
			"Medical assistance required.",
			"That hit was heavier than expected."
		),

		NPC_TALK_KEY_LOWHEALTH = list(
			"I'm badly wounded.",
			"Combat effectiveness compromised.",
			"I need immediate medical support.",
			"Man down! I need assistance!",
			"I can't maintain this position.",
			"Request emergency extraction.",
			"My condition is critical.",
			"I'm losing too much blood.",
			"Get the medic here now.",
			"I need cover!"
		),

		NPC_TALK_KEY_ENEMY_NEARBY = list(
			"Contact ahead.",
			"Unknown contact.",
			"Possible hostile.",
			"Eyes on target.",
			"Movement ahead.",
			"Stay focused.",
			"Weapon ready.",
			"Hostile presence detected.",
			"Maintain visual contact.",
			"Prepare for engagement."
		),

		NPC_TALK_KEY_ENEMY_CROWD_NEARBY = list(
			"Multiple contacts!",
			"Large hostile group ahead.",
			"We are outnumbered.",
			"Hold the defensive line.",
			"Do not let them breach the position.",
			"Requesting additional units.",
			"Prepare for sustained contact.",
			"Keep the civilians behind us.",
			"Concentrate fire on the front.",
			"Do not break formation."
		),

		NPC_TALK_KEY_IN_DANGER = list(
			"CONTACT!",
			"TAKE COVER!",
			"INCOMING!",
			"RETURN FIRE!",
			"KEEP YOUR HEAD DOWN!",
			"FALL BACK!",
			"HOLD POSITION!",
			"WATCH YOUR FLANK!",
			"MOVE!",
			"ENGAGING!"
		)
	)

/mob/living/basic/npc/military/generate_name()
	var/static/ranks = list(
		"Officer",
		"Corporal",
		"Sergeant",
		"Lieutenant",
	)
	var/base = ..()
	return "[pick(ranks)] [base]"

/mob/living/basic/npc/military/military/sniper
	item_r_hand = /obj/item/gun/ballistic/rifle/sniper_rifle
	projectilesound = 'sound/items/weapons/gun/sniper/shot.ogg'
	casingtype = /obj/item/ammo_casing/p50
	burst_shots = 1
	ranged_cooldown = 7 SECONDS
	ragned_shots_before_reload = 5
