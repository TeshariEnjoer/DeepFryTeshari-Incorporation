/// The BYOND hub entry. Supersedes the tagline module, which is commented out of tgstation.dme
/// because both define update_status(). The hub cuts the entry off mid-tag somewhere past 250
/// characters, so the optional lines are only added when there is room left for them.

#define HUB_STATUS_LIMIT 250
#define HUB_LEADER " ... "

/datum/config_entry/string/wiki_link

/world/proc/update_status()

	var/list/manifest = list()

	if(SSmapping.current_map)
		manifest += "sector [lowertext(SSmapping.current_map.map_name)]"

	var/players = GLOB.clients.len
	var/popcap = CONFIG_GET(number/extreme_popcap)
	// Tells the hub we are full.
	game_state = (popcap && players >= popcap)

	var/subjects = "subjects [add_leading("[players]", 3, "0")]"
	if(popcap)
		subjects += "/[popcap]"
	if(LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		subjects += " (sealed)"
	else if(game_state)
		subjects += " (at capacity)"
	manifest += subjects

	manifest += "cycle [get_cycle_state()]"

	var/hostedby = CONFIG_GET(string/hostedby)
	if(!host && hostedby)
		manifest += "operator [hostedby]"

	var/name_line = "<b>[CONFIG_GET(string/servername)]</b>"
	var/manifest_line = jointext(manifest, HUB_LEADER)
	var/links_line = "<a href=\"[CONFIG_GET(string/discord_link)]\">discord</a> / <a href=\"[CONFIG_GET(string/wiki_link)]\">archive</a>"

	// What is left once the three lines that always ship, and their <br>s, are paid for.
	var/budget = HUB_STATUS_LIMIT - length(name_line) - length(manifest_line) - length(links_line) - 8

	var/candidate
	var/trial_line
	if(SSround_events?.active_event)
		var/datum/full_round_event/event = SSround_events.active_event
		candidate = "trial[HUB_LEADER][lowertext(event.hub_name || event.name)]"
		if(length(candidate) + 4 <= budget)
			trial_line = candidate
			budget -= length(candidate) + 4

	var/tagline_line
	var/tagline = CONFIG_GET(string/servertagline)
	if(tagline)
		candidate = "<i>[tagline]</i>"
		if(length(candidate) + 4 <= budget)
			tagline_line = candidate

	var/list/lines = list(name_line)
	if(tagline_line)
		lines += tagline_line
	lines += manifest_line
	if(trial_line)
		lines += trial_line
	lines += links_line

	status = jointext(lines, "<br>")

/world/proc/get_cycle_state()
	if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
		return "engine spinup"
	if(SSticker.current_state == GAME_STATE_PREGAME)
		return SSticker.GetTimeLeft() > 0 ? "intake [round(SSticker.GetTimeLeft() / 10)]s" : "intake closing"
	if(SSticker.current_state == GAME_STATE_SETTING_UP)
		return "intake closing"
	if(SSticker.current_state == GAME_STATE_FINISHED)
		return "chamber purge"
	if(!SSticker.IsRoundInProgress())
		return "standby"
	if(SSshuttle?.emergency && !(SSshuttle.emergency.mode in list(SHUTTLE_IDLE, SHUTTLE_ENDGAME)))
		return "extraction [SSshuttle.emergency.getTimerStr()]"
	return "t+[round_timestamp("hh:mm")]"

#undef HUB_LEADER
#undef HUB_STATUS_LIMIT
