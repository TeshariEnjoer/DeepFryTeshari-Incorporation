/*
 * Configurable advanced ranged attack for basic mobs.
 *
 * Supports:
 * - projectile or casing based attacks;
 * - burst fire;
 * - magazine size;
 * - reload delay;
 * - custom can_fire checks;
 * - before/after fire callbacks;
 */


/datum/component/advanced_ranged_attacks

	/// What kind of casing do we use to fire?
	var/casing_type

	/// What kind of projectile do we fire?
	/// Use only one of this or casing_type.
	var/projectile_type

	/// Sound to play when we fire.
	var/projectile_sound

	/// How many shots we fire in one burst.
	var/burst_shots

	/// Interval between shots in a burst.
	var/burst_intervals

	/// Time between individual shots.
	var/cooldown_time

	/// Number of shots which can be fired before reloading.
	var/shots_before_reload

	/// Time required to reload.
	var/reload_time

	/// Number of shots fired since the last reload.
	var/shots_fired = 0

	/// Whether the weapon is currently being reloaded.
	var/reloading = FALSE

	/// Callback invoked immediately before firing.
	var/datum/callback/before_fire_callback

	/// Callback invoked after successfully firing.
	var/datum/callback/after_fire_callback

	COOLDOWN_DECLARE(fire_cooldown)
	COOLDOWN_DECLARE(reload_cooldown)


/datum/component/advanced_ranged_attacks/Initialize(
	casing_type,
	projectile_type,
	projectile_sound = 'sound/items/weapons/gun/pistol/shot.ogg',
	burst_shots,
	burst_intervals = 0.2 SECONDS,
	cooldown_time = 3 SECONDS,
	shots_before_reload,
	reload_time = 5 SECONDS,
	datum/callback/before_fire_callback,
	datum/callback/after_fire_callback
)

	. = ..()

	if(!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.casing_type = casing_type
	src.projectile_type = projectile_type
	src.projectile_sound = projectile_sound
	src.cooldown_time = cooldown_time
	src.shots_before_reload = shots_before_reload
	src.reload_time = reload_time
	src.before_fire_callback = before_fire_callback
	src.after_fire_callback = after_fire_callback

	if(casing_type && projectile_type)
		CRASH("Set both casing_type and projectile_type in [parent]'s advanced ranged attacks component!")

	if(!casing_type && !projectile_type)
		CRASH("Set neither casing_type nor projectile_type in [parent]'s advanced ranged attacks component!")

	if(burst_shots <= 1)
		return

	src.burst_shots = burst_shots
	src.burst_intervals = burst_intervals


/datum/component/advanced_ranged_attacks/RegisterWithParent()

	. = ..()

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

	RegisterSignal(parent, COMSIG_MOB_ATTACK_RANGED, PROC_REF(fire_ranged_attack))
	RegisterSignal(parent, COMSIG_MOB_TROPHY_ACTIVATED(TROPHY_WATCHER), PROC_REF(disable_attack))
	RegisterSignal(parent, COMSIG_LIVING_STATUS_APPLIED, PROC_REF(on_status_applied))
	RegisterSignal(parent, COMSIG_LIVING_STATUS_REMOVED, PROC_REF(on_status_removed))


/datum/component/advanced_ranged_attacks/UnregisterFromParent()

	. = ..()

	UnregisterSignal(parent, list(
		COMSIG_MOB_ATTACK_RANGED,
		COMSIG_MOB_TROPHY_ACTIVATED(TROPHY_WATCHER),
		COMSIG_LIVING_STATUS_APPLIED,
		COMSIG_LIVING_STATUS_REMOVED
	))

	REMOVE_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)


/datum/component/advanced_ranged_attacks/proc/fire_ranged_attack(
	mob/living/basic/firer,
	atom/target,
	modifiers
)

	SIGNAL_HANDLER

	if(QDELETED(firer) || QDELETED(target))
		return

	if(reloading)
		return

	if(shots_before_reload && shots_fired >= shots_before_reload)
		start_reload(firer)
		return

	if(!can_fire(firer, target, modifiers))
		return

	if(before_fire_callback)
		before_fire_callback.Invoke(firer, target, modifiers)

	COOLDOWN_START(src, fire_cooldown, cooldown_time)

	INVOKE_ASYNC(src, PROC_REF(async_fire_ranged_attack), firer, target, modifiers)

	if(isnull(burst_shots))
		return

	for(var/i in 1 to (burst_shots - 1))

		if(shots_before_reload && shots_fired + i >= shots_before_reload)
			break

		addtimer(CALLBACK(src, PROC_REF(async_fire_ranged_attack), firer, target, modifiers), i * burst_intervals)


