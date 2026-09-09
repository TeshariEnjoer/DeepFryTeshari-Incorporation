/datum/element/ai_pull_awareness


/datum/element/ai_pull_awareness/Attach(datum/target)

	. = ..()

	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

	RegisterSignal(
		target,
		COMSIG_LIVING_GET_PULLED,
		PROC_REF(on_pulled)
	)


/datum/element/ai_pull_awareness/Detach(
	datum/source,
	...
)

	. = ..()

	UnregisterSignal(
		source,
		COMSIG_LIVING_GET_PULLED
	)


/datum/element/ai_pull_awareness/proc/on_pulled(
	mob/living/victim,
	mob/living/puller
)

	SIGNAL_HANDLER

	if(!victim?.ai_controller)
		return

	if(!puller || puller == victim)
		return

	if(QDELETED(puller))
		return

	victim.ai_controller.set_blackboard_key(
		BB_BASIC_MOB_PULL_TARGET,
		puller
	)



/datum/ai_planning_subtree/pull_response

	operational_datums = list(/datum/element/ai_pull_awareness)
	var/pull_target_key = BB_BASIC_MOB_PULL_TARGET
	var/pull_response_behavior = /datum/ai_behavior/pull_response
	var/pull_escape_behavior = /datum/ai_behavior/break_pull


/datum/ai_planning_subtree/pull_response/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)
	var/mob/living/puller = controller.blackboard[pull_target_key]

	if(!puller || QDELETED(puller))
		controller.clear_blackboard_key(pull_target_key)
		return

	controller.queue_behavior(
		pull_response_behavior,
		pull_target_key,
		pull_escape_behavior
	)

/datum/ai_behavior/pull_response

	action_cooldown = 1 SECONDS


/datum/ai_behavior/pull_response/perform(
	seconds_per_tick,
	datum/ai_controller/controller,
	pull_target_key,
	pull_escape_behavior
)
	var/mob/living/puller = controller.blackboard[pull_target_key]

	if(!puller || QDELETED(puller))
		controller.clear_blackboard_key(pull_target_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.queue_behavior(
		pull_escape_behavior,
		puller
	)

	controller.clear_blackboard_key(
		pull_target_key
	)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_planning_subtree/pull_response/push_after
	pull_escape_behavior = /datum/ai_behavior/break_pull/push_after


/datum/ai_behavior/break_pull

/datum/ai_behavior/break_pull/perform(seconds_per_tick, datum/ai_controller/controller, mob/living/puller)
	var/mob/living/pawn = controller.pawn

	if(QDELETED(pawn) || QDELETED(puller))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(pawn.pulledby != puller)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	puller.stop_pulling()
	pawn.visible_message("[pawn] break from [puller.p_their()] grab!")
	after_break(pawn, puller, controller)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/break_pull/proc/after_break(mob/living/pawn, mob/living/puller, datum/ai_controller/controller)
	return

/datum/ai_behavior/break_pull/push_after

/datum/ai_behavior/break_pull/push_after/after_break(mob/living/pawn, mob/living/puller, datum/ai_controller/controller)
	pawn.PushAM(puller)
	return

