/datum/action/cooldown/mob_cooldown/mech_crush
	name = "Destroy Mech"
	button_icon = 'icons/mob/rideables/mecha.dmi'
	button_icon_state = "seraph-broken"
	desc = "Attack a mech, tearing it apart and destroying the pilot."
	cooldown_time = 1 SECONDS

	var/rip_chance = 33
	var/continues_rip_chance = 10
	var/internal_damage_chance = 20
	var/slash_armor_penetration = 70
	var/damage_per_slash = 60
	var/crushing = FALSE
	var/maximum_distance = 1
	var/time_per_slash = 2.5 SECONDS
	var/time_to_grag = 3 SECONDS

/datum/action/cooldown/mob_cooldown/mech_crush/PreActivate(atom/target)
	if(crushing)
		return FALSE
	if(!ismecha(target))
		return FALSE
	. = ..()

/datum/action/cooldown/mob_cooldown/mech_crush/Activate(atom/target)
	if(get_dist(target, owner) > maximum_distance)
		owner.balloon_alert(owner, "Too far away")
		StartCooldown()
		return
	crushing = TRUE
	StartCooldown()
	owner.balloon_alert_to_viewers("Leaps at [target]")
	INVOKE_ASYNC(src, PROC_REF(crush_mech), target, owner)


/datum/action/cooldown/mob_cooldown/mech_crush/proc/check_continue(obj/vehicle/sealed/mecha/mech, mob/living/user)
	if(QDELETED(mech) \
		|| QDELETED(user) \
		|| user.stat == DEAD \
		|| get_dist(mech, user) > maximum_distance \
		|| !user.can_perform_action(mech, BYPASS_ADJACENCY|ALLOW_RESTING) \
	)
		return FALSE
	return TRUE

#define ACTION_IGNORES (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE)

/datum/action/cooldown/mob_cooldown/mech_crush/proc/crush_mech(obj/vehicle/sealed/mecha/mech, mob/living/user, hits = 0)
	if(!check_continue(mech, user))
		user.balloon_alert_to_viewers("Stops mauling [mech ? mech : "the mech"]!")
		crushing = FALSE
		return

	var/next_delay = hits ? time_per_slash * max(0.4, (1 - hits)) : time_per_slash
	if(!do_after(user, next_delay, mech, ACTION_IGNORES, \
		extra_checks = CALLBACK(src, PROC_REF(check_continue), mech, user), \
		max_interact_count = 1))

		user.balloon_alert_to_viewers("Stops mauling [mech ? mech : "the mech"]!")
		crushing = FALSE
		return

	var/message = span_warning(pick(list(
		"[user] mercilessly gnaws into the armor of [mech]!",
		"[user] rips apart the armor segments of [mech] with a crunch!",
		"[user] gnaws between the joints of [mech]!",
		"[user] literally tears the armor of [mech] in two!",
		"Sparks and charred chunks fly out from under the armor of [mech]!",
		"[user]'s limb plunges into the hull of [mech] with a horrible grinding sound!",
		"[user] tears the armor plates of [mech] to shreds with savage force!",
		"[user] crunches through the outer layer of [mech]'s armor!",
		"The armor of [mech] cracks and bursts under [user]'s blow!",
		"Acrid smoke and sparks pour from the breach in [mech]!",
		"[user] cuts through the armor of [mech] with terrifying ease, like paper!",
		"The armor of [mech] flies apart from [user]'s powerful blow!"
	)))

	user.visible_message(message, span_warning("You maul the armor of [mech]!"), span_warning("You hear the sounds of clanging metal!"))
	do_sparks(rand(3, 4), TRUE, mech)
	user.do_attack_animation(mech)
	var/damage = mech.take_damage(damage_per_slash, BRUTE, attack_dir = get_dir(user, mech), armour_penetration = slash_armor_penetration)
	if(!damage)
		damage = mech.take_damage(damage_per_slash * 0.3, BRUTE, attack_dir = get_dir(user, mech), armour_penetration = 100)

	new /obj/effect/temp_visual/slash(get_turf(mech), mech, world.icon_size / 2, world.icon_size / 2, COLOR_RED)
	sleep(0.1 SECONDS)

	if(!check_continue(mech, user))
		user.balloon_alert_to_viewers("Stops mauling [mech ? mech : "the mech"]!")
		crushing = FALSE
		return

	if(damage && prob(rip_chance) && mech.flat_equipment)
		for(var/obj/item/mecha_parts/mecha_equipment/qeuipment in shuffle(mech.flat_equipment.Copy()))
			qeuipment.detach()
			do_sparks(rand(3, 4), TRUE, mech)
			user.visible_message(span_danger("[user] aggressively rips [qeuipment] out of [mech], breaking it!"),
								span_warning("You rip [qeuipment] out of [mech]!"))


			new /obj/effect/temp_visual/slash(get_turf(mech), mech, world.icon_size / 2, world.icon_size / 2, COLOR_RED)
			qdel(qeuipment)
			new /obj/effect/decal/cleanable/blood/gibs/robot_debris/up(pick(shuffle(get_adjacent_turfs(mech))))
			if(!prob(continues_rip_chance))
				break
			if(!check_continue(mech, user))
				crushing = FALSE
				return
			sleep(0.2 SECONDS)

	if(!check_continue(mech, user))
		user.balloon_alert_to_viewers("Stops mauling [mech ? mech : "the mech"]!")
		crushing = FALSE
		return

	if(damage && prob(internal_damage_chance))
		var/internal_damage_to_deal = mech.possible_int_damage
		internal_damage_to_deal &= ~mech.internal_damage

		if(internal_damage_to_deal)
			mech.set_internal_damage(pick(bitfield_to_list(internal_damage_to_deal)))

	hits += 1
	addtimer(CALLBACK(src, PROC_REF(crush_mech), mech, user, hits), 1)

#undef ACTION_IGNORES
