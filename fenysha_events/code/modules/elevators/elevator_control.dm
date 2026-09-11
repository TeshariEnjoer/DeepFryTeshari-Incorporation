GLOBAL_LIST_INIT(all_elevators, list())

#define SOUND_ELEVATOR_MOVE 'fenysha_events/sounds/effects/elevator_sounds.ogg'
#define ELEVATOR_SHAFT_BLUR_SIZE 2
#define ELEVATOR_FALL_DAMAGE_PER_FLOOR 20


/atom
	var/can_elevate = TRUE


/proc/get_or_create_elevator(id)
	if(!id)
		return null

	var/datum/elevator/E = GLOB.all_elevators[id]
	if(E)
		return E

	E = new
	E.elevator_id = id
	GLOB.all_elevators[id] = E
	return E


/proc/purge_all_elevators()
	var/list/doomed = GLOB.all_elevators.Copy()

	for(var/id in doomed)
		var/datum/elevator/E = GLOB.all_elevators[id]
		if(!E)
			continue

		GLOB.all_elevators -= id
		qdel(E)


/datum/elevator
	var/elevator_id
	var/time_per_floor = 3 SECONDS
	var/current_floor = 1
	var/moving = FALSE
	var/platform_transition = FALSE

	var/music_enabled = TRUE
	var/music_channel = 2
	var/sfx_channel = 1

	var/list/elevator_turfs_by_floor = list()
	var/list/buttons_by_floor = list()
	var/list/doors_by_floor = list()
	var/list/floor_names = list()
	var/list/all_buttons = list()
	var/list/request_queue = list()
	var/list/shaft_blur_filters = list()

	var/static/list/blacklisted_atoms = list(
		/obj/effect/mapping_helpers/elevator_turf_marker,
		/obj/machinery/door/poddoor/story/elevator,
	)


/datum/elevator/New()
	. = ..()
	RegisterSignal(SStrain_controller, COMSIG_TRAINSTATION_LOADED, PROC_REF(on_trainstation_loaded))


/datum/elevator/Destroy(force)
	UnregisterSignal(SStrain_controller, COMSIG_TRAINSTATION_LOADED)
	remove_shaft_blur()

	for(var/obj/machinery/button/elevator_control/button as anything in all_buttons)
		if(button && button.control == src)
			button.control = null

	for(var/floor_key in doors_by_floor)
		var/list/doors = doors_by_floor[floor_key]
		if(!doors)
			continue

		for(var/obj/machinery/door/poddoor/story/elevator/door as anything in doors)
			if(door && door.control == src)
				door.control = null

	for(var/floor_key in elevator_turfs_by_floor)
		var/list/turfs = elevator_turfs_by_floor[floor_key]
		if(!turfs)
			continue

		for(var/turf/T as anything in turfs)
			if(T)
				UnregisterSignal(T, COMSIG_ATOM_ENTERED)

	elevator_turfs_by_floor = null
	buttons_by_floor = null
	doors_by_floor = null
	floor_names = null
	all_buttons = null
	request_queue = null
	shaft_blur_filters = null

	return ..()


/datum/elevator/proc/on_trainstation_loaded(datum/source, datum/train_station/station)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(reinitialize))


