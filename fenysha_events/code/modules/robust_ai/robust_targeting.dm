/datum/target_priority_strategy/mutant

/datum/target_priority_strategy/mutant/get_target_priority(
	datum/ai_controller/controller,
	atom/target
)
	if(!target)
		return -INFINITY

	var/mob/living/pawn = controller.pawn

	// Non-living attackable objects remain valid targets.
	// Give them a meaningful baseline instead of making their priority
	if(!isliving(target))
		return 25

	var/mob/living/living_target = target

	if(living_target.stat == DEAD)
		return -INFINITY

	var/score = 0
	var/distance = get_dist(pawn, living_target)

	score += max(0, 30 - distance * 3)

	if(living_target == controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		score += 35

	if(living_target.stat == UNCONSCIOUS)
		score += 180

	if(living_target.body_position == LYING_DOWN)
		score += 90

	if(living_target.maxHealth > 0)
		var/health_ratio = clamp(
			living_target.health / living_target.maxHealth,
			0,
			1
		)

		score += round((1 - health_ratio) * 120)

		if(health_ratio <= 0.2)
			score += 60
		else if(health_ratio <= 0.4)
			score += 30

	if(iscarbon(living_target))
		var/mob/living/carbon/carbon_target = living_target

		var/damage = carbon_target.get_brute_loss() + carbon_target.get_fire_loss()

		if(damage >= 75)
			score += 35
		else if(damage >= 50)
			score += 20
		else if(damage >= 25)
			score += 10

		if(!carbon_target.get_bodypart(BODY_ZONE_L_LEG))
			score += 35

		if(!carbon_target.get_bodypart(BODY_ZONE_R_LEG))
			score += 35

		if(!carbon_target.get_bodypart(BODY_ZONE_L_ARM))
			score += 15

		if(!carbon_target.get_bodypart(BODY_ZONE_R_ARM))
			score += 15

	score += rand(-5, 5)

	return score


/datum/target_priority_strategy/mutant/select_target(
	datum/ai_controller/controller,
	list/targets
)
	if(!length(targets))
		return

	var/best_target
	var/best_score = -INFINITY

	for(var/atom/target as anything in targets)
		var/score = get_target_priority(
			controller,
			target
		)

		if(isliving(target))
			score += rand(-3, 3)

		if(score > best_score)
			best_score = score
			best_target = target

	return best_target


/datum/target_priority_strategy/combatant

/datum/target_priority_strategy/combatant/get_target_priority(
	datum/ai_controller/controller,
	atom/target
)
	if(!target)
		return -INFINITY

	var/mob/living/pawn = controller.pawn

	// Non-living targets remain valid, but are less important than combatants.
	if(!isliving(target))
		return 25

	var/mob/living/living_target = target

	if(living_target.stat == DEAD)
		return -INFINITY

	var/score = 0

	// Closer enemies are slightly more attractive.
	var/distance = get_dist(pawn, living_target)
	score += max(0, distance * 60)

	// Avoid constantly switching away from the current target.
	if(living_target == controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		score += 35

	// Incapacitated enemies are easy targets.
	if(living_target.stat == UNCONSCIOUS)
		score += 100

	if(living_target.body_position == LYING_DOWN)
		score += 45

	// Injured targets are still attractive.
	if(living_target.maxHealth > 0)
		var/health_ratio = clamp(
			living_target.health / living_target.maxHealth,
			0,
			1
		)

		score += round((1 - health_ratio) * 80)

		if(health_ratio <= 0.2)
			score += 40
		else if(health_ratio <= 0.4)
			score += 20

	if(iscarbon(living_target))
		var/mob/living/carbon/carbon_target = living_target

		var/weapon_score = 0

		for(var/obj/item/item in carbon_target.held_items)
			if(!item)
				continue

			if(item.item_flags & ABSTRACT)
				continue

			if(istype(item, /obj/item/gun))
				weapon_score += 100
				continue

			if(istype(item, /obj/item/melee))
				weapon_score += 60
				continue

			if(istype(item, /obj/item/grenade))
				weapon_score += 80
				continue

		score += weapon_score
		var/armor_score = 0

		for(var/obj/item/clothing/clothing in carbon_target.get_equipped_items())
			if(!clothing)
				continue

			var/datum/armor/armor = clothing.get_armor()

			if(armor)
				if(armor.get_rating(MELEE))
					armor_score += armor.get_rating(MELEE)

				if(armor.get_rating(BULLET))
					armor_score += armor.get_rating(BULLET)

		score += armor_score
		var/damage = carbon_target.get_brute_loss() + carbon_target.get_fire_loss()

		if(damage >= 75)
			score += 30
		else if(damage >= 50)
			score += 20
		else if(damage >= 25)
			score += 10

		if(!carbon_target.get_bodypart(BODY_ZONE_L_LEG))
			score += 25

		if(!carbon_target.get_bodypart(BODY_ZONE_R_LEG))
			score += 25

		if(weapon_score >= 100)
			score += 75

	score += rand(-5, 5)

	return score


/datum/target_priority_strategy/combatant/select_target(
	datum/ai_controller/controller,
	list/targets
)
	if(!length(targets))
		return

	var/best_target
	var/best_score = -INFINITY

	for(var/atom/target as anything in targets)
		var/score = get_target_priority(
			controller,
			target
		)

		if(isliving(target))
			score += rand(-3, 3)

		if(score > best_score)
			best_score = score
			best_target = target

	return best_target


/// Weighted target selection.
///
/// The only behavioral difference is target filtering:
/// instead of discarding targets which score below the current target,
/// all valid targets are passed to the priority strategy.

/datum/ai_behavior/find_potential_targets/weighted

/datum/ai_behavior/find_potential_targets/weighted/perform(
	seconds_per_tick,
	datum/ai_controller/controller,
	target_key,
	targeting_strategy_key,
	hiding_location_key
)
	var/mob/living/living_mob = controller.pawn

	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[priority_strategy_key])
	if(!priority_strategy)
		CRASH("No target priority strategy was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]

	// Keep the current target until the refresh cooldown expires.
	// A target which is no longer attackable is immediately discarded.
	if( \
		controller.blackboard[BB_BASIC_MOB_TARGET_REFRESH_COOLDOWN] > world.time \
		&& current_target \
		&& targeting_strategy.can_attack(living_mob, current_target, vision_range) \
	)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = vision_range

	if(isnull(current_target) && !isnull(controller.blackboard[aggro_grab_range_key]))
		aggro_range = controller.blackboard[aggro_grab_range_key]
	else if(!isnull(controller.blackboard[aggro_range_key]))
		aggro_range = controller.blackboard[aggro_range_key]

	controller.clear_blackboard_key(target_key)

	// We already have a proximity field watching for targets.
	if(controller.blackboard[BB_FIND_TARGETS_FIELD(type)])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/potential_targets = hearers(
		aggro_range,
		get_turf(controller.pawn)
	) - living_mob

	// Search for hostile machinery separately.
	var/turf/mob_turf = get_turf(living_mob)

	if(mob_turf?.z)
		for(var/atom/hostile_machine as anything in GLOB.hostile_machines_by_z[mob_turf.z])
			if(can_see(living_mob, hostile_machine, aggro_range))
				potential_targets += hostile_machine

	if(!potential_targets.len)
		if(!current_target)
			failed_to_find_anyone(
				controller,
				target_key,
				targeting_strategy_key,
				hiding_location_key
			)

		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	// Filter ONLY by whether the target can actually be attacked.
	//
	// Unlike the standard behavior, we deliberately do not compare the
	// candidate with the current target's priority here.

	var/list/filtered_targets = list()

	for(var/atom/pot_target in potential_targets)
		if(!targeting_strategy.can_attack(
			living_mob,
			pot_target,
			vision_range
		))
			continue

		filtered_targets += pot_target

	if(!filtered_targets.len)
		if(!current_target)
			failed_to_find_anyone(
				controller,
				target_key,
				targeting_strategy_key,
				hiding_location_key
			)

		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	// Let the priority strategy make the actual decision.

	var/atom/target = pick_final_target(
		controller,
		filtered_targets
	)

	if(!target)
		if(!current_target)
			failed_to_find_anyone(
				controller,
				target_key,
				targeting_strategy_key,
				hiding_location_key
			)

		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[controller.pawn] has selected [target] as a weighted target for blackboard key [target_key]! Behavior: [src]", get_turf(target), "Target: [target]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to weighted target", get_turf(controller.pawn), get_turf(target))

	controller.set_blackboard_key(
		target_key,
		target
	)

	controller.set_blackboard_key(
		BB_BASIC_MOB_TARGET_REFRESH_COOLDOWN,
		world.time + priority_refresh_cooldown
	)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(
		living_mob,
		target
	)

	if(potential_hiding_location)
		controller.set_blackboard_key(
			hiding_location_key,
			potential_hiding_location
	)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_behavior/find_potential_targets/weighted/pick_final_target(
	datum/ai_controller/controller,
	list/filtered_targets
)
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[priority_strategy_key])

	if(!priority_strategy)
		return pick(filtered_targets)

	return priority_strategy.select_target(
		controller,
		filtered_targets
	)

/datum/ai_planning_subtree/weighted_find_target

	/// Variable to store target in.
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

	/// Targeting strategy key to use.
	var/strategy_key = BB_TARGETING_STRATEGY

	/// Behavior to use to find targets.
	var/target_behavior = /datum/ai_behavior/find_potential_targets/weighted


/datum/ai_planning_subtree/weighted_find_target/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)
	. = ..()

	controller.queue_behavior(
		target_behavior,
		target_key,
		strategy_key,
		BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION
	)



/datum/ai_planning_subtree/basic_ranged_attack_subtree/npc
	operational_datums = list(/datum/component/advanced_ranged_attacks)
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/npc

/datum/ai_planning_subtree/basic_ranged_attack_subtree/npc/ranged
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/npc/very_ranged

/datum/ai_planning_subtree/basic_ranged_attack_subtree/npc/no_chase
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/npc/no_chase

/datum/ai_behavior/basic_ranged_attack/npc
	required_distance = 9
	chase_range = 18
	avoid_friendly_fire = TRUE

/datum/ai_behavior/basic_ranged_attack/npc/no_chase
	required_distance = 9
	chase_range = 0
	avoid_friendly_fire = TRUE

/datum/ai_behavior/basic_ranged_attack/npc/very_ranged
	required_distance = 20
	chase_range = 0
	avoid_friendly_fire = TRUE
