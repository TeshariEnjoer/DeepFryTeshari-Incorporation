/datum/action/cooldown/mob_cooldown/aoe_slash
	name = "Rending Slash"
	desc = "Unleash a violent area-of-effect slash in front of you, cutting through flesh and matter."
	background_icon_state = "bg_alien"
	cooldown_time = 7 SECONDS
	shared_cooldown = NONE

	var/damage = 50
	var/obj_damage_mult = 4
	var/wound_bonus = 30
	var/armour_penetration = 50
	var/slash_color = "#ff3333"
	var/attack_sound = 'fenysha_events/sounds/mobs/slash_attack_sound.ogg'
	var/attack_cd = CLICK_CD_MELEE
	var/range = 1


/datum/action/cooldown/mob_cooldown/aoe_slash/Activate(atom/target)
	if(!target || get_dist(target, owner) > 1)
		owner.balloon_alert(owner, "To far!")
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(isclosedturf(target_turf))
		return
	. = ..()

	owner.visible_message(
		span_danger("[owner] performs a ferocious sweeping slash!"),
		span_userdanger("You unleash a devastating area slash!")
	)
	new /obj/effect/temp_visual/telegraphing/boss_hit(get_turf(target_turf))
	addtimer(CALLBACK(src, PROC_REF(do_slash), target_turf), 1 SECONDS)
	return TRUE


/datum/action/cooldown/mob_cooldown/aoe_slash/proc/do_slash(turf/target)
	if(get_dist(target, owner) > 1)
		return
	owner.do_attack_animation(target, ATTACK_EFFECT_SLASH)
	new /obj/effect/temp_visual/huge_slash(target, target, world.icon_size / 2, world.icon_size / 2, slash_color)

	playsound(target, attack_sound, 50, vary = TRUE)

	perform_aoe_slash(target)
	owner.changeNext_move(attack_cd)


/datum/action/cooldown/mob_cooldown/aoe_slash/proc/perform_aoe_slash(turf/epicenter)
	var/list/affected = list()
	for(var/turf/T in range(range - 1, epicenter))
		if(get_dist(owner, T) > range)
			continue

		for(var/atom/A in T.contents)
			if(A in affected)
				continue

			if(isliving(A))
				var/mob/living/L = A
				if(L == owner)
					continue

				L.apply_damage(
					damage,
					BRUTE,
					owner.zone_selected,
					wound_bonus = wound_bonus,
					sharpness = SHARP_EDGED,
					attacking_item = src
				)

				log_combat(owner, L, "aoe slashed", src)
				affected += L

			else if(A.uses_integrity)
				A.take_damage(
					damage * obj_damage_mult,
					BRUTE,
					MELEE,
					TRUE,
					src,
					armour_penetration
				)


/obj/effect/temp_visual/huge_slash
	icon_state = "highfreq_slash"
	alpha = 170
	duration = 0.5 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

/obj/effect/temp_visual/huge_slash/Initialize(mapload, atom/target, x_slashed, y_slashed, slash_color)
	. = ..()
	if(!target)
		return
	var/matrix/new_transform = matrix()
	new_transform.Turn(rand(1, 360))
	var/datum/decompose_matrix/decomp = target.transform.decompose()
	new_transform.Translate((x_slashed - ICON_SIZE_X/2) * decomp.scale_x, (y_slashed - ICON_SIZE_Y/2) * decomp.scale_y)


	new_transform.Turn(decomp.rotation)
	new_transform.Translate(decomp.shift_x, decomp.shift_y)
	new_transform.Translate(target.pixel_x, target.pixel_y)
	transform = new_transform

	var/matrix/scaled_transform = new_transform + matrix(new_transform.a, new_transform.b, 0, new_transform.d, new_transform.e, 0)
	scaled_transform.Scale(2, 2)
	animate(src, duration*0.5, color = slash_color, transform = scaled_transform, alpha = 255)


/datum/action/cooldown/mob_cooldown/aoe_slash/extreme
	damage = 100
	obj_damage_mult = 10
	wound_bonus = 100
	armour_penetration = 100