/datum/elevator/proc/reinitialize()
	moving = FALSE
	platform_transition = FALSE
	request_queue = list()

	for(var/obj/machinery/button/elevator_control/button as anything in all_buttons)
		if(QDELETED(button) || button.control != src)
			all_buttons -= button

	for(var/floor_key in buttons_by_floor.Copy())
		var/list/button_list = buttons_by_floor[floor_key]
		if(!button_list)
			buttons_by_floor -= floor_key
			continue

		for(var/obj/machinery/button/elevator_control/button as anything in button_list.Copy())
			if(QDELETED(button) || button.control != src)
				button_list -= button

		if(!length(button_list))
			buttons_by_floor -= floor_key

	for(var/floor_key in doors_by_floor.Copy())
		var/list/door_list = doors_by_floor[floor_key]
		if(!door_list)
			doors_by_floor -= floor_key
			continue

		for(var/obj/machinery/door/poddoor/story/elevator/door as anything in door_list.Copy())
			if(QDELETED(door) || door.control != src)
				door_list -= door

		if(!length(door_list))
			doors_by_floor -= floor_key

	for(var/floor_key in elevator_turfs_by_floor.Copy())
		var/list/turf_list = elevator_turfs_by_floor[floor_key]

		if(!turf_list)
			elevator_turfs_by_floor -= floor_key
			continue

		for(var/turf/T as anything in turf_list.Copy())
			if(!T || QDELETED(T))
				turf_list -= T

		if(!length(turf_list))
			elevator_turfs_by_floor -= floor_key

	if(!is_valid_floor(current_floor))
		current_floor = 1

	update_shaft_visuals()
	open_floor(current_floor)


/datum/elevator/proc/overlaps_turfs(list/block)
	if(!block || !length(block))
		return FALSE

	for(var/floor_key in elevator_turfs_by_floor)
		var/list/turfs = elevator_turfs_by_floor[floor_key]
		if(!turfs)
			continue

		for(var/turf/platform_turf as anything in turfs)
			if(block[platform_turf])
				return TRUE

	return FALSE


/proc/purge_elevators_in(list/turfs)
	if(!length(turfs))
		return

	var/list/block = list()

	for(var/turf/blocked_turf as anything in turfs)
		block[blocked_turf] = TRUE

	var/list/doomed = list()

	for(var/id in GLOB.all_elevators)
		var/datum/elevator/elevator = GLOB.all_elevators[id]

		if(elevator && elevator.overlaps_turfs(block))
			doomed += id

	for(var/id in doomed)
		var/datum/elevator/elevator = GLOB.all_elevators[id]

		if(!elevator)
			continue

		GLOB.all_elevators -= id
		qdel(elevator)


/datum/elevator/proc/num_to_floor(num)
	return "floor_[num]"


/datum/elevator/proc/floor_to_num(floor)
	return text2num(replacetext(floor, "floor_", ""))


/datum/elevator/proc/is_valid_floor(floor)
	return !!elevator_turfs_by_floor[num_to_floor(floor)]


/datum/elevator/proc/floor_amount()
	return length(buttons_by_floor)


/datum/elevator/proc/register_turf(turf/T, floor)
	if(!T)
		return

	var/floor_key = num_to_floor(floor)

	if(!elevator_turfs_by_floor[floor_key])
		elevator_turfs_by_floor[floor_key] = list()

	elevator_turfs_by_floor[floor_key] |= T

	UnregisterSignal(T, COMSIG_ATOM_ENTERED)
	RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(on_turf_entered))

	update_shaft_visuals()


/datum/elevator/proc/unregister_turf(turf/T, floor)
	if(!T)
		return

	UnregisterSignal(T, COMSIG_ATOM_ENTERED)

	var/floor_key = num_to_floor(floor)
	var/list/L = elevator_turfs_by_floor[floor_key]

	if(!L)
		return

	L -= T

	if(!length(L))
		elevator_turfs_by_floor -= floor_key

	remove_shaft_blur_from_turf(T)


/datum/elevator/proc/register_button(obj/machinery/button/elevator_control/B)
	if(!B || QDELETED(B))
		return

	B.control = src
	all_buttons |= B

	var/floor_key = num_to_floor(B.floor)

	if(!buttons_by_floor[floor_key])
		buttons_by_floor[floor_key] = list()

	buttons_by_floor[floor_key] |= B

	if(B.floor_name)
		floor_names[floor_key] = B.floor_name


