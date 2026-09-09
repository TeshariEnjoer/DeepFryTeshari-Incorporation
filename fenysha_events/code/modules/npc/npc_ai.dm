/datum/ai_movement/jps/npc
	max_pathing_attempts = 8

/datum/ai_controller/basic_controller/npc_civilian

	blackboard = list(
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/jps/npc
	idle_behavior = /datum/idle_behavior/idle_random_walk/often

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pull_response/push_after,
		/datum/ai_planning_subtree/social_alarm,
		/datum/ai_planning_subtree/social_threat/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/refresh_social_threat_memory,
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
	idle_behavior = /datum/idle_behavior/return_to_spawn

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
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/npc,
	)
