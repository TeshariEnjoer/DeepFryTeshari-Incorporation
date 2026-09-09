


/obj/effect/landmark/police_patrol_point
	name = "Police patrol point"

/mob/living/basic/npc/police
	name = "Police Officer"
	health = 250
	maxHealth = 250
	faction = list(FACTION_CIVILIAN, FACTION_POLICE, FACTION_NEUTRAL)
	join_text = "You are a police officer. Maintain order in your zone and protect civilians."
	important_text = "Do not attack players without reason, and do not leave your city!"
	melee_damage_lower = 15
	melee_damage_upper = 30
	melee_damage_type = STAMINA

	ai_controller = /datum/ai_controller/basic_controller/npc_police
	mapping_anchor = /obj/effect/landmark/police_patrol_point

	possible_outfits = list(
		/datum/outfit/trainstation_civilian/police,
		/datum/outfit/trainstation_civilian/police/alt,
	)

	speech_chance = 15
	speech_phrases = list(
		"Move along, don't linger!",
		"Everything's under control here.",
		"Keep your hands where I can see them.",
		"Suspicious behavior will be reported.",
		"Be careful.",
	)
	speech_emote_see = list(
		"adjusts their beret.",
		"surveys the surroundings.",
		"rests a hand on their baton.",
	)
	speech_emote_hear = list(
		"mutters something into their radio.",
		"clears their throat.",
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

/mob/living/basic/npc/police/baton/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	do_sparks(1, TRUE, src)


/mob/living/basic/npc/police/disabler
	attack_sound = 'sound/items/weapons/egloves.ogg'
	melee_damage_lower = 40
	melee_damage_upper = 40
	melee_attack_cooldown = 3 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/npc_police/ranged

	ranged = TRUE
	item_r_hand = /obj/item/gun/energy/disabler
	projectilesound = 'sound/items/weapons/taser2.ogg'
	casingtype = /obj/projectile/beam/disabler
	burst_shots = 2


/obj/effect/landmark/military_patrol_point
	name = "Military patrol point"


/mob/living/basic/npc/police/military
	health = 300
	maxHealth = 300
	faction = list(FACTION_POLICE, FACTION_NEUTRAL)
	join_text = "You are a soldier. You must maintain order in your zone and protect civilians."
	melee_damage_lower = 15
	melee_damage_upper = 30
	melee_damage_type = BRUTE
	ai_controller = /datum/ai_controller/basic_controller/npc_military
	mapping_anchor = /obj/effect/landmark/military_patrol_point
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5


	ranged = TRUE
	item_r_hand = /obj/item/gun/ballistic/automatic/m90
	projectilesound = 'sound/items/weapons/gun/smg/shot_alt.ogg'
	casingtype = /obj/item/ammo_casing/c38
	burst_shots = 3

	speech_chance = 15
	speech_phrases = list(
		"Move along.",
		"Keep moving.",
		"You don't belong here.",
		"Clear the area.",
		"Hands where I can see them.",
		"Restricted access zone.",
		"Disperse, now.",
		"None of your business.",
		"Step back.",
		"Get out of here.",
		"Area's closed.",
		"Keep walking.",
		"Step aside.",
		"No loitering.",
		"Get moving, civilian."
	)

	speech_emote_see = list(
		"surveys the surroundings.",
		"slightly raises their weapon.",
		"takes a step forward.",
		"keeps a hand on their rifle.",
		"narrows their eyes at you.",
		"sharply waves a hand — move along.",
		"steps into your path.",
		"turns their head, checking their rear.",
		"keeps a hand near their holster.",
		"stares without blinking."
	)

	speech_emote_hear = list(
		"mutters into the radio.",
		"speaks quietly into their headset.",
		"lets out an unintelligible growl.",
		"barks a short code.",
		"whispers coordinates.",
		"quietly reports: \"one civilian\"",
		"mutters: \"another drifter\"",
		"clicks their tongue and switches on the radio.",
		"breathes heavily into the microphone.",
		"repeats a short order under their breath."
	)

	possible_outfits = list(/datum/outfit/trainstation_military)
	inante_abilities = list(
		/datum/action/cooldown/mob_cooldown/knockdown_target = BB_BASIC_MOB_ABILITY_KNOCKDOWN,
		/datum/action/cooldown/mob_cooldown/throw_grenade = BB_BASIC_MOB_ABILITY_THROW_GRENADE,
	)

/mob/living/basic/npc/police/military/sniper
	item_r_hand = /obj/item/gun/ballistic/rifle/sniper_rifle
	projectilesound = 'sound/items/weapons/gun/sniper/shot.ogg'
	casingtype = /obj/item/ammo_casing/p50
	burst_shots = 1
	ranged_cooldown = 7 SECONDS


/mob/living/basic/npc/police/military/bad_guys
	name = "Raider"

	faction = list(FACTION_HOSTILE)
	make_random_name = FALSE
	join_text = "You are a raider. Defend the zone you are in and attack outsiders. Try to keep them alive while doing so."
	important_text = "Do not attack the train, and do not pursue players! Do not remove players from the round entirely!"
	possible_outfits = list(
		/datum/outfit/trainstation_raider,
		/datum/outfit/trainstation_raider/alt,
		/datum/outfit/trainstation_raider/alt_2,
	)

	// item_r_hand = /obj/item/gun/ballistic/automatic/as32
	projectilesound = 'sound/items/weapons/gun/smg/shot_alt.ogg'
	casingtype = /obj/item/ammo_casing/c35sol
	ranged_cooldown = 3 SECONDS
	burst_shots = 3

/mob/living/basic/npc/police/military/bad_guys/meele

	melee_damage_lower = 30
	melee_damage_upper = 30
	ranged = FALSE
	item_r_hand = /obj/item/knife/combat
	item_l_hand = /obj/item/shield/riot
