/// The address every wiki browser falls back to when it has not been pointed anywhere else.
#define DEFAULT_WIKI_BROWSER_URL "https://fenysha.github.io/tartarus-wiki/en/"

/// Vets an address before it reaches the browser frame, so a bad var edit cannot put anything else in there.
/proc/sanitize_wiki_browser_url(url, fallback = DEFAULT_WIKI_BROWSER_URL)
	var/static/regex/web_address = regex(@"^https?://[^\s'<>]+$")
	if(istext(url) && findtext(trim(url), web_address))
		return trim(url)
	return fallback
