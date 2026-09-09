/datum/ai_planning_subtree/flee_target/if_to_close
	var/maximum_distance = 2

/datum/ai_planning_subtree/flee_target/if_to_close/should_flee(datum/ai_controller/controller, atom/flee_from)
	if(get_dist(controller.pawn, flee_from) > maximum_distance)
		return
	return ..()


/datum/ai_planning_subtree/targeted_mob_ability/check_range
	var/min_range = 0
	var/max_range = 30

/datum/ai_planning_subtree/targeted_mob_ability/check_range/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]
	if(!target || !controller.pawn)
		return
	var/distance_to_target = get_dist(controller.pawn, target)
	if(distance_to_target >= max_range || distance_to_target <= min_range)
		return
	return ..()


/datum/ai_planning_subtree/cuff_if_downed
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	var/cuff_time = 5 SECONDS
	var/clear_target = TRUE

/datum/ai_planning_subtree/cuff_if_downed/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!target || !iscarbon(target))
		return
	if(controller.blackboard[BB_BASIC_MOB_BEGIN_CUFFING])
		return
	var/mob/living/carbon/carbon_target = target
	if(carbon_target.handcuffed)
		if(clear_target)
			controller.clear_blackboard_key(target_key)
		return
	if(!carbon_target.canBeHandcuffed())
		return
	if(!(carbon_target.staminaloss >= carbon_target.max_stamina))
		return
	if(get_dist(pawn, carbon_target) > 1)
		return
	var/cuff_type = controller.blackboard[BB_BASIC_MOB_CUFF_TYPE] || BB_BASIC_MOB_DEFAULT_CUFF_TYPE
	controller.queue_behavior(/datum/ai_behavior/zipties_target, target_key, cuff_type, cuff_time, clear_target)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/zipties_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, cuff_type, cuff_time, clear_target)
	var/mob/living/pawn = controller.pawn
	var/mob/living/carbon/carbon_target = controller.blackboard[target_key]
	if(!carbon_target || (get_dist(pawn, carbon_target) > 1) || carbon_target.handcuffed)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(controller.blackboard[BB_BASIC_MOB_BEGIN_CUFFING])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	controller.set_blackboard_key(BB_BASIC_MOB_BEGIN_CUFFING, TRUE)
	to_chat(carbon_target, span_userdanger("[pawn] is trying to put zipties on you!"))
	pawn.visible_message(span_danger("[pawn] is trying to put zipties on [carbon_target]!"))
	if(!do_after(pawn, cuff_time, carbon_target))
		controller.clear_blackboard_key(BB_BASIC_MOB_BEGIN_CUFFING)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.clear_blackboard_key(BB_BASIC_MOB_BEGIN_CUFFING)
	if(!QDELETED(carbon_target) && carbon_target.canBeHandcuffed())
		carbon_target.set_handcuffed(new cuff_type(carbon_target))
		carbon_target.update_handcuffed()
	if(clear_target)
		controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


