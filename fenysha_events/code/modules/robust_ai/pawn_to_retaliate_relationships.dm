/datum/element/ai_social_awareness

	/// Range in which information about an attack is spread.
	var/alarm_range = 9

	/// How long the victim keeps broadcasting the attack.
	var/alarm_duration = 10 SECONDS


/datum/element/ai_social_awareness/Attach(datum/target)

	. = ..()

	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	target.AddElement(/datum/element/relay_attackers)

	RegisterSignal(
		target,
		COMSIG_ATOM_WAS_ATTACKED,
		PROC_REF(on_attacked)
	)

	ADD_TRAIT(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)


/datum/element/ai_social_awareness/Detach(
	datum/source,
	...
)

	. = ..()

	UnregisterSignal(
		source,
		COMSIG_ATOM_WAS_ATTACKED
	)


/datum/element/ai_social_awareness/proc/on_attacked(
	mob/living/victim,
	atom/attacker
)

	SIGNAL_HANDLER

	if(!attacker || attacker == victim)
		return

	if(!isliving(attacker))
		return

	var/mob/living/living_attacker = attacker

	// Remember the attacker locally.
	report_attacker(
		victim,
		living_attacker
	)

	// Start or refresh the victim's social alarm.
	if(victim.ai_controller)
		victim.ai_controller.set_blackboard_key(
			BB_BASIC_MOB_SOCIAL_ALARM_TARGET,
			living_attacker
		)

		victim.ai_controller.set_blackboard_key(
			BB_BASIC_MOB_SOCIAL_ALARM_UNTIL,
			world.time + alarm_duration
		)

	// Immediately spread the information.
	broadcast_attacker(
		victim,
		living_attacker
	)


/datum/element/ai_social_awareness/proc/report_attacker(
	mob/living/victim,
	mob/living/attacker
)

	if(!victim.ai_controller || !attacker)
		return

	victim.ai_controller.set_blackboard_key_assoc_lazylist(
		BB_BASIC_MOB_RETALIATE_LIST,
		attacker,
		world.time
	)


/datum/element/ai_social_awareness/proc/broadcast_attacker(
	mob/living/victim,
	mob/living/attacker
)

	if(!attacker)
		return

	for(var/mob/living/observer in viewers(alarm_range, victim))

		if(observer == victim)
			continue

		if(!observer.ai_controller)
			continue

		// The observer must be able to actually see the victim.
		if(!can_see(observer, victim, alarm_range))
			continue

		report_attacker(
			observer,
			attacker
		)

/*
 * SOCIAL THREAT
 *
 * Selects a remembered offender as the current target.
 *
 * This does NOT force the NPC to attack.
 * Different descendants can use the selected target for combat, fleeing,
 * protecting somebody, warning others, etc.
 */


/datum/ai_planning_subtree/social_threat

	operational_datums = list(
		/datum/element/ai_social_awareness
	)

	/// Blackboard key containing remembered threats.
	var/threat_list_key = BB_BASIC_MOB_RETALIATE_LIST

	/// Blackboard key containing selected threat.
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

	/// Blackboard key containing hiding location.
	var/hiding_place_key = BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION

	/// Blackboard key containing target validation strategy.
	var/targeting_strategy_key = BB_TARGETING_STRATEGY

	/// Whether faction restrictions are respected.
	var/check_faction = FALSE

	/// Behavior responsible for selecting a threat.
	var/target_behavior = /datum/ai_behavior/social_threat


/datum/ai_planning_subtree/social_threat/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)

	controller.queue_behavior(
		target_behavior,
		threat_list_key,
		target_key,
		targeting_strategy_key,
		hiding_place_key,
		check_faction
	)


/datum/ai_planning_subtree/social_threat/check_faction

	check_faction = TRUE


/datum/ai_planning_subtree/social_threat/to_flee

	target_key = BB_BASIC_MOB_FLEE_TARGET
	hiding_place_key = BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION
	targeting_strategy_key = BB_FLEE_TARGETING_STRATEGY

