/mob/living/silicon/Topic(href, href_list)
	. = ..()
#if !defined(NOERP) // FENYSHA EDIT ADDITION - no panel on these builds; examine prints the description instead
	if(href_list["lookup_info"] == "open_examine_panel")
		examine_panel.holder = src
		examine_panel.ui_interact(usr) //datum has a tgui component, here we open the window
#endif
	if(href_list["temporary_flavor"]) // we need this here because tg code doesnt call parent in /mob/living/silicon/Topic()
		show_temp_ftext(usr)
