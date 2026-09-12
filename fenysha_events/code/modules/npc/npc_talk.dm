/datum/element/npc_talk
	var/datum/callback/talk_callback

/datum/element/npc_talk/Attach(datum/target, datum/callback/callback)
	. = ..()

	if(!ismob(target) || !callback)
		return ELEMENT_INCOMPATIBLE

	talk_callback = callback
	RegisterSignal(target, COMSIG_NPC_TALK, PROC_REF(on_npc_talk))

/datum/element/npc_talk/proc/on_npc_talk(mob/living/basic/npc/source, list/talk_context)
	SIGNAL_HANDLER

	if(!talk_callback)
		return

	talk_callback.Invoke(talk_context)


/mob/living/basic/npc
	// Supported phrase placeholders:
	// %THEY%      - target's pronoun, "they"
	// %THEIR%     - target's possessive pronoun, "their"
	// %THEM%      - target's object pronoun, "them"
	// %THEYRE%    - target's "they are"
	// %MOBNAME%   - target's name
	// %PNAME%     - NPC's name
	// %PTHEY%     - NPC's pronoun, "they"
	// %PTHEIR%    - NPC's possessive pronoun, "their"
	// %PTHEM%     - NPC's object pronoun, "them"
	// %PTHEYRE%   - NPC's "they are"
	//
	// Placeholders referring to the target are replaced only when a target exists.
	// %PTHE...% placeholders always refer to the NPC speaking.
	//
	var/list/speech_phrases = list(
		NPC_TALK_KEY_IDLE = list(),
		NPC_TALK_KEY_TARGET = list(),
		NPC_TALK_KEY_INJURED = list(),
		NPC_TALK_KEY_LOWHEALTH = list(),
		NPC_TALK_KEY_ENEMY_NEARBY = list(),
		NPC_TALK_KEY_ENEMY_CROWD_NEARBY = list(),
		NPC_TALK_KEY_IN_DANGER = list(),
	)

/mob/living/basic/npc/proc/npc_say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode, list/message_mods)
	var/delay = clamp(round(length_char(message) / 3), 10, 45)
	show_npc_typing(delay)
	addtimer(CALLBACK(src, PROC_REF(delayed_say), message), delay)

	return TRUE

/mob/living/basic/npc/proc/delayed_say(message)
	return say(message)

/mob/living/basic/npc/proc/show_npc_typing(duration)
	clear_npc_typing()

	var/image/typing = image('icons/mob/effects/talk.dmi', src, "typing")
	typing.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	typing.layer = ABOVE_MOB_LAYER

	npc_typing_popup = typing
	add_overlay(npc_typing_popup)

	addtimer(CALLBACK(src, PROC_REF(clear_npc_typing)), duration)

/mob/living/basic/npc/proc/clear_npc_typing()
	if(!npc_typing_popup)
		return

	cut_overlay(npc_typing_popup)
	npc_typing_popup = null

/mob/living/basic/npc/proc/handle_npc_talk(list/talk_context)
	if(!length(talk_context))
		return

	var/static/list/priorities = list(
		NPC_TALK_KEY_IN_DANGER,
		NPC_TALK_KEY_ENEMY_CROWD_NEARBY,
		NPC_TALK_KEY_ENEMY_NEARBY,
		NPC_TALK_KEY_LOWHEALTH,
		NPC_TALK_KEY_INJURED,
		NPC_TALK_KEY_TARGET,
		NPC_TALK_KEY_IDLE,
	)

	for(var/key in priorities)
		if(!talk_context[key])
			continue

		var/list/phrases = speech_phrases[key]
		if(!length(phrases))
			continue

		var/phrase = pick(phrases)
		var/mob/living/basic/npc/pawn = src
		var/mob/living/target = talk_context[NPC_TALK_KEY_TARGET]

		if(target)
			phrase = replacetext(phrase, "%THEY%", target.p_they())
			phrase = replacetext(phrase, "%THEIR%", target.p_their())
			phrase = replacetext(phrase, "%THEM%", target.p_them())
			phrase = replacetext(phrase, "%THEYRE%", target.p_theyre())
			phrase = replacetext(phrase, "%MOBNAME%", target.name)

		phrase = replacetext(phrase, "%PNAME%", pawn.name)
		phrase = replacetext(phrase, "%PTHEY%", pawn.p_they())
		phrase = replacetext(phrase, "%PTHEIR%", pawn.p_their())
		phrase = replacetext(phrase, "%PTHEM%", pawn.p_them())
		phrase = replacetext(phrase, "%PTHEYRE%", pawn.p_theyre())

		npc_say(phrase)
		return