/datum/component/advanced_ranged_attacks/proc/can_fire(
	mob/living/basic/firer,
	atom/target,
	modifiers
)

	if(QDELETED(firer) || QDELETED(target))
		return FALSE

	if(reloading)
		return FALSE

	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		return FALSE

	if(SEND_SIGNAL(firer, COMSIG_BASICMOB_PRE_ATTACK_RANGED, target, modifiers) & COMPONENT_CANCEL_RANGED_ATTACK)
		return FALSE

	if(shots_before_reload && shots_fired >= shots_before_reload)
		return FALSE

	return TRUE


/datum/component/advanced_ranged_attacks/proc/async_fire_ranged_attack(
	mob/living/basic/firer,
	atom/target,
	modifiers
)

	if(QDELETED(firer) || QDELETED(target))
		return

	if(reloading)
		return

	if(shots_before_reload && shots_fired >= shots_before_reload)
		return

	shots_fired++

	firer.face_atom(target)

	if(projectile_type)
		firer.fire_projectile(
			projectile_type,
			target,
			projectile_sound
		)

		after_fire(
			firer,
			target,
			modifiers
		)

		return

	playsound(firer, projectile_sound, 100, TRUE)

	var/turf/startloc = get_turf(firer)
	var/obj/item/ammo_casing/casing = new casing_type(startloc)

	var/target_zone

	if(ismob(target))
		var/mob/target_mob = target
		target_zone = target_mob.get_random_valid_zone()
	else
		target_zone = ran_zone()

	casing.fire_casing(
		target,
		firer,
		null,
		null,
		null,
		target_zone,
		0,
		firer
	)

	casing.update_appearance()
	casing.fade_into_nothing(30 SECONDS)

	after_fire(
		firer,
		target,
		modifiers
	)


/datum/component/advanced_ranged_attacks/proc/after_fire(
	mob/living/basic/firer,
	atom/target,
	modifiers
)

	SEND_SIGNAL(parent, COMSIG_BASICMOB_POST_ATTACK_RANGED, target, modifiers)

	if(after_fire_callback)
		after_fire_callback.Invoke(
			firer,
			target,
			modifiers
		)

	if(shots_before_reload && shots_fired >= shots_before_reload)
		return


/datum/component/advanced_ranged_attacks/proc/start_reload(
	mob/living/basic/firer
)

	if(!shots_before_reload)
		return

	if(reloading)
		return

	if(shots_fired < shots_before_reload)
		return

	reloading = TRUE

	COOLDOWN_START(src, reload_cooldown, reload_time)
	INVOKE_ASYNC(src, PROC_REF(async_reload), firer)


/datum/component/advanced_ranged_attacks/proc/async_reload(
	mob/living/basic/firer
)

	if(QDELETED(firer))
		reloading = FALSE
		return

	if(!do_after(
		firer,
		reload_time,
		firer,
		max_interact_count = 1
	))
		reloading = FALSE
		return

	if(QDELETED(firer))
		reloading = FALSE
		return

	shots_fired = 0
	reloading = FALSE


/datum/component/advanced_ranged_attacks/proc/disable_attack(
	mob/source,
	obj/item/crusher_trophy/used_trophy,
	mob/living/user
)

	SIGNAL_HANDLER

	var/stun_duration = (used_trophy.bonus_value * 0.1) SECONDS

	COOLDOWN_INCREMENT(src, fire_cooldown, stun_duration)
	COOLDOWN_INCREMENT(src, reload_cooldown, stun_duration)


/datum/component/advanced_ranged_attacks/proc/on_status_applied(
	mob/living/source,
	datum/status_effect/effect
)

	SIGNAL_HANDLER

	if(!istype(effect, /datum/status_effect/rebuked))
		return

	var/datum/status_effect/rebuked/rebuked = effect

	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		COOLDOWN_INCREMENT(src, fire_cooldown, cooldown_time * (rebuked.cd_increase - 1))

	if(!COOLDOWN_FINISHED(src, reload_cooldown))
		COOLDOWN_INCREMENT(src, reload_cooldown, reload_time * (rebuked.cd_increase - 1))

	cooldown_time *= rebuked.cd_increase
	reload_time *= rebuked.cd_increase


/datum/component/advanced_ranged_attacks/proc/on_status_removed(
	mob/living/source,
	datum/status_effect/effect
)

	SIGNAL_HANDLER

	if(!istype(effect, /datum/status_effect/rebuked))
		return

	var/datum/status_effect/rebuked/rebuked = effect

	cooldown_time /= rebuked.cd_increase
	reload_time /= rebuked.cd_increase
