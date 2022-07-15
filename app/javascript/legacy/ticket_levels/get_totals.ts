import ticket_levels from "../../routes/nonprofits/events/ticket_levels";
// License: LGPL-3.0-or-later
// Retrieve the total attendee (ticket) counts for every ticket level for a given event
import request from "../common/super-agent-promise";

export default function get_totals(nonprofit_id:string, event_id:string):Promise<unknown> {
	return request.get(ticket_levels.nonprofitEventTicketLevels.path({nonprofitId: nonprofit_id, id: event_id}))
		.perform();
}