/datum/elevator/proc/unregister_button(obj/machinery/button/elevator_control/B)
	if(!B)
		return

	all_buttons -= B

	if(B.control == src)
		B.control = null

	var/floor_key = num_to_floor(B.floor)
	var/list/L = buttons_by_floor[floor_key]

	if(L)
		L -= B

		if(!length(L))
			buttons_by_floor -= floor_key


/datum/elevator/proc/register_door(obj/machinery/door/poddoor/story/elevator/D)
	if(!D || QDELETED(D))
		return

	D.control = src

	var/floor_key = num_to_floor(D.floor)

	if(!doors_by_floor[floor_key])
		doors_by_floor[floor_key] = list()

	doors_by_floor[floor_key] |= D


/datum/elevator/proc/unregister_door(obj/machinery/door/poddoor/story/elevator/D)
	if(!D)
		return

	if(D.control == src)
		D.control = null

	var/floor_key = num_to_floor(D.floor)
	var/list/L = doors_by_floor[floor_key]

	if(L)
		L -= D

		if(!length(L))
			doors_by_floor -= floor_key


/datum/elevator/proc/is_elevator_turf(turf/T)
	if(!T)
		return FALSE

	for(var/floor_key in elevator_turfs_by_floor)
		var/list/turf_list = elevator_turfs_by_floor[floor_key]
		if(!turf_list)
			continue

		if(T in turf_list)
			return floor_to_num(floor_key)

	return FALSE


/datum/elevator/proc/call_to_floor(floor)
	if(!is_valid_floor(floor))
		return

	if(floor == current_floor)
		open_floor(current_floor)
		return

	var/floor_key = num_to_floor(floor)

	if(floor_key in request_queue)
		return

	request_queue += floor_key

	if(!moving)
		process_queue()


/datum/elevator/proc/request_floor(floor)
	if(!is_valid_floor(floor))
		return

	if((floor == current_floor) || (num_to_floor(floor) in request_queue))
		return

	request_queue += num_to_floor(floor)


/datum/elevator/proc/process_queue()
	while(request_queue.len > 0)
		if(QDELETED(src))
			return

		moving = TRUE

		var/target_floor = request_queue[1]
		request_queue.Cut(1, 2)

		var/target_floor_num = floor_to_num(target_floor)
		move_to_floor(target_floor_num)

		if(QDELETED(src))
			return

		moving = FALSE


/datum/elevator/proc/move_to_floor(target_floor)
	if(target_floor == current_floor)
		open_floor(current_floor)
		return

	if(!is_valid_floor(target_floor))
		return

	var/old_floor = current_floor
	var/is_descending = target_floor < old_floor

	close_floor(old_floor)

	if(is_descending)
		prepare_descending_shaft(target_floor)

	broadcast_elevator_sound(SOUND_ELEVATOR_MOVE, sfx_channel, volume = 70)

	var/floor_delta = abs(target_floor - old_floor)
	var/travel_time = floor_delta * time_per_floor

	sleep(travel_time)

	if(QDELETED(src))
		return

	if(!is_valid_floor(target_floor))
		return

	platform_transition = TRUE
	move_platform(old_floor, target_floor)

	if(QDELETED(src))
		return

	current_floor = target_floor
	platform_transition = FALSE

	update_shaft_visuals()
	open_floor(current_floor)


/datum/elevator/proc/prepare_descending_shaft(target_floor)
	// Every open virtual floor between the old platform and the
	// destination floor is allowed to drop its contents further down.
	for(var/floor = current_floor, floor > target_floor, floor--)
		drop_floor_contents(floor)


