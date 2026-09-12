/obj/item/modular_computer/laptop/wiki
	name = "reference laptop"
	desc = "A laptop bolted shut around a single bookmark. Reads the manual, does nothing else."
	starting_programs = list(/datum/computer_file/program/wiki_browser)
	/// Stamped onto the installed browser on init, so each laptop can be var edited to its own page.
	var/wiki_url = DEFAULT_WIKI_BROWSER_URL

/obj/item/modular_computer/laptop/wiki/Initialize(mapload)
	. = ..()
	// install_default_programs() has already run by this point, so the copy to stamp exists
	for(var/datum/computer_file/program/wiki_browser/browser in stored_files)
		browser.url = wiki_url
