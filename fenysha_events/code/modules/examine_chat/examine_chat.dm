/*
*	The examine panel is unreachable on NOERP builds, so a long description collapses inside the chat
*	message itself instead of behind a link to a window nobody can open. The markup is a <details>, and
*	the styling that hides the marker once it is open lives in tgui-panel's Chat.scss.
*/

/**
 * Wraps prose so chat shows a preview and reveals the rest in place when clicked.
 *
 * Each half is translated on its own because translated_chat_text() returns markup for the autotranslate
 * overlay, which cannot be cut in half by copytext.
 */
/proc/collapsed_chat_text(client/target, full_text, client/author, preview_limit = FLAVOR_PREVIEW_LIMIT)
	if(!istext(full_text) || !length(full_text))
		return full_text
	if(length_char(full_text) <= preview_limit)
		return translated_chat_text(target, full_text, author)

	var/preview = copytext_char(full_text, 1, preview_limit)
	var/remainder = copytext_char(full_text, preview_limit)
	return "<details class='examine_more'><summary>[translated_chat_text(target, preview, author)]... \
		<span class='examine_more_link'>\[Read more\]</span></summary>[translated_chat_text(target, remainder, author)]</details>"