/datum/elevator/proc/drop_floor_contents(floor)
	var/list/source_turfs = get_floor_turfs(floor)

	if(!source_turfs)
		return

	var/next_floor = floor - 1

	if(next_floor < 1)
		return

	var/list/destination_turfs = get_floor_turfs(next_floor)

	if(!destination_turfs)
		return

	var/list/sorted_source = source_turfs.Copy()
	var/list/sorted_destination = destination_turfs.Copy()

	sortTim(sorted_source, GLOBAL_PROC_REF(cmp_elevator_turf_position))
	sortTim(sorted_destination, GLOBAL_PROC_REF(cmp_elevator_turf_position))

	for(var/i = 1, i <= sorted_source.len, i++)
		var/turf/source = sorted_source[i]
		var/turf/destination = sorted_destination[i]

		if(!source || !destination)
			continue

		var/list/movables = source.contents.Copy()

		for(var/atom/movable/M in movables)
			if(!should_fall_atom(M))
				continue

			drop_atom_to_floor(M, source, destination, 1)


/datum/elevator/proc/drop_atom_to_floor(atom/movable/M, turf/source, turf/destination, floors)
	if(QDELETED(M) || M.loc != source || !destination)
		return

	var/pixel_x = M.pixel_x
	var/pixel_y = M.pixel_y
	var/pixel_z = M.pixel_z

	animate_virtual_fall(M, source, destination)

	if(QDELETED(M) || M.loc != source)
		return

	M.forceMove(destination)

	M.pixel_x = pixel_x
	M.pixel_y = pixel_y
	M.pixel_z = pixel_z

	apply_fall_damage(M, floors)


/datum/elevator/proc/animate_virtual_fall(atom/movable/M, turf/source, turf/destination)
	if(QDELETED(M) || !source || !destination)
		return

	var/delta_x = (destination.x - source.x) * world.icon_size
	var/delta_y = (destination.y - source.y) * world.icon_size

	animate(M, pixel_x = M.pixel_x + delta_x, pixel_y = M.pixel_y + delta_y, time = 0.15 SECONDS, easing = QUAD_EASING)
	sleep(0.15 SECONDS)

	if(QDELETED(M))
		return

	animate(M, pixel_x = M.pixel_x - delta_x, pixel_y = M.pixel_y - delta_y, time = 0)


/datum/elevator/proc/apply_fall_damage(atom/movable/M, floors)
	if(QDELETED(M) || floors <= 0)
		return

	var/damage = ELEVATOR_FALL_DAMAGE_PER_FLOOR * floors

	if(isliving(M))
		var/mob/living/L = M
		L.adjust_brute_loss(damage)

		if(L.stat != DEAD)
			to_chat(L, span_danger("You crash down the elevator shaft!"))

		return

	if(isitem(M))
		var/obj/item/I = M
		I.take_damage(damage)


/datum/elevator/proc/should_fall_atom(atom/movable/M)
	if(!M || QDELETED(M))
		return FALSE

	if(!M.can_elevate)
		return FALSE

	for(var/T in blacklisted_atoms)
		if(istype(M, T))
			return FALSE

	if(ismob(M) && HAS_TRAIT(M, TRAIT_MOVE_FLYING))
		return FALSE

	return TRUE


/datum/elevator/proc/crush_destination_floor(floor)
	var/list/turfs = get_floor_turfs(floor)

	if(!turfs)
		return

	for(var/turf/T as anything in turfs)
		if(!T || QDELETED(T))
			continue

		var/list/movables = T.contents.Copy()

		for(var/atom/movable/M in movables)
			if(!should_crush_atom(M))
				continue

			if(ismob(M))
				var/mob/living/L = M

				if(isliving(L))
					L.gib()
				else
					qdel(L)

				continue

			qdel(M)


/datum/elevator/proc/should_crush_atom(atom/movable/M)
	if(!M || QDELETED(M))
		return FALSE

	if(!M.can_elevate)
		return FALSE

	for(var/T in blacklisted_atoms)
		if(istype(M, T))
			return FALSE

	return TRUE


