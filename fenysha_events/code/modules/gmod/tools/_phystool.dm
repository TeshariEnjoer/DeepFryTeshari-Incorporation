#define TRAIT_PHYSGUN_PAUSE "physgun_pause"
#define PHYSGUN_EFFECTS "physgun_effects"

/obj/item/physgun
	name = "Physgun"
	desc = "A tool for manipulating the physics of objects."
	icon = 'fenysha_events/icons/items/tools/gmod_tools.dmi'
	icon_state = "gravitygun"
	inhand_icon_state = "gravitygun"
	lefthand_file = 'fenysha_events/icons/items/inhand/tools/gmod_tools_left.dmi'
	righthand_file = 'fenysha_events/icons/items/inhand/tools/gmod_tools_right.dmi'
	slot_flags = NONE
	demolition_mod = 0.5
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 0
	throw_speed = 1
	throw_range = 1
	drop_sound = 'sound/items/handling/tools/screwdriver_drop.ogg'
	pickup_sound = 'fenysha_events/sounds/tools/phystools/physgun_pickup.ogg'

	var/personal_color = COLOR_TAN_ORANGE
	var/effects_color = null
	var/force_grab = FALSE
	var/advanced = FALSE
	var/use_cooldown = 1.5 SECONDS
	var/maximum_distance = 8
	var/atom/movable/handled_atom
	var/datum/component/physgun_grab/current_grab_component
	var/mob/living/physgun_user
	var/datum/beam/physgun_beam
	var/atom/movable/screen/fullscreen/cursor_catcher/physgun_catcher
	COOLDOWN_DECLARE(grab_cooldown)
	var/datum/looping_sound/gravgen/kinesis/phys_gun/loop_sound

/obj/item/physgun/Initialize(mapload)
	effects_color = personal_color
	. = ..()
	loop_sound = new(src)

/obj/item/physgun/Destroy(force)
	if(handled_atom)
		release_atom()
	if(loop_sound)
		qdel(loop_sound)
	return ..()

/obj/item/physgun/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		return
	var/mutable_appearance/overlay = mutable_appearance(icon_file, "gravitygun_overlay", src)
	overlay.color = personal_color ? personal_color : initial(personal_color)
	. += overlay

/obj/item/physgun/update_overlays()
	. = ..()
	var/mutable_appearance/color_appearance = mutable_appearance(icon, "gravitygun_overlay")
	color_appearance.color = personal_color ? personal_color : initial(personal_color)
	. += color_appearance

/obj/item/physgun/pickup(mob/user)
	. = ..()
	if(user)
		RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_clicked), TRUE)

/obj/item/physgun/dropped(mob/user, silent)
	if(user)
		UnregisterSignal(user, COMSIG_MOB_CLICKON)
	. = ..()
	if(handled_atom)
		release_atom()

/obj/item/physgun/ranged_interact_with_atom(atom/movable/target, mob/living/user, list/modifiers)
	. = ..()
	if(!ismovable(target))
		return
	if(handled_atom)
		return
	if(!can_catch(target, user))
		playsound(user, 'fenysha_events/sounds/tools/phystools/physgun_cant_grab.ogg', 100, TRUE)
		return
	if(!COOLDOWN_FINISHED(src, grab_cooldown))
		user.balloon_alert(user, "recharging!")
		return
	if(!range_check(target, user))
		user.balloon_alert(user, "too far away!")
		return
	if(catch_atom(target, user))
		COOLDOWN_START(src, grab_cooldown, use_cooldown)

/obj/item/physgun/click_alt(mob/user)
	if(handled_atom)
		balloon_alert(user, "Impossible in the current state!")
		return CLICK_ACTION_SUCCESS
	var/chosen_color = tgui_color_picker(user, "Choose a new effects color", "Physgun Color")
	if(!chosen_color)
		balloon_alert(user, "Invalid color!")
		return CLICK_ACTION_SUCCESS
	effects_color = chosen_color
	personal_color = chosen_color
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/physgun/examine(mob/user)
	. = ..()
	. += span_notice("Quick guide:")
	. += span_notice("ALT + Left Click on the device — pick a color.")
	. += span_notice("Left Click on an object — start dragging.")
	. += span_green("Right Click while dragging — freeze the object.")
	. += span_red("Left Click while dragging — release the object.")
	. += span_notice("CTRL + Left Click while dragging — throw the object.")
	. += span_notice("ALT + Left Click while dragging — rotate the object.")

