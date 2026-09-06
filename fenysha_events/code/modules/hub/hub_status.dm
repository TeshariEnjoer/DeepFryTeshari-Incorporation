/// The BYOND hub entry. Supersedes the tagline module, which is commented out of tgstation.dme
/// because both define update_status(). The hub renders little more than <b>, <i>, <br>,
/// <font color> and <a href>, and truncates past about five lines.

#define HUB_LEADER " <font color='#5c5c5c'>...</font> "

/datum/config_entry/string/wiki_link
	config_entry_value = "We forgot to set the server's wiki link in config.txt"

/world/proc/update_status()

	var/list/manifest = list()

	var/new_status = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if(server_name)
			new_status += "<b>[server_name]</b>"
		new_status += " <font color='#7a7a7a'>&#8212; tartarus engine</font><br>"
		new_status += "<i><font color='#8a8a8a'>[CONFIG_GET(string/servertagline)]</font></i><br>"
		hostedby = CONFIG_GET(string/hostedby)

	if(SSmapping.current_map)
		manifest += "<font color='#6e6e6e'>sector</font> [lowertext(SSmapping.current_map.map_name)]"

	var/players = GLOB.clients.len
	var/popcap = CONFIG_GET(number/extreme_popcap)
	// Tells the hub we are full.
	game_state = (popcap && players >= popcap)

	var/subjects = "<font color='#6e6e6e'>subjects</font> [add_leading("[players]", 3, "0")][popcap ? "/[add_leading("[popcap]", 3, "0")]" : ""]"
	if(LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		subjects += " <font color='#b03a2e'>(sealed)</font>"
	else if(game_state)
		subjects += " <font color='#b03a2e'>(at capacity)</font>"
	manifest += subjects

	manifest += "<font color='#6e6e6e'>cycle</font> [get_cycle_state()]"

	if(!host && hostedby)
		manifest += "<font color='#6e6e6e'>operator</font> [hostedby]"

	new_status += "[jointext(manifest, HUB_LEADER)]<br>"

	if(SSround_events?.active_event)
		var/datum/full_round_event/event = SSround_events.active_event
		new_status += "<font color='#6e6e6e'>trial</font>[HUB_LEADER]<b><font color='#d9a441'>[lowertext(event.hub_name || event.name)]</font></b><br>"

	new_status += "<a href=\"[CONFIG_GET(string/discord_link)]\"><font color='#7b86c4'>DISCORD</font></a> <font color='#5c5c5c'>//</font> <a href=\"[CONFIG_GET(string/wiki_link)]\"><font color='#b8a06a'>ARCHIVE</font></a>"

	status = new_status

	// The cycle line is a live clock and nothing else refreshes between logins.
	if(SStimer)
		addtimer(CALLBACK(src, PROC_REF(update_status)), 1 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE)

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
		return "<font color='#d08020'>extraction [SSshuttle.emergency.getTimerStr()]</font>"
	return "t+[round_timestamp("hh:mm")]"

#undef HUB_LEADER
