GLOBAL_LIST_EMPTY(ai_patrol_routes)


/proc/get_ai_patrol_route(route_id)

	if(isnull(route_id))
		return

	return GLOB.ai_patrol_routes[route_id]


/proc/register_ai_patrol_point(
	route_id,
	point_index,
	turf/location
)

	if(isnull(route_id) || !location)
		return

	var/list/route = GLOB.ai_patrol_routes[route_id]

	if(!route)
		route = list()
		GLOB.ai_patrol_routes[route_id] = route

	if(route[point_index] && route[point_index] != location)
		stack_trace("Duplicate AI patrol point: route '[route_id]', index [point_index]")

	route[point_index] = location

/proc/unregister_ai_patrol_point(route_id, point_index, turf/location)

	var/list/route = GLOB.ai_patrol_routes[route_id]

	if(!route)
		return

	if(route[point_index] == location)
		route -= point_index

	if(!length(route))
		GLOB.ai_patrol_routes -= route_id