/obj/item/physgun/process(seconds_per_tick)
	if(!physgun_user || !current_grab_component || QDELETED(handled_atom))
		release_atom()
		return

	if(!range_check(handled_atom, physgun_user))
		release_atom()
		return

	if(!physgun_catcher)
		release_atom()
		return

	if(physgun_catcher.mouse_params)
		physgun_catcher.calculate_params()

	if(!physgun_catcher.given_turf)
		return

	physgun_user.setDir(get_dir(physgun_user, handled_atom))

	var/pixel_target_x = current_grab_component.stored_pixel_x + physgun_catcher.given_x - world.icon_size / 2
	var/pixel_target_y = current_grab_component.stored_pixel_y + physgun_catcher.given_y - world.icon_size / 2

	if(handled_atom.loc == physgun_catcher.given_turf)
		if(handled_atom.pixel_x == pixel_target_x && handled_atom.pixel_y == pixel_target_y)
			return
		animate(handled_atom, time = 0.2 SECONDS, pixel_x = pixel_target_x, pixel_y = pixel_target_y)
		if(physgun_beam)
			physgun_beam.redrawing()
		return

	var/turf/turf_to_move = get_step_towards(handled_atom, physgun_catcher.given_turf)
	if(!turf_to_move)
		return

	var/direction = get_dir(handled_atom, turf_to_move)

	if(!direction)
		return

	if(!handled_atom.Move(turf_to_move, direction, 4))
		return

	var/pixel_x_change = 0
	var/pixel_y_change = 0

	if(direction & NORTH)
		pixel_y_change = world.icon_size / 2
	else if(direction & SOUTH)
		pixel_y_change = -world.icon_size / 2

	if(direction & EAST)
		pixel_x_change = world.icon_size / 2
	else if(direction & WEST)
		pixel_x_change = -world.icon_size / 2

	animate(handled_atom, time = 0.1 SECONDS, pixel_x = current_grab_component.stored_pixel_x + pixel_x_change, pixel_y = current_grab_component.stored_pixel_y + pixel_y_change)

	if(physgun_beam)
		physgun_beam.redrawing()

/obj/item/physgun/proc/can_catch(atom/target, mob/user)
	if(target == user)
		return FALSE
	if(!ismovable(target))
		return FALSE

	var/atom/movable/movable_target = target

	if(iseffect(movable_target))
		return FALSE

	if(movable_target.anchored && !HAS_TRAIT(movable_target, TRAIT_PHYSGUN_PAUSE) && !advanced)
		return FALSE

	if(ismob(movable_target))
		if(!isliving(movable_target))
			return FALSE
		var/mob/living/living_target = movable_target
		if(living_target.buckled)
			return FALSE
		if(living_target.client && !advanced)
			return FALSE

	return TRUE

/obj/item/physgun/proc/range_check(atom/target, mob/user)
	if(!isturf(user.loc))
		return FALSE
	return can_see(user, target, maximum_distance)

/obj/item/physgun/proc/on_clicked(atom/source, atom/clicked_on, modifiers)
	SIGNAL_HANDLER

	if(!handled_atom || !physgun_user)
		return

	. = COMSIG_MOB_CANCEL_CLICKON

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!advanced)
			physgun_user.balloon_alert(physgun_user, "not enough energy!")
			return
		pause_atom(handled_atom)
		return

	if(LAZYACCESS(modifiers, CTRL_CLICK))
		repulse(handled_atom, physgun_user)
		return

	if(LAZYACCESS(modifiers, ALT_CLICK))
		rotate_object(handled_atom)
		return

	release_atom()

/obj/item/physgun/proc/on_living_resist(mob/living/source)
	SIGNAL_HANDLER

	if(source != handled_atom)
		return

	if(force_grab)
		source.balloon_alert(source, "can't escape!")
		return

	release_atom()

