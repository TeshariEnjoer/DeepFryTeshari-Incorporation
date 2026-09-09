/mob/living/basic/khara_mutant/flesh_human
	name = "Flesh Humanoid"
	desc = "A terrifying humanoid creature that was clearly a human until recently. Its whole body trembles, bending unnaturally, \
			while four appendages on its back undulate rapidly."
	icon = 'fenysha_events/icons/mob/48x48.dmi'
	icon_state = "khara_slasher"
	icon_living = "khara_slasher"
	icon_dead = "khara_slasher"
	speak_emote = list("writhes")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "push aside"
	ai_controller = /datum/ai_controller/basic_controller/giant_spider
	melee_damage_upper = 20
	melee_damage_lower = 20
	armour_penetration = 40

	shock_multiplier = 1.5
	baton_stun_amount = 3 SECONDS
	baton_stun_cooldown = 3 SECONDS
	shock_stun_cooldown = 2 SECONDS
	regeneration_delay = 7 SECONDS

	pixel_x = -12
	base_pixel_x = -12

	speed = 0
	health = 250
	maxHealth = 250
	spread_blood_radius = 1
	minimum_melee_damage_treshold = 15

	var/evade_cooldown = 0.8 SECONDS
	var/evade_steps = 1
	var/evade_chance = 80

/mob/living/basic/khara_mutant/flesh_human/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/projectile_evade, \
		evade_chance = evade_chance, \
		evade_cooldown = evade_cooldown, \
		callback_check = CALLBACK(src, PROC_REF(try_evade)) \
	)

/mob/living/basic/khara_mutant/flesh_human/proc/try_evade(atom/source, obj/projectile/hitting_projectile, def_zone, piercing_hit)
	if(stat == DEAD)
		return FALSE
	if(istype(hitting_projectile, /obj/projectile/energy/anti_khara))
		return FALSE
	return TRUE
