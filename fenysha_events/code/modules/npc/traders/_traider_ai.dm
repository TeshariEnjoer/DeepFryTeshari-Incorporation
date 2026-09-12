/datum/ai_planning_subtree/return_to_spawn/shopkeeper
	spawn_point_key = BB_NPC_TRAIDER_SHOP

	return_distance = 1 // We trying to stay directly at home
	arrival_distance = 0 //Same tile

/datum/ai_controller/basic_controller/npc_traider

	blackboard = list(
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/combatant,
		BB_NPC_TRAIDER_TRAID_FACTION = list(FACTION_NEUTRAL, FACTION_CIVILIAN),
		BB_NPC_TRADER_INTERUPT_KEY = BB_BASIC_MOB_CURRENT_TARGET,
	)

	ai_movement = /datum/ai_movement/jps/npc
	idle_behavior = null

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pull_response/push_after,
		/datum/ai_planning_subtree/social_alarm,
		/datum/ai_planning_subtree/social_threat,
		/datum/ai_planning_subtree/refresh_social_threat_memory,
		/datum/ai_planning_subtree/weighted_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/knockdown,
		/datum/ai_planning_subtree/clear_social_threats,
		/datum/ai_planning_subtree/return_to_spawn/shopkeeper,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/npc,
	)


/datum/ai_controller/basic_controller/piecefull

	blackboard = list(
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/combatant,
		BB_NPC_TRAIDER_TRAID_FACTION = list(FACTION_NEUTRAL, FACTION_CIVILIAN),
		BB_NPC_TRADER_INTERUPT_KEY = BB_BASIC_MOB_CURRENT_TARGET,
	)

	ai_movement = /datum/ai_movement/jps/npc
	idle_behavior = null

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pull_response/push_after,
		/datum/ai_planning_subtree/social_alarm,
		/datum/ai_planning_subtree/social_threat/to_flee,
		/datum/ai_planning_subtree/refresh_social_threat_memory,
		/datum/ai_planning_subtree/weighted_find_target,
		/datum/ai_planning_subtree/clear_social_threats,
		/datum/ai_planning_subtree/return_to_spawn/shopkeeper,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
	)