/obj/item/physgun/proc/catch_atom(atom/movable/target, mob/user)
	if(!can_catch(target, user))
		return FALSE

	if(SEND_SIGNAL(target, COMSIG_MOVABLE_PHYSGUN_GRABBED, src) & COMPONENT_BLOCK_PHYSGUN_GRAB)
		playsound(user, 'fenysha_events/sounds/tools/phystools/physgun_cant_grab.ogg', 100, TRUE)
		return FALSE

	if(isliving(target))
		var/mob/living/L = target
		if(force_grab)
			L.SetParalyzed(INFINITY, TRUE)
		if(L.has_status_effect(/datum/status_effect/physgun_pause))
			L.remove_status_effect(/datum/status_effect/physgun_pause)
		target.add_traits(list(TRAIT_HANDS_BLOCKED), REF(src))
		RegisterSignal(target, COMSIG_LIVING_RESIST, PROC_REF(on_living_resist), TRUE)

	current_grab_component = target.AddComponent(/datum/component/physgun_grab, src)

	if(!current_grab_component)
		if(isliving(target))
			target.remove_traits(list(TRAIT_HANDS_BLOCKED), REF(src))
			UnregisterSignal(target, COMSIG_LIVING_RESIST)
			if(force_grab)
				var/mob/living/L = target
				L.SetParalyzed(0)
		return FALSE

	if(target.anchored)
		target.set_anchored(FALSE)

	physgun_beam = user.ColoredBeam(target, "1-full", beam_color = effects_color)
	physgun_catcher = user.overlay_fullscreen("physgun_effect", /atom/movable/screen/fullscreen/cursor_catcher, 0)
	physgun_catcher.assign_to_mob(user)

	handled_atom = target
	physgun_user = user

	loop_sound.start()
	START_PROCESSING(SSfastprocess, src)

	return TRUE

/obj/item/physgun/proc/release_atom()
	var/atom/movable/released_atom = handled_atom
	var/mob/living/released_living

	if(isliving(released_atom))
		released_living = released_atom

	if(released_living)
		UnregisterSignal(released_living, COMSIG_LIVING_RESIST)
		released_living.remove_traits(list(TRAIT_HANDS_BLOCKED), REF(src))
		if(force_grab)
			released_living.SetParalyzed(0)

	if(released_atom)
		SEND_SIGNAL(released_atom, COMSIG_MOVABLE_PHYSGUN_RELEASED)

	STOP_PROCESSING(SSfastprocess, src)

	if(physgun_user)
		physgun_user.clear_fullscreen("physgun_effect")

	if(physgun_beam)
		qdel(physgun_beam)

	physgun_beam = null
	physgun_catcher = null
	current_grab_component = null
	physgun_user = null
	handled_atom = null

	loop_sound.stop()

/obj/item/physgun/proc/rotate_object(atom/movable/target)
	target.setDir(turn(target.dir, -90))

/obj/item/physgun/proc/pause_atom(atom/movable/target)
	var/mob/living/L

	STOP_PROCESSING(SSfastprocess, src)

	if(isliving(target))
		L = target
		UnregisterSignal(target, COMSIG_LIVING_RESIST)
		L.remove_traits(list(TRAIT_HANDS_BLOCKED), REF(src))

	if(physgun_catcher)
		physgun_catcher = null

	if(physgun_user)
		physgun_user.clear_fullscreen("physgun_effect")

	if(physgun_beam)
		qdel(physgun_beam)

	physgun_beam = null
	physgun_user = null
	handled_atom = null
	current_grab_component = null

	loop_sound.stop()

	SEND_SIGNAL(target, COMSIG_MOVABLE_PHYSGUN_PAUSED)

/obj/item/physgun/proc/repulse(atom/movable/target, mob/user)
	release_atom()

	var/turf/target_turf = get_turf_in_angle(get_angle(user, target), get_turf(user), 10)
	target.throw_at(target_turf, range = 9, speed = target.density ? 3 : 4, thrower = user, spin = isitem(target))

	playsound(user, 'fenysha_events/sounds/tools/phystools/physgun_repulse.ogg', 100, TRUE)

/obj/item/physgun/advanced
	advanced = TRUE
	use_cooldown = 1 SECONDS
	personal_color = COLOR_FRENCH_BLUE

/obj/item/physgun/advanced/admin
	force_grab = TRUE
	personal_color = COLOR_RED_GRAY

/datum/looping_sound/gravgen/kinesis/phys_gun
	mid_sounds = 'fenysha_events/sounds/tools/phystools/physgun_hold_loop.ogg'
	mid_length = 1.9 SECONDS

/datum/status_effect/physgun_pause
	id = "physgun_pause"
	alert_type = null
	var/force = FALSE

/datum/status_effect/physgun_pause/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(on_resist), TRUE)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, REF(src))

/datum/status_effect/physgun_pause/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, REF(src))

/datum/status_effect/physgun_pause/proc/on_resist()
	SIGNAL_HANDLER

	if(force)
		owner.balloon_alert(owner, "can't escape!")
		return

	SEND_SIGNAL(owner, COMSIG_MOVABLE_PHYSGUN_RELEASED)
	owner.remove_status_effect(src)

/datum/status_effect/physgun_pause/admin
	id = "physgun_pause_admin"
	force = TRUE

