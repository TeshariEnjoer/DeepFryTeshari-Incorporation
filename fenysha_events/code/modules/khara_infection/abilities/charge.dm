/datum/action/cooldown/mob_cooldown/boss_charge
	name = "Charge"
	desc = "Charge towards a targeted location, dealing heavy damage on impact."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "goliath_baby"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE

	var/max_range = 10
	var/charge_sound = 'fenysha_events/sounds/mobs/mutant_boss_attack_01.ogg'
	var/charge_delay = 5

/datum/action/cooldown/mob_cooldown/boss_charge/PreActivate(atom/target)
	target = get_turf(target)
	if (get_dist(owner, target) > max_range)
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/boss_charge/Activate(atom/target)
	var/dist = get_dist(owner, target) - 1
	if(dist <= 1)
		owner.balloon_alert(owner, "To close!")
		return
	INVOKE_ASYNC(src, PROC_REF(do_charge), get_turf(target))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/boss_charge/proc/do_charge(turf/target)
	owner.visible_message(span_danger("[owner] charges towards [target]!"))
	if(charge_delay)
		new /obj/effect/temp_visual/telegraphing/boss_hit(target)
		if(!do_after(owner, charge_delay))
			owner.balloon_alert(owner, "Interupted!")
	if(charge_sound)
		playsound(owner, charge_sound, 40)
	var/dist = get_dist(owner, target) - 1
	for(var/i = 1 to dist)
		if(get_dist(owner, target) <= 1)
			break
		new /obj/effect/temp_visual/decoy/fading/halfsecond(owner.loc, owner)
		owner.forceMove(get_step_towards(owner, target))

	for(var/mob/living/living_target in target.contents)
		if(get_dist(owner, living_target) <= 1)
			var/damage = rand(20, 30)
			if(!(living_target.check_block(owner, damage, armour_penetration = 50) == SUCCESSFUL_BLOCK))
				living_target.take_bodypart_damage(damage)
				living_target.Knockdown(10)
				shake_camera(living_target)
	playsound(owner, 'sound/effects/blob/blobattack.ogg', 100, TRUE)

/datum/action/cooldown/mob_cooldown/boss_charge/weak
	max_range = 6
	charge_delay = 1 SECONDS
