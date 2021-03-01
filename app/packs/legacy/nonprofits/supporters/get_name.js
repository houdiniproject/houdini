// License: LGPL-3.0-or-later
appl.def('get_supporter_name', function(supporter) {
	if(!supporter) return ''
	return supporter.name || supporter.email
})