/datum/component/physgun_grab
	VAR_PRIVATE/atom/movable/movable_parent = null
	VAR_PRIVATE/obj/item/physgun/physgun = null
	VAR_PRIVATE/paused = FALSE
	VAR_PRIVATE/original_density = FALSE
	VAR_PRIVATE/original_movement_type = 0
	VAR_PRIVATE/original_plane = 0
	VAR_PRIVATE/original_anchored = FALSE
	var/stored_pixel_x = 0
	var/stored_pixel_y = 0

/datum/component/physgun_grab/Initialize(obj/item/physgun/P)
	if(!ismovable(parent) || !istype(P))
		return COMPONENT_INCOMPATIBLE

	movable_parent = parent
	physgun = P

	original_density = movable_parent.density
	original_movement_type = movable_parent.movement_type
	original_plane = movable_parent.plane
	original_anchored = movable_parent.anchored
	stored_pixel_x = movable_parent.pixel_x
	stored_pixel_y = movable_parent.pixel_y

	movable_parent.movement_type = FLYING
	movable_parent.set_density(FALSE)
	movable_parent.plane = movable_parent.plane + 1
	parent.add_filter("physgun", 3, list("type" = "outline", "color" = P.effects_color, "size" = 2))

/datum/component/physgun_grab/RegisterWithParent()
	. = ..()
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PHYSGUN_GRABBED, PROC_REF(on_physgun_grab))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PHYSGUN_PAUSED, PROC_REF(on_physgun_pause))
	RegisterSignal(movable_parent, COMSIG_MOVABLE_PHYSGUN_RELEASED, PROC_REF(on_physgun_release))

/datum/component/physgun_grab/proc/on_physgun_grab(atom/movable/source, obj/item/physgun/new_physgun)
	SIGNAL_HANDLER

	if(paused)
		on_physgun_release()
		return

	return COMPONENT_BLOCK_PHYSGUN_GRAB

/datum/component/physgun_grab/proc/on_physgun_pause()
	SIGNAL_HANDLER

	if(paused)
		return

	paused = TRUE
	movable_parent.set_anchored(TRUE)
	movable_parent.plane = original_plane
	ADD_TRAIT(movable_parent, TRAIT_PHYSGUN_PAUSE, PHYSGUN_EFFECTS)

	if(isliving(movable_parent))
		var/mob/living/L = movable_parent
		var/status_path = physgun.force_grab ? /datum/status_effect/physgun_pause/admin : /datum/status_effect/physgun_pause
		L.apply_status_effect(status_path)
		REMOVE_TRAIT(movable_parent, TRAIT_HANDS_BLOCKED, REF(physgun))

/datum/component/physgun_grab/proc/on_physgun_release()
	SIGNAL_HANDLER

	if(QDELETED(movable_parent))
		qdel(src)
		return

	movable_parent.pixel_x = stored_pixel_x
	movable_parent.pixel_y = stored_pixel_y
	movable_parent.movement_type = original_movement_type
	movable_parent.set_density(original_density)
	movable_parent.plane = original_plane
	movable_parent.set_anchored(original_anchored)
	movable_parent.remove_filter("physgun")

	if(HAS_TRAIT(movable_parent, TRAIT_PHYSGUN_PAUSE))
		REMOVE_TRAIT(movable_parent, TRAIT_PHYSGUN_PAUSE, PHYSGUN_EFFECTS)

	qdel(src)

/datum/component/physgun_grab/proc/on_pre_move(atom/movable/source)
	SIGNAL_HANDLER

	if(!HAS_TRAIT(source, TRAIT_PHYSGUN_PAUSE))
		return

	if(HAS_TRAIT(source, TRAIT_GODMODE))
		return

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE


/atom/proc/ColoredBeam(atom/BeamTarget, icon_state = "b_beam", icon = 'icons/effects/beam.dmi', time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam, beam_color = null, emissive = TRUE, animate = TRUE, override_origin_pixel_x = null, override_origin_pixel_y = null, override_target_pixel_x = null, override_target_pixel_y = null, layer = ABOVE_ALL_MOB_LAYER)
	var/datum/beam/colored/newbeam = new(src, BeamTarget, icon, icon_state, time, maxdistance, beam_type, beam_color, emissive, animate, override_origin_pixel_x, override_origin_pixel_y, override_target_pixel_x, override_target_pixel_y, layer)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam/, Start))
	return newbeam

/datum/beam/colored

/datum/beam/colored/set_subsegment_appearance(obj/effect/ebeam/segment)
	set_up_effect(segment, icon_state)
	segment.color = beam_color