/datum/elevator/proc/on_turf_entered(turf/source, atom/movable/movable)
	SIGNAL_HANDLER

	if(platform_transition || moving)
		return

	if(QDELETED(movable) || movable.loc != source)
		return

	if(HAS_TRAIT(movable, TRAIT_MOVE_FLYING))
		return

	var/floor = is_elevator_turf(source)

	if(!floor || floor <= current_floor)
		return

	INVOKE_ASYNC(src, PROC_REF(drop_from_floor), movable, floor)


/datum/elevator/proc/drop_from_floor(atom/movable/M, starting_floor)
	if(QDELETED(M))
		return

	var/floor = starting_floor

	while(floor > current_floor)
		if(QDELETED(M))
			return

		var/list/source_turfs = get_floor_turfs(floor)
		var/list/destination_turfs = get_floor_turfs(floor - 1)

		if(!source_turfs || !destination_turfs)
			return

		var/turf/source = M.loc

		if(!(source in source_turfs))
			return

		var/turf/destination = get_corresponding_turf(source_turfs, destination_turfs, source)

		if(!destination)
			return

		drop_atom_to_floor(M, source, destination, 1)

		if(QDELETED(M))
			return

		floor--


/datum/elevator/proc/get_corresponding_turf(list/source_turfs, list/destination_turfs, turf/source)
	if(!source || !source_turfs || !destination_turfs)
		return null

	var/list/sorted_source = source_turfs.Copy()
	var/list/sorted_destination = destination_turfs.Copy()

	sortTim(sorted_source, GLOBAL_PROC_REF(cmp_elevator_turf_position))
	sortTim(sorted_destination, GLOBAL_PROC_REF(cmp_elevator_turf_position))

	var/index = sorted_source.Find(source)

	if(!index || index > sorted_destination.len)
		return null

	return sorted_destination[index]


/proc/cmp_elevator_turf_position(turf/a, turf/b)
	if(a.y != b.y)
		return a.y - b.y

	return a.x - b.x


/datum/elevator/proc/move_platform(old_floor, new_floor)
	var/list/old_turfs = get_floor_turfs(old_floor)
	var/list/new_turfs = get_floor_turfs(new_floor)

	if(!old_turfs || !new_turfs)
		return

	if(length(old_turfs) != length(new_turfs))
		CRASH("Elevator [elevator_id]: floor [old_floor] and floor [new_floor] have different platform sizes!")

	var/list/sorted_old_turfs = old_turfs.Copy()
	var/list/sorted_new_turfs = new_turfs.Copy()

	sortTim(sorted_old_turfs, GLOBAL_PROC_REF(cmp_elevator_turf_position))
	sortTim(sorted_new_turfs, GLOBAL_PROC_REF(cmp_elevator_turf_position))

	for(var/i = 1, i <= sorted_old_turfs.len, i++)
		var/turf/source = sorted_old_turfs[i]
		var/turf/destination = sorted_new_turfs[i]

		if(!source || !destination)
			continue

		var/list/movables = source.contents.Copy()

		for(var/atom/movable/M in movables)
			if(!should_move_atom(M, source))
				continue

			var/pixel_x = M.pixel_x
			var/pixel_y = M.pixel_y
			var/pixel_z = M.pixel_z

			M.forceMove(destination)

			M.pixel_x = pixel_x
			M.pixel_y = pixel_y
			M.pixel_z = pixel_z


/datum/elevator/proc/should_move_atom(atom/A, turf/source_turf)
	if(!A || QDELETED(A) || !A.can_elevate)
		return FALSE

	for(var/T in blacklisted_atoms)
		if(istype(A, T))
			return FALSE

	return TRUE


/datum/elevator/proc/update_shaft_visuals()
	for(var/floor_key in elevator_turfs_by_floor)
		var/floor = floor_to_num(floor_key)
		var/list/turfs = elevator_turfs_by_floor[floor_key]

		if(!turfs)
			continue

		var/is_current_floor = floor == current_floor

		for(var/turf/T as anything in turfs)
			if(!T || QDELETED(T))
				continue

			if(is_current_floor)
				remove_shaft_blur_from_turf(T)
			else
				apply_shaft_blur_to_turf(T)


