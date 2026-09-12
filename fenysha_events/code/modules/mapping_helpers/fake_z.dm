/turf/open/fake_z
	name = "unstable space"
	desc = "The space below seems strangely distorted."

	icon_state = MAP_SWITCH("pure_white", "invisible")

	baseturfs = /turf/open/fake_z

	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	pathing_pass_method = TURF_PATHING_PASS_PROC

	plane = TRANSPARENT_FLOOR_PLANE
	layer = SPACE_LAYER

	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags = NO_RUST

	/// X offset of the actual turf below this fake level.
	var/fake_x_offset = 0

	/// Y offset of the actual turf below this fake level.
	var/fake_y_offset = 0

	/// Whether this turf should visually distort its lower level.
	var/fake_z_distortion = TRUE

	/// Prevents recursive falling while Move() is propagating through fake levels.
	var/falling_movable

/turf/open/fake_z/Initialize(mapload)
	. = ..()

	ADD_TURF_TRANSPARENCY(src, INNATE_TRAIT)

	if(fake_z_distortion)
		filters += filter(type = "blur", size = 0.6)

	update_fake_z_visual()

	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_created))

	return INITIALIZE_HINT_LATELOAD


/turf/open/fake_z/LateInitialize()
	. = ..()

	update_fake_z_visual()


/turf/open/fake_z/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)

	var/turf/below = get_fake_z_below()

	if(below)
		vis_contents -= below

	filters = null

	return ..()


/turf/open/fake_z/proc/get_fake_z_below()
	var/target_z = z - 1

	if(target_z < 1 || target_z > world.maxz)
		return null

	var/target_x = x + fake_x_offset
	var/target_y = y + fake_y_offset

	if(target_x < 1 || target_x > world.maxx)
		return null

	if(target_y < 1 || target_y > world.maxy)
		return null

	return locate(target_x, target_y, target_z)


/turf/open/fake_z/proc/update_fake_z_visual()
	var/turf/below = get_fake_z_below()

	if(!below)
		return

	vis_contents += below


/turf/open/fake_z/proc/on_atom_created(datum/source, datum/created_atom)
	SIGNAL_HANDLER

	if(!ismovable(created_atom))
		return

	var/atom/movable/movable = created_atom

	if(movable.loc != src)
		return

	fall_to_fake_z(movable)


/turf/open/fake_z/Enter(atom/movable/movable, atom/oldloc)
	. = ..()

	if(!.)
		return FALSE

	if(movable.set_currently_z_moving(CURRENTLY_Z_FALLING_FROM_MOVE))
		return TRUE

	return FALSE


/turf/open/fake_z/Entered(atom/movable/movable)
	. = ..()

	if(!movable.set_currently_z_moving(CURRENTLY_Z_FALLING))
		return

	fall_to_fake_z(movable)


/turf/open/fake_z/proc/fall_to_fake_z(atom/movable/movable)
	if(QDELETED(movable))
		return

	if(movable.loc != src)
		return

	if(falling_movable == movable)
		return

	if(HAS_TRAIT(movable, TRAIT_MOVE_FLYING))
		return

	var/turf/destination = get_fake_z_below()

	if(!destination)
		return

	if(!movable.can_z_move(DOWN, src, null, ZMOVE_FALL_FLAGS))
		return

	falling_movable = movable

	/// Move() is intentional.
	/// This keeps Enter()/Entered() and all normal movement handling active.
	movable.Move(destination)

	falling_movable = null


/turf/open/fake_z/zAirIn()
	return TRUE


/turf/open/fake_z/zAirOut()
	return TRUE


/turf/open/fake_z/zPassIn(direction)
	if(direction != DOWN)
		return FALSE

	for(var/obj/contained_object in contents)
		if(contained_object.obj_flags & BLOCK_Z_IN_DOWN)
			return FALSE

	return TRUE


/turf/open/fake_z/zPassOut(direction)
	if(direction != UP)
		return FALSE

	for(var/obj/contained_object in contents)
		if(contained_object.obj_flags & BLOCK_Z_OUT_UP)
			return FALSE

	return TRUE


/turf/open/fake_z/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/movable/our_movable = pass_info.requester_ref?.resolve()

	if(our_movable && !our_movable.can_z_move(DOWN, src, null, ZMOVE_FALL_FLAGS))
		return TRUE

	return FALSE


/turf/open/fake_z/can_cross_safely(atom/movable/crossing)
	return HAS_TRAIT(crossing, TRAIT_MOVE_FLYING) || !crossing.can_z_move(DOWN, src, z_move_flags = ZMOVE_FALL_FLAGS)


/turf/open/fake_z/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE

	return FALSE


/obj/structure/ladder/unbreakable/fake_z
	name = "sturdy ladder"
	desc = "An extremely sturdy metal ladder."
	resistance_flags = INDESTRUCTIBLE


	/// X offset used when searching for the simulated floor below/above.
	var/x_offset = 0

	/// Y offset used when searching for the simulated floor below/above.
	var/y_offset = 0


