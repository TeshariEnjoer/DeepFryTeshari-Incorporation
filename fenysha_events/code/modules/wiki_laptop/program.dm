/datum/computer_file/program/wiki_browser
	filename = "wikibrowser"
	filedesc = "Reference Browser"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "generic"
	extended_desc = "A browser stripped of its address bar. It loads the one page it was set up with and refuses to be pointed anywhere else."
	program_icon = "book-open"
	size = 4
	tgui_id = "NtosWikiBrowser"
	can_run_on_flags = PROGRAM_ALL
	/// The single address this copy loads. Stamped in by the machine it ships on; players have no way to change it.
	var/url = DEFAULT_WIKI_BROWSER_URL

/datum/computer_file/program/wiki_browser/clone(rename = FALSE)
	var/datum/computer_file/program/wiki_browser/copy = ..()
	copy.url = url
	return copy

/datum/computer_file/program/wiki_browser/ui_static_data(mob/user)
	var/list/data = list()
	data["url"] = sanitize_wiki_browser_url(url)
	return data
