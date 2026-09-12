/*
*	The bare version: no NtOS shell, no desktop, no other programs. Opening it is the page and nothing else.
*/

/obj/item/wiki_laptop
	name = "wiki laptop"
	desc = "Seems to just open one page."
	icon = 'icons/obj/devices/modular_laptop.dmi'
	icon_state = "laptop"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = SLOWS_WHILE_IN_HAND
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 4)
	/// The only address this laptop loads. Set it per instance from the map editor or VV.
	var/url = DEFAULT_WIKI_BROWSER_URL

/obj/item/wiki_laptop/attack_self(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/item/wiki_laptop/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/wiki_laptop/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WikiBrowser", name)
		ui.open()

/obj/item/wiki_laptop/ui_static_data(mob/user)
	var/list/data = list()
	data["url"] = sanitize_wiki_browser_url(url)
	return data