/obj/structure/ladder/unbreakable/fake_z/LateInitialize()
	if(!id || (up && down))
		update_appearance()
		return

	var/turf/source_turf = get_turf(src)

	if(!source_turf)
		update_appearance()
		return

	/// Look for the ladder representing the virtual floor below.
	if(!down)
		var/turf/down_turf = locate(
			source_turf.x + x_offset,
			source_turf.y + y_offset,
			source_turf.z - 1
		)

		if(down_turf)
			for(var/obj/structure/ladder/unbreakable/fake_z/target in down_turf)
				if(target == src)
					continue

				if(target.id != id)
					continue

				if(target.height != height - 1)
					continue

				down = target
				target.up = src
				target.update_appearance(UPDATE_ICON_STATE)
				break

	/// Look for the ladder representing the virtual floor above.
	if(!up)
		var/turf/up_turf = locate(
			source_turf.x + x_offset,
			source_turf.y + y_offset,
			source_turf.z + 1
		)

		if(up_turf)
			for(var/obj/structure/ladder/unbreakable/fake_z/target in up_turf)
				if(target == src)
					continue

				if(target.id != id)
					continue

				if(target.height != height + 1)
					continue

				up = target
				target.down = src
				target.update_appearance(UPDATE_ICON_STATE)
				break

	update_appearance()


/obj/structure/ladder/unbreakable/fake_z/Destroy(force)
	if(down)
		down.up = null
		down.update_appearance(UPDATE_ICON_STATE)

	if(up)
		up.down = null
		up.update_appearance(UPDATE_ICON_STATE)

	down = null
	up = null

	return ..()


/obj/structure/stairs/fake_z
	name = "stairs"

	/// Identifier shared by stairs belonging to the same simulated structure.
	var/id

	/// Virtual floor number.
	var/height = 0

	/// X offset used when searching for the corresponding stair on another level.
	var/x_offset = 0

	/// Y offset used when searching for the corresponding stair on another level.
	var/y_offset = 0

	/// Cached stair on the virtual floor above.
	var/obj/structure/stairs/fake_z/up_fake

	/// Cached stair on the virtual floor below.
	var/obj/structure/stairs/fake_z/down_fake


/obj/structure/stairs/fake_z/Initialize(mapload)
	. = ..()

	return INITIALIZE_HINT_LATELOAD


/obj/structure/stairs/fake_z/LateInitialize()
	. = ..()

	find_fake_connections()
	update_appearance()
	update_minimap_blip()


/obj/structure/stairs/fake_z/Destroy()
	if(up_fake)
		up_fake.down_fake = null
		up_fake = null

	if(down_fake)
		down_fake.up_fake = null
		down_fake = null

	return ..()


/obj/structure/stairs/fake_z/proc/get_fake_target_turf(target_height)
	var/turf/source = get_turf(src)

	if(!source)
		return null

	var/height_difference = target_height - height

	if(!height_difference)
		return source

	/*
		One level corresponds to one real Z-level.

		The X/Y offset is applied relative to our own turf.
		This means a stair can connect to a completely different
		coordinate on the next physical Z-level.
	*/

	var/target_x = source.x + x_offset
	var/target_y = source.y + y_offset
	var/target_z = source.z + height_difference

	if(target_x < 1 || target_x > world.maxx)
		return null

	if(target_y < 1 || target_y > world.maxy)
		return null

	if(target_z < 1 || target_z > world.maxz)
		return null

	return locate(target_x, target_y, target_z)


/obj/structure/stairs/fake_z/proc/find_fake_connections()
	var/turf/target_turf

	if(!up_fake)
		target_turf = get_fake_target_turf(height + 1)

		if(target_turf)
			for(var/obj/structure/stairs/fake_z/stair in target_turf)
				if(stair == src)
					continue

				if(stair.id != id)
					continue

				if(stair.height != height + 1)
					continue

				up_fake = stair
				stair.down_fake = src
				stair.update_appearance()
				break

	if(!down_fake)
		target_turf = get_fake_target_turf(height - 1)

		if(target_turf)
			for(var/obj/structure/stairs/fake_z/stair in target_turf)
				if(stair == src)
					continue

				if(stair.id != id)
					continue

				if(stair.height != height - 1)
					continue

				down_fake = stair
				stair.up_fake = src
				stair.update_appearance()
				break


/obj/structure/stairs/fake_z/proc/get_fake_step(direction)
	if(direction == UP)
		return up_fake

	if(direction == DOWN)
		return down_fake

	return null


/obj/structure/stairs/fake_z/isTerminator()
	var/turf/T = get_turf(src)

	if(!T)
		return FALSE

	/*
		We still allow normal visual chaining of stairs.

		A stair is considered a terminator when there is no
		next stair in its horizontal direction.
	*/

	var/turf/next = get_step(T, dir)

	if(!next)
		return TRUE

	for(var/obj/structure/stairs/S in next)
		if(S.dir == dir)
			return FALSE

	return TRUE


/obj/structure/stairs/fake_z/stair_ascend(atom/movable/climber)
	var/obj/structure/stairs/fake_z/next_stair = up_fake

	if(!next_stair)
		return

	var/turf/checking = get_turf(next_stair)

	if(!checking)
		return

	/*
		Check the actual physical Z transition.

		This is necessary because BYOND still sees two real Z-levels,
		even though our gameplay connection is controlled manually.
	*/

	if(!climber.can_z_move(UP, get_turf(src), checking, z_move_flags = ZMOVE_ALLOW_BUCKLED))
		return

	var/turf/target = get_turf(next_stair)

	if(!target)
		return

	/*
		Do not allow the mob to immediately fall through
		the simulated level after arriving.
	*/

	if(!climber.can_z_move(DOWN, target, z_move_flags = ZMOVE_FALL_FLAGS))
		return

	climber.zMove(
		target = target,
		z_move_flags = ZMOVE_STAIRS_FLAGS
	)

	climber.pulling?.move_from_pull(climber, target, climber.glide_size)

	for(var/mob/living/buckled in climber.buckled_mobs)
		buckled.pulling?.move_from_pull(buckled, target, buckled.glide_size)