/datum/ai_behavior/social_threat

	action_cooldown = 2 SECONDS

	/// Maximum range at which the offender can be directly targeted.
	var/vision_range = 9


/datum/ai_behavior/social_threat/perform(
	seconds_per_tick,
	datum/ai_controller/controller,
	threat_list_key,
	target_key,
	targeting_strategy_key,
	hiding_location_key,
	check_faction
)

	var/mob/living/living_mob = controller.pawn

	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/list/threat_list = controller.blackboard[threat_list_key]

	if(!threat_list || !islist(threat_list))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/current_target = controller.blackboard[target_key]

	// Preserve a currently valid target.
	if(current_target && targeting_strategy.can_attack(
			living_mob,
			current_target,
			vision_range
		)
	)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(!check_faction)
		controller.set_blackboard_key(
			BB_TEMPORARILY_IGNORE_FACTION,
			TRUE
		)

	var/list/valid_targets = list()

	for(var/mob/living/potential_target as anything in threat_list)

		if(QDELETED(potential_target))
			continue

		if(!targeting_strategy.can_attack(
			living_mob,
			potential_target,
			vision_range
		))
			continue

		valid_targets += potential_target

	if(!length(valid_targets))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[BB_TARGET_PRIORITY_STRATEGY])

	var/atom/new_target

	if(priority_strategy)
		new_target = priority_strategy.select_target(
			controller,
			valid_targets
		)
	else
		new_target = pick(valid_targets)

	if(!new_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(
		target_key,
		new_target
	)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(
		living_mob,
		new_target
	)

	if(potential_hiding_location)
		controller.set_blackboard_key(
			hiding_location_key,
			potential_hiding_location
		)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_behavior/social_threat/finish_action(
	datum/ai_controller/controller,
	succeeded,
	threat_list_key,
	target_key,
	targeting_strategy_key,
	hiding_location_key,
	check_faction
)

	. = ..()

	if(succeeded || check_faction)
		return

	var/usually_ignores_faction = (controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || FALSE)
	controller.set_blackboard_key(
		BB_TEMPORARILY_IGNORE_FACTION,
		usually_ignores_faction
	)


/*
 * ============================================================================
 * CLEAR SOCIAL THREATS
 * ============================================================================
 */


/datum/ai_planning_subtree/clear_social_threats

	var/threat_list_key = BB_BASIC_MOB_RETALIATE_LIST

	/// How long an attacker remains remembered.
	var/memory_duration = 20 SECONDS

	/// Forget attackers outside this distance.
	var/forget_distance = 30

	/// Forget dead attackers.
	var/clear_if_dead = TRUE

	/// Forget restrained attackers.
	var/clear_if_restrained = TRUE


/datum/ai_planning_subtree/clear_social_threats/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)

	var/list/threat_list = controller.blackboard[threat_list_key]

	if(!threat_list || !islist(threat_list))
		return

	controller.queue_behavior(
		/datum/ai_behavior/clear_social_threats,
		threat_list_key,
		memory_duration,
		forget_distance,
		clear_if_dead,
		clear_if_restrained
	)

/datum/ai_behavior/clear_social_threats


/datum/ai_behavior/clear_social_threats/perform(
	seconds_per_tick,
	datum/ai_controller/controller,
	threat_list_key,
	memory_duration,
	forget_distance,
	clear_if_dead,
	clear_if_restrained
)

	var/list/threat_list = controller.blackboard[threat_list_key]

	if(!threat_list || !islist(threat_list))
		return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_INSTANT

	var/mob/living/pawn = controller.pawn

	for(var/mob/living/enemy as anything in threat_list)

		var/last_update = threat_list[enemy]

		// Deleted target.
		if(QDELETED(enemy))
			threat_list -= enemy
			continue

		// Invalid memory record.
		if(isnull(last_update))
			threat_list -= enemy
			continue

		// Memory naturally decays over time.
		if(world.time - last_update >= memory_duration)
			threat_list -= enemy
			continue

		// Extremely distant offenders are no longer relevant.
		if(get_dist(pawn, enemy) > forget_distance)
			threat_list -= enemy
			continue

		// Dead offenders are no longer an active threat.
		if(clear_if_dead && enemy.stat == DEAD)
			threat_list -= enemy
			continue

		// A restrained offender is no longer an immediate threat.
		if(clear_if_restrained && iscarbon(enemy))

			var/mob/living/carbon/carbon_enemy = enemy

			if(carbon_enemy.handcuffed)
				threat_list -= enemy
				continue

	return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_INSTANT


