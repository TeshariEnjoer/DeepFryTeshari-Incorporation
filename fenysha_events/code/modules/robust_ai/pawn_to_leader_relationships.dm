/datum/ai_planning_subtree/find_leader

	var/prefer_player = FALSE
	var/same_faction = TRUE

	/// Behavior which controls the mob while it has a leader.
	var/pawn_leader_behaviour = /datum/ai_behavior/pawn_leader

	/// How far we are willing to search for a leader.
	var/leader_search_range = 15

	/// Maximum distance at which an existing leader is considered valid.
	var/leader_max_distance = 30

	/// How often we are allowed to search for another leader.
	var/leader_search_cooldown = 5 SECONDS

/datum/ai_planning_subtree/find_leader/proc/can_be_leader(
	mob/living/pawn,
	mob/living/candidate
)
	return FALSE


/datum/ai_planning_subtree/find_leader/proc/get_leader_score(
	mob/living/pawn,
	mob/living/candidate
)
	return 0


/datum/ai_planning_subtree/find_leader/proc/on_leader_found(
	datum/ai_controller/controller,
	mob/living/leader
)
	return

/datum/ai_planning_subtree/find_leader/proc/find_new_leader(
	datum/ai_controller/controller
)
	var/mob/living/pawn = controller.pawn
	var/mob/living/best_leader
	var/best_score = -INFINITY

	for(var/mob/living/candidate in hearers(leader_search_range, pawn))
		if(candidate == pawn)
			continue

		if(!can_be_leader(pawn, candidate))
			continue

		var/score = get_leader_score(pawn, candidate)

		if(score > best_score)
			best_score = score
			best_leader = candidate

	if(!best_leader)
		return FALSE

	controller.set_blackboard_key(
		BB_BASIC_MOB_LEADER,
		best_leader
	)

	controller.set_blackboard_key(
		BB_BASIC_MOB_LEADER_LAST_SEEN,
		world.time
	)

	on_leader_found(controller, best_leader)

	return TRUE

/datum/ai_planning_subtree/find_leader/proc/leader_is_valid(
	datum/ai_controller/controller,
	mob/living/leader
)
	if(!leader || QDELETED(leader))
		return FALSE

	if(leader.stat == DEAD)
		return FALSE

	var/mob/living/pawn = controller.pawn

	if(pawn.z != leader.z)
		return FALSE

	if(get_dist(pawn, leader) > leader_max_distance)
		return FALSE

	return TRUE

/datum/ai_planning_subtree/find_leader/proc/clear_leader(
	datum/ai_controller/controller
)
	controller.clear_blackboard_key(BB_BASIC_MOB_LEADER)
	controller.clear_blackboard_key(BB_BASIC_MOB_LEADER_LAST_SEEN)
	controller.clear_blackboard_key(BB_BASIC_MOB_LEADER_HIDING_LOCATION)

	controller.set_blackboard_key(
		BB_BASIC_MOB_LEADER_SEARCH_COOLDOWN,
		world.time + leader_search_cooldown
	)


/datum/ai_planning_subtree/find_leader/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)
	var/mob/living/leader = controller.blackboard[BB_BASIC_MOB_LEADER]

	if(leader)
		if(leader_is_valid(controller, leader))
			controller.queue_behavior(
				pawn_leader_behaviour,
				BB_BASIC_MOB_LEADER
			)
			return

		clear_leader(controller)

	if(controller.blackboard[BB_BASIC_MOB_LEADER_SEARCH_COOLDOWN] > world.time)
		return

	if(find_new_leader(controller))
		controller.queue_behavior(
			pawn_leader_behaviour,
			BB_BASIC_MOB_LEADER
		)


/datum/ai_planning_subtree/pawn_leader

	var/leader_key = BB_BASIC_MOB_LEADER

	/// Distance at which the mob stops following the leader.
	var/follow_distance = 5


/datum/ai_planning_subtree/pawn_leader/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)
	var/mob/living/leader = controller.blackboard[leader_key]

	if(!leader)
		return

	var/mob/living/pawn = controller.pawn

	// Leader is too far away.
	// Following takes absolute priority over any advanced behavior.
	if(get_dist(pawn, leader) > follow_distance)
		controller.queue_behavior(
			/datum/ai_behavior/travel_towards_atom,
			leader
		)
		return

	// We are close enough to the leader.
	// Give descendants an opportunity to perform their own handling.
	handle_near_leader(
		controller,
		leader,
		seconds_per_tick
	)


/datum/ai_planning_subtree/pawn_leader/proc/handle_near_leader(
	datum/ai_controller/controller,
	mob/living/leader,
	seconds_per_tick
)
	return


/datum/ai_behavior/pawn_leader
