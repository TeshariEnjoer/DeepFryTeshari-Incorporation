/datum/ai_planning_subtree/targeted_mob_ability/throw_grenade

	ability_key = BB_BASIC_MOB_ABILITY_THROW_GRENADE

	var/minimum_distance = 3
	var/maximum_distance = 8
	var/minimum_targets = 1
	var/explosion_radius = 2


/datum/ai_planning_subtree/targeted_mob_ability/throw_grenade/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)
	if(!controller.blackboard_key_exists(target_key))
		return

	var/mob/living/pawn = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]

	if(!iscarbon(target))
		return

	if(target == pawn)
		return

	var/distance = get_dist(pawn, target)

	if(distance < minimum_distance || distance > maximum_distance)
		return

	if(!can_see(pawn, target, maximum_distance))
		return

	var/nearby_targets = 0

	for(var/mob/living/carbon/nearby in oview(explosion_radius, target))
		if(nearby == pawn)
			continue

		if(!nearby.stat)
			if(!pawn.faction_check_atom(nearby))
				nearby_targets++

	if(nearby_targets < minimum_targets)
		return

	return ..()

/datum/action/cooldown/mob_cooldown/throw_grenade
	name = "Throw Grenade"
	desc = "Throw grande at target."

	cooldown_time = 30 SECONDS
	shared_cooldown = null

	var/obj/item/grenade/grenade_type = /obj/item/grenade/syndieminibomb/concussion
	button_icon = 'icons/obj/weapons/grenade.dmi'
	button_icon_state = "concussion"

/datum/action/cooldown/mob_cooldown/throw_grenade/Activate(atom/target)
	var/mob/living/user = owner

	if(QDELETED(user))
		return

	user.visible_message(span_userdanger("[user] is preparing to throw grenade at [target]!"))
	if(!do_after(user, 1.5 SECONDS, user, max_interact_count = 1))
		StartCooldown(3 SECONDS)
		return

	var/obj/item/grenade/G = new grenade_type(get_turf(user))
	G.arm_grenade(user)
	G.throw_at(target, get_dist(user, target), 3, user, TRUE)
	return ..()

