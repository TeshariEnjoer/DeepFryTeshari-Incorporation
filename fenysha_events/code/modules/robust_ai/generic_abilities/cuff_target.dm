/datum/ai_planning_subtree/restrain_if_downed
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	var/restrain_time = 5 SECONDS
	var/clear_target = TRUE
	var/ability_key = BB_BASIC_MOB_ABILITY_RESTRAIN_TARGET


/datum/ai_planning_subtree/restrain_if_downed/SelectBehaviors(
	datum/ai_controller/controller,
	seconds_per_tick
)
	var/mob/living/pawn = controller.pawn
	var/mob/living/carbon/target = controller.blackboard[target_key]

	if(!target || !iscarbon(target))
		return

	if(target == pawn)
		return

	if(target.stat == DEAD)
		return

	if(target.handcuffed)
		if(clear_target)
			controller.clear_blackboard_key(target_key)
		return

	if(!target.canBeHandcuffed())
		return

	if(target.staminaloss < target.max_stamina)
		return

	if(get_dist(pawn, target) > 1)
		return

	var/datum/action/cooldown/mob_cooldown/restrain_target/restrain_action = controller.blackboard[ability_key]

	if(!restrain_action)
		return

	restrain_action.Activate(target)

	return SUBTREE_RETURN_FINISH_PLANNING


/datum/action/cooldown/mob_cooldown/restrain_target
	name = "Restrain target"
	desc = "Restrain an incapacitated target."

	cooldown_time = 10 SECONDS
	shared_cooldown = null

	button_icon = 'icons/obj/weapons/restraints.dmi'
	button_icon_state = "cuff"

	var/restrain_time = 5 SECONDS
	var/restrain_type = /obj/item/restraints/handcuffs/cable


/datum/action/cooldown/mob_cooldown/restrain_target/Activate(atom/target)

	var/mob/living/user = owner

	if(QDELETED(user) || QDELETED(target))
		return

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target

	if(carbon_target == user)
		return

	if(carbon_target.stat == DEAD)
		return

	if(carbon_target.handcuffed)
		return

	if(!carbon_target.canBeHandcuffed())
		return

	if(carbon_target.staminaloss < carbon_target.max_stamina)
		return

	if(get_dist(user, carbon_target) > 1)
		return

	if(!do_after(
		user,
		restrain_time,
		carbon_target
	))
		StartCooldown(2 SECONDS)
		return

	if(QDELETED(carbon_target))
		return

	if(carbon_target.stat == DEAD)
		return

	if(carbon_target.handcuffed)
		return

	if(!carbon_target.canBeHandcuffed())
		return

	carbon_target.set_handcuffed(
		new restrain_type(carbon_target)
	)

	carbon_target.update_handcuffed()

	return ..()
