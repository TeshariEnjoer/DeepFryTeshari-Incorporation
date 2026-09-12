#define STARTING_CASH_AMOUNT 200

GLOBAL_DATUM_INIT(starting_cash_handler, /datum/starting_cash_handler, new)

// Gives every SSjob-spawned crewmember (roundstart and latejoin) their starting dollars.
/datum/starting_cash_handler

/datum/starting_cash_handler/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/starting_cash_handler/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/crewmember = spawned
	if(!istype(crewmember))
		return

	var/obj/item/stack/dollar/cash = new(get_turf(crewmember), STARTING_CASH_AMOUNT)
	crewmember.equip_in_one_of_slots(
		cash,
		list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_BACKPACK, LOCATION_HANDS),
		qdel_on_fail = FALSE,
		indirect_action = TRUE,
	)

#undef STARTING_CASH_AMOUNT
