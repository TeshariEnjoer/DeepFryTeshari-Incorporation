/datum/idle_behavior/patrol

	var/patrol_points_key = BB_BASIC_MOB_PATROL_POINTS
	var/patrol_index_key = BB_BASIC_MOB_PATROL_INDEX

	var/arrival_distance = 2

	/// Maximum distance from the current patrol point.
	var/max_patrol_distance = 10

	var/loop_route = TRUE

	/// Chance to make a patrol step per second.
	var/walk_chance = 50


/datum/idle_behavior/patrol/perform_idle_behavior(
	seconds_per_tick,
	datum/ai_controller/controller
)
	. = ..()

	var/mob/living/pawn = controller.pawn

	if(LAZYLEN(pawn.do_afters))
		return FALSE

	if(!(pawn.mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(!isturf(pawn.loc))
		return FALSE

	if(pawn.pulledby)
		return FALSE

	var/list/patrol_points = controller.blackboard[patrol_points_key]

	if(!patrol_points || !length(patrol_points))
		return TRUE

	if(!SPT_PROB(walk_chance, seconds_per_tick))
		return TRUE

	var/index = controller.blackboard[patrol_index_key]

	if(!index)
		index = 1
		controller.set_blackboard_key(
			patrol_index_key,
			index
		)

	if(index > length(patrol_points))

		if(!loop_route)
			return TRUE

		index = 1

		controller.set_blackboard_key(
			patrol_index_key,
			index
		)

	var/turf/current_point = patrol_points[index]

	if(!current_point || QDELETED(current_point))
		patrol_points[index] = null
		return TRUE

	var/distance = get_dist(pawn, current_point)

	// Point reached.
	if(distance <= arrival_distance)

		index++

		if(index > length(patrol_points))

			if(!loop_route)
				return TRUE

			index = 1

		controller.set_blackboard_key(
			patrol_index_key,
			index
		)

		return TRUE

	var/list/possible_turfs = list()

	// If we are far away, prefer directions which move us towards the point.
	for(var/direction in GLOB.alldirs)

		var/turf/destination = get_step(pawn, direction)

		if(!destination?.can_cross_safely(pawn))
			continue

		var/destination_distance = get_dist(destination, current_point)

		if(distance > max_patrol_distance)
			if(destination_distance >= distance)
				continue
		else
			if(destination_distance > max_patrol_distance)
				continue

		possible_turfs += destination

	if(!length(possible_turfs))
		return TRUE

	var/turf/destination = pick(possible_turfs)

	pawn.Move(
		destination,
		get_dir(pawn, destination)
	)

	return TRUE


/datum/idle_behavior/return_to_spawn

	var/spawn_point_key = BB_BASIC_MOB_SPAWN_POINT

	/// Distance at which the NPC starts returning home.
	var/return_distance = 10

	/// Distance at which the NPC considers itself home.
	var/arrival_distance = 2


/datum/idle_behavior/return_to_spawn/perform_idle_behavior(
	seconds_per_tick,
	datum/ai_controller/controller
)
	. = ..()

	var/mob/living/pawn = controller.pawn

	if(LAZYLEN(pawn.do_afters))
		return FALSE

	if(!(pawn.mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(!isturf(pawn.loc))
		return FALSE

	if(pawn.pulledby)
		return FALSE

	var/turf/spawn_point = controller.blackboard[spawn_point_key]

	// First idle execution establishes the home position.
	if(!spawn_point)
		spawn_point = get_turf(pawn)

		controller.set_blackboard_key(
			spawn_point_key,
			spawn_point
		)

		return TRUE

	var/distance = get_dist(
		pawn,
		spawn_point
	)

	if(distance <= arrival_distance)
		return TRUE

	if(distance < return_distance)
		return TRUE

	var/list/possible_turfs = list()

	for(var/direction in GLOB.alldirs)

		var/turf/destination = get_step(
			pawn,
			direction
		)

		if(!destination?.can_cross_safely(pawn))
			continue

		if(get_dist(destination, spawn_point) >= distance)
			continue

		possible_turfs += destination

	if(!length(possible_turfs))
		return TRUE

	var/turf/destination = pick(possible_turfs)

	pawn.Move(
		destination,
		get_dir(pawn, destination)
	)

	return TRUE



/obj/effect/mapping_helpers/ai_patrol_point

	name = "AI Patrol Point"
	icon_state = "mobspawner"

	/// Identifier of the patrol route.
	var/route_id = "default"

	/// Position inside the route.
	var/point_index = 1


/obj/effect/mapping_helpers/ai_patrol_point/Initialize(mapload)

	. = ..()

	if(!mapload)
		return

	register_ai_patrol_point(
		route_id,
		point_index,
		get_turf(src)
	)


/obj/effect/mapping_helpers/ai_patrol_point/Destroy()

	unregister_ai_patrol_point(
		route_id,
		point_index,
		get_turf(src)
	)

	return ..()




/obj/effect/mapping_helpers/ai_patrol_anchor

	name = "AI Patrol Anchor"
	icon_state = "airlock_cyclelink_helper"

	var/route_id = "default"

	/// Radius in which mobs are assigned to this patrol.
	var/assignment_radius = 5


/obj/effect/mapping_helpers/ai_patrol_anchor/Initialize(mapload)

	. = ..()

	if(!mapload)
		return

	INVOKE_ASYNC(src, PROC_REF(assign_patrol))


/obj/effect/mapping_helpers/ai_patrol_anchor/proc/assign_patrol()

	var/list/route = get_ai_patrol_route(route_id)

	if(!length(route))
		stack_trace("AI patrol anchor '[src]' references empty route '[route_id]'")
		return

	for(var/mob/living/pawn in range(assignment_radius, src))

		if(!pawn.ai_controller)
			continue

		// Don't configure NPCs which explicitly opt out of map patrols.
		if(!pawn.ai_controller.blackboard[BB_BASIC_MOB_CAN_USE_PATROL_POINTS] || FALSE)
			continue

		var/list/patrol_points = list()

		for(var/index in route)
			patrol_points += route[index]

		if(!length(patrol_points))
			continue

		pawn.ai_controller.set_blackboard_key(
			BB_BASIC_MOB_PATROL_POINTS,
			patrol_points
		)

		pawn.ai_controller.set_blackboard_key(
			BB_BASIC_MOB_PATROL_INDEX,
			1
		)

		pawn.ai_controller.set_blackboard_key(
			BB_BASIC_MOB_PATROL_ANCHOR,
			src
		)
