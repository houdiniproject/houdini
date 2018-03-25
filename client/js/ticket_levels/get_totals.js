// License: LGPL-3.0-or-later
// Retrieve the total attendee (ticket) counts for every ticket level for a given event
var request = require("../common/super-agent-promise")

module.exports = get_totals

function get_totals(nonprofit_id, event_id) {
	return request.get('/nonprofits/' + nonprofit_id + '/events/' + event_id + '/ticket_levels')
		.perform()
}