/datum/elevator/proc/apply_shaft_blur_to_turf(turf/T)
	if(!T || shaft_blur_filters[T])
		return

	var/blur_filter = filter(type = "blur", size = ELEVATOR_SHAFT_BLUR_SIZE)

	T.filters += blur_filter
	shaft_blur_filters[T] = blur_filter


/datum/elevator/proc/remove_shaft_blur_from_turf(turf/T)
	if(!T)
		return

	var/blur_filter = shaft_blur_filters[T]

	if(!blur_filter)
		return

	T.filters -= blur_filter
	shaft_blur_filters -= T


/datum/elevator/proc/remove_shaft_blur()
	for(var/turf/T as anything in shaft_blur_filters)
		if(!T || QDELETED(T))
			continue

		var/blur_filter = shaft_blur_filters[T]

		if(blur_filter)
			T.filters -= blur_filter

	shaft_blur_filters.Cut()


/datum/elevator/proc/close_floor(floor)
	var/list/L = doors_by_floor[num_to_floor(floor)]

	if(!L)
		return

	for(var/obj/machinery/door/poddoor/story/elevator/D in L)
		if(D && !QDELETED(D))
			D.close()


/datum/elevator/proc/open_floor(floor)
	var/list/L = doors_by_floor[num_to_floor(floor)]

	if(!L)
		return

	for(var/obj/machinery/door/poddoor/story/elevator/D in L)
		if(D && !QDELETED(D))
			D.open()


/datum/elevator/proc/has_floor(floor)
	return is_valid_floor(floor)


/datum/elevator/proc/get_floor_turfs(floor)
	return elevator_turfs_by_floor[num_to_floor(floor)]


/datum/elevator/proc/get_floor_doors(floor)
	return doors_by_floor[num_to_floor(floor)]


/datum/elevator/proc/broadcast_elevator_sound(sound_file, channel = 1, volume = 100, loop = 0)
	if(!sound_file)
		return

	var/list/elevator_mobs = get_elevator_occupants()

	for(var/mob/m in elevator_mobs)
		if(m.client)
			SEND_SOUND(m, sound(sound_file, repeat = loop, wait = 0, volume = volume, channel = channel))


/datum/elevator/proc/announce_floor(floor)
	var/list/elevator_mobs = get_elevator_occupants()
	var/floor_name = get_floor_name(floor)

	for(var/mob/m in elevator_mobs)
		to_chat(m, span_notice("<b>DING!</b> Arriving at [floor_name]..."))


/datum/elevator/proc/get_floor_name(floor)
	var/floor_key = num_to_floor(floor)

	if(floor_names[floor_key])
		return floor_names[floor_key]

	return "Floor [floor]"


/datum/elevator/proc/get_elevator_occupants()
	var/list/occupants = list()
	var/list/turfs = list()

	for(var/floor_key in elevator_turfs_by_floor)
		var/list/turf_list = elevator_turfs_by_floor[floor_key]

		if(turf_list)
			turfs += turf_list

	for(var/turf/T in turfs)
		if(!T || QDELETED(T))
			continue

		for(var/mob/m in T.contents)
			occupants += m

	return occupants


/datum/elevator/proc/start_music()
	if(!music_enabled)
		return


/datum/elevator/proc/stop_music()
	broadcast_elevator_sound(null, music_channel)


/obj/machinery/button/elevator_control
	name = "elevator call button"
	desc = "Press this button to call the elevator"

	base_icon_state = "tram"
	icon_state = "tram"

	var/floor = 1
	var/elevator_id
	var/floor_name
	var/datum/elevator/control

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1


/obj/machinery/button/elevator_control/Initialize(mapload)
	. = ..()