/*
 * REFRESH SOCIAL MEMORY
 *
 * If the NPC sees a remembered offender again, the memory is refreshed.
 */


/datum/ai_planning_subtree/refresh_social_threat_memory

	var/memory_key = BB_BASIC_MOB_RETALIATE_LIST

	var/update_range = 9


/datum/ai_planning_subtree/refresh_social_threat_memory/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)

	var/list/memory = controller.blackboard[memory_key]

	if(!memory || !islist(memory))
		return

	var/mob/living/pawn = controller.pawn

	for(var/mob/living/known_enemy as anything in memory)

		if(QDELETED(known_enemy))
			memory -= known_enemy
			continue

		if(!can_see(
			pawn,
			known_enemy,
			update_range
		))
			continue

		memory[known_enemy] = world.time



/*
 * SOCIAL ALARM
 *
 * After being attacked, an NPC keeps broadcasting the identity of its attacker
 * for a limited amount of time.
 *
 * This behavior is intentionally separate from social_threat.
 * Knowing about an attacker and responding to that attacker are two different
 * decisions.
 */


/datum/ai_planning_subtree/social_alarm

	var/alarm_target_key = BB_BASIC_MOB_SOCIAL_ALARM_TARGET

	var/alarm_until_key = BB_BASIC_MOB_SOCIAL_ALARM_UNTIL

	var/alarm_range = 9

	var/default_alarm_duration = 10 SECONDS

	var/broadcast_behavior = /datum/ai_behavior/broadcast_social_alarm


/datum/ai_planning_subtree/social_alarm/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)

	var/mob/living/attacker = controller.blackboard[alarm_target_key]

	if(!attacker || QDELETED(attacker))
		controller.clear_blackboard_key(
			alarm_target_key
		)

		controller.clear_blackboard_key(
			alarm_until_key
		)

		return

	var/alarm_until = controller.blackboard[alarm_until_key]

	if(!alarm_until)
		controller.set_blackboard_key(
			alarm_until_key,
			world.time + default_alarm_duration
		)
		return

	if(alarm_until <= world.time)
		controller.clear_blackboard_key(
			alarm_target_key
		)

		controller.clear_blackboard_key(
			alarm_until_key
		)

		return

	// Continue broadcasting until the alarm expires.
	controller.queue_behavior(
		broadcast_behavior,
		alarm_target_key,
		alarm_until_key,
		alarm_range
	)


/datum/ai_behavior/broadcast_social_alarm

	action_cooldown = 2 SECONDS


/datum/ai_behavior/broadcast_social_alarm/perform(
	seconds_per_tick,
	datum/ai_controller/controller,
	alarm_target_key,
	alarm_until_key,
	alarm_range
)

	var/mob/living/victim = controller.pawn

	var/mob/living/attacker = controller.blackboard[alarm_target_key]

	if(!attacker || QDELETED(attacker))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/alarm_until = controller.blackboard[alarm_until_key]

	if(!alarm_until || alarm_until <= world.time)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/mob/living/observer in viewers(alarm_range, victim))

		if(observer == victim)
			continue

		if(!observer.ai_controller)
			continue

		if(!can_see(
			observer,
			victim,
			alarm_range
		))
			continue

		observer.ai_controller.set_blackboard_key_assoc_lazylist(
			BB_BASIC_MOB_RETALIATE_LIST,
			attacker,
			world.time
		)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
