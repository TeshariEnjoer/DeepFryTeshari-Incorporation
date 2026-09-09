#define RUMBLE_RADIUS 3
#define RUMBLE_WARNING_TIME (1.5 SECONDS)
#define RUMBLE_KNOCKDOWN_TIME (3 SECONDS)
#define RUMBLE_THROW_SPEED 1.5

/datum/action/cooldown/mob_cooldown/rumble
	name = "Rumble Earth"
	desc = "Violently shake the ground around you, knocking down and repelling nearby creatures."
	button_icon_state = "berserk_mode"
	cooldown_time = 8 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE

	var/radius = RUMBLE_RADIUS


/datum/action/cooldown/mob_cooldown/rumble/Activate(atom/target)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(run_rumbling))

/datum/action/cooldown/mob_cooldown/rumble/proc/run_rumbling()
	owner.visible_message(
		span_danger("[owner] slams [owner.p_their()] limbs into the ground!"),
		span_userdanger("You slam the ground with tremendous force!")
	)

	playsound(owner, 'sound/effects/bang.ogg', 60, TRUE, frequency = 0.9, extrarange = SILENCED_SOUND_EXTRARANGE)
	var/turf/center = get_turf(owner)
	for(var/turf/T in range(radius, center))
		if(get_dist(center, T) > radius)
			continue
		new /obj/effect/temp_visual/telegraphing/boss_hit(T)
	sleep(RUMBLE_WARNING_TIME)

	rumble_wave(center)

/datum/action/cooldown/mob_cooldown/rumble/proc/rumble_wave(turf/epicenter)
	var/static/list/ripple_sounds = list(
		'sound/effects/bang.ogg',
	)

	var/max_wave_radius = radius + 2
	var/list/affected_mobs = list()

	for(var/current_radius in 1 to max_wave_radius)
		sleep(1.5 + (current_radius * 0.8))
		var/list/ring_turfs = list()
		for(var/turf/T in range(current_radius, epicenter))
			if(get_dist(epicenter, T) == current_radius)
				ring_turfs += T
		if(!length(ring_turfs))
			continue
		for(var/turf/T in ring_turfs)
			animate(T, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 3, loop = 2, easing = JUMP_EASING)
			animate(pixel_x = 0, pixel_y = 0, time = 4)
		CHECK_TICK
		var/volume = clamp(90 - (current_radius * 12), 30, 90)
		playsound(epicenter, pick(ripple_sounds), volume, TRUE, frequency = 0.7 + (current_radius * 0.04))
		for(var/mob/living/L in range(current_radius + 1, epicenter))
			if(L in affected_mobs)
				continue
			if(L == owner)
				continue
			if(L.incorporeal_move)
				continue
			var/dist = get_dist(epicenter, L)
			if(dist < current_radius - 1 || dist > current_radius + 1.5)
				continue

			affected_mobs += L

			var/strength = clamp((max_wave_radius - dist + 1), 1, max_wave_radius)
			L.apply_damage(5 + strength * 2.5, BRUTE, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
			L.Knockdown(2 SECONDS + strength * 1.2)
			L.Paralyze(0.4 SECONDS)

			if(!L.anchored)
				var/dir = get_dir(epicenter, L)
				if(!dir) dir = pick(GLOB.cardinals)

				var/throw_dist = clamp(strength, 1, 5)
				var/turf/target_turf = get_ranged_target_turf(L, dir, throw_dist)
				L.throw_at(target_turf, throw_dist, 1.6, src, spin = FALSE)
		CHECK_TICK
		for(var/mob/M in range(7, epicenter))
			if(current_radius <= 3)
				shake_camera(M, 4, 1.5 + (current_radius * 0.4))
			else
				shake_camera(M, 3, 1)

#undef RUMBLE_RADIUS
#undef RUMBLE_WARNING_TIME
#undef RUMBLE_KNOCKDOWN_TIME
#undef RUMBLE_THROW_SPEED