/obj/machinery/button/elevator_control/post_machine_initialize()
	. = ..()
	control = get_or_create_elevator(elevator_id)

	if(control)
		control.register_button(src)

	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Use elevator")
	qdel(GetComponent(/datum/component/atom_mounted))


/obj/machinery/button/elevator_control/Destroy()
	if(control)
		control.unregister_button(src)

	control = null
	return ..()


/obj/machinery/button/elevator_control/interact(mob/user)
	if(!control)
		return FALSE

	var/is_inside_elevator = control.is_elevator_turf(get_turf(src)) ? TRUE : FALSE
	var/should_advanced_view = control.floor_amount() > 2

	if(!is_inside_elevator)
		control.call_to_floor(floor)

		user.visible_message(
			span_notice("[user] presses the elevator button."),
			span_notice("You press the elevator call button for [control.get_floor_name(floor)].")
		)

		return TRUE

	if(!should_advanced_view)
		var/current_elevator_floor = control.is_elevator_turf(get_turf(src))

		if(current_elevator_floor == control.current_floor)
			if(control.current_floor == 1)
				control.move_to_floor(control.floor_amount())
			else
				control.move_to_floor(1)
		else
			control.move_to_floor(control.floor_amount())

		user.visible_message(
			span_notice("[user] presses the elevator button."),
			span_notice("You press the elevator button for another floor.")
		)

		return TRUE

	var/list/available_floors = list()

	for(var/floor_key in control.buttons_by_floor)
		var/floor_number = control.floor_to_num(floor_key)
		available_floors[control.get_floor_name(floor_number)] = floor_number

	var/picked = tgui_input_list(user, "What floor?", "Elevator", available_floors)

	if(!picked)
		return TRUE

	control.move_to_floor(available_floors[picked])
	return TRUE


/obj/machinery/button/elevator_control/screwdriver_act(mob/living/user, obj/item/tool)
	return


/obj/machinery/button/elevator_control/wrench_act(mob/living/user, obj/item/tool)
	return


/obj/machinery/button/elevator_control/emag_act(mob/user, obj/item/card/emag/emag_card)
	return

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/elevator_control, 32)

/obj/machinery/door/poddoor/story/elevator
	name = "elevator door"
	desc = "Automated elevator door"

	var/floor = 1
	var/elevator_id
	var/datum/elevator/control


/obj/machinery/door/poddoor/story/elevator/Initialize(mapload)
	. = ..()


/obj/machinery/door/poddoor/story/elevator/post_machine_initialize()
	. = ..()
	control = get_or_create_elevator(elevator_id)

	if(control)
		control.register_door(src)


/obj/machinery/door/poddoor/story/elevator/Destroy()
	if(control)
		control.unregister_door(src)

	control = null
	return ..()


/obj/machinery/door/poddoor/story/elevator/always_invisible
	invisibility = INVISIBILITY_ABSTRACT


/obj/machinery/door/poddoor/story/elevator/always_invisible/open(forced)
	. = ..()
	opacity = FALSE


/obj/machinery/door/poddoor/story/elevator/always_invisible/close(forced)
	. = ..()
	opacity = FALSE


/obj/effect/mapping_helpers/elevator_turf_marker
	name = "Elevator Turf Marker"
	desc = "Marks a turf as part of an elevator shaft"

	late = TRUE
	invisibility = INVISIBILITY_ABSTRACT

	var/floor = 1
	var/elevator_id


/obj/effect/mapping_helpers/elevator_turf_marker/LateInitialize()
	. = ..()

	var/datum/elevator/E = get_or_create_elevator(elevator_id)

	if(E)
		E.register_turf(get_turf(src), floor)

	qdel(src)


/obj/structure/elevator_platfrom
	name = "Elevator platform"
	mouse_opacity = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1
	anchored = TRUE
	icon = 'fenysha_events/icons/turf/floors/floors.dmi'
	icon_state = "dark_large"
	layer = ABOVE_OPEN_TURF_LAYER - 12
	plane = -6
