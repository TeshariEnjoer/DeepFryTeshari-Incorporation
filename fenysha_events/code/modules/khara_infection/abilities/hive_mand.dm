/datum/component/khara_hivemind
	VAR_PRIVATE/static/list/all_minds = list()
	var/datum/action/cooldown/khara_hivemind_talk/action
	var/cast = KHARA_CAST_LESSER

/datum/component/khara_hivemind/Initialize(cast = KHARA_CAST_LESSER)
	if(!is_khara_creature(parent))
		return COMPONENT_INCOMPATIBLE
	action = new()
	action.Grant(parent)
	action.component = src
	all_minds += parent
	src.cast = cast

/datum/component/khara_hivemind/Destroy(force)
	all_minds -= parent
	action.Remove(parent)
	QDEL_NULL(action)
	. = ..()

/datum/component/khara_hivemind/proc/get_minds()
	RETURN_TYPE(/list)
	var/list/to_return = list()
	for(var/mob/living/L in all_minds)
		if(QDELETED(L) || !L.client)
			continue
		to_return += L
	return to_return

/datum/action/cooldown/khara_hivemind_talk
	name = "Hivemind talk"
	desc = "Talk to other khara creatures!"
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "discordant_whisper"
	check_flags = NONE
	cooldown_time = 1 SECONDS
	text_cooldown = TRUE
	click_to_activate = FALSE

	var/datum/component/khara_hivemind/component = null

/datum/action/cooldown/khara_hivemind_talk/Activate(atom/target)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(talk_to_hivemind))

/datum/action/cooldown/khara_hivemind_talk/proc/talk_to_hivemind(say_msg = null)
	var/msg = say_msg
	if(!msg)
		msg = tgui_input_text(owner, "What you want to say", "Khara hivemind", multiline = FALSE)
	if(!msg || msg == "")
		return
	var/cast = component.cast
	var/list/listeners = component.get_minds()
	owner.log_sayverb_talk(msg, list(), tag = "khara hivemind")
	var/raw = span_blob("<b><font color=\"[COLOR_RED]\">Khara overmind: ...[msg]</font></b>")
	var/rendered = raw
	if(cast == KHARA_CAST_ADAPTED)
		rendered = span_big(raw)
	else if(cast == KHARA_CAST_ASSIMILATING)
		rendered = span_boldbig(raw)

	relay_to_list_and_observers(
		rendered,
		listeners,
		owner,
		MESSAGE_TYPE_RADIO,
		translatable_body = msg,
	)
	StartCooldown()
