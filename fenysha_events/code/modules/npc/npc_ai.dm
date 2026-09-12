/datum/ai_planning_subtree/npc_talk
	operational_datums = list(/datum/element/npc_talk)
	var/talk_cooldown_key = BB_NPC_TALK_COOLDOWN
	var/last_talk_key = BB_NPC_LAST_TALK

/datum/ai_planning_subtree/npc_talk/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[last_talk_key] && \
		(world.time < controller.blackboard[last_talk_key] + controller.blackboard[talk_cooldown_key]))
		return

	var/mob/living/npc = controller.pawn
	if(!npc)
		return

	var/list/talk_context = get_talk_context(controller)
	if(!length(talk_context))
		return

	controller.set_blackboard_key(last_talk_key, world.time)
	SEND_SIGNAL(npc, COMSIG_NPC_TALK, talk_context)

/datum/ai_planning_subtree/npc_talk/proc/get_talk_context(datum/ai_controller/controller)
	var/mob/living/npc = controller.pawn
	var/list/context = list()

	if(!npc)
		return context

	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	if(current_target)
		context[NPC_TALK_KEY_TARGET] = current_target

	if(npc.stat != CONSCIOUS)
		return context

	if(npc.maxHealth > 0)
		var/health_ratio = clamp(
			npc.health / npc.maxHealth,
			0,
			1
		)

		if(health_ratio < 1)
			context[NPC_TALK_KEY_INJURED] = TRUE

		if(health_ratio <= 0.3)
			context[NPC_TALK_KEY_LOWHEALTH] = TRUE

	var/aggro_range = controller.blackboard[BB_BASIC_MOB_OVERRIDE_VISION_RANGE]

	if(!aggro_range)
		aggro_range = 7

	var/list/nearby_targets = hearers(aggro_range,get_turf(npc)) - npc
	var/enemy_count = 0

	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])

	if(targeting_strategy)
		for(var/atom/potential_target in nearby_targets)
			if(!targeting_strategy.can_attack(
				npc,
				potential_target,
				aggro_range
			))
				continue

			enemy_count++

	if(enemy_count)
		context[NPC_TALK_KEY_ENEMY_NEARBY] = TRUE

	if(enemy_count >= 4)
		context[NPC_TALK_KEY_ENEMY_CROWD_NEARBY] = TRUE

	if(enemy_count > 0 && !current_target)
		context[NPC_TALK_KEY_IN_DANGER] = TRUE

	if(!current_target && !enemy_count)
		context[NPC_TALK_KEY_IDLE] = TRUE

	return context


/datum/ai_movement/jps/npc
	max_pathing_attempts = 8

/datum/ai_controller/basic_controller/npc_civilian

	blackboard = list(
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_NPC_TALK_COOLDOWN = 30 SECONDS,
	)

	ai_movement = /datum/ai_movement/jps/npc
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pull_response/push_after,
		/datum/ai_planning_subtree/social_alarm,
		/datum/ai_planning_subtree/social_threat/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/refresh_social_threat_memory,
		/datum/ai_planning_subtree/npc_talk,
		/datum/ai_planning_subtree/clear_social_threats,
	)


/datum/ai_controller/basic_controller/npc_military

	blackboard = list(
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/combatant,
		BB_BASIC_MOB_CAN_USE_PATROL_POINTS = TRUE,
	)

	ai_movement = /datum/ai_movement/jps/npc

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pull_response/push_after,
		/datum/ai_planning_subtree/social_alarm,
		/datum/ai_planning_subtree/social_threat,
		/datum/ai_planning_subtree/refresh_social_threat_memory,
		/datum/ai_planning_subtree/weighted_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/knockdown,
		/datum/ai_planning_subtree/targeted_mob_ability/throw_grenade,
		/datum/ai_planning_subtree/clear_social_threats,
		/datum/ai_planning_subtree/return_to_spawn,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/npc,
	)
