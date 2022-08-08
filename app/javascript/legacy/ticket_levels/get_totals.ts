// License: LGPL-3.0-or-later
// Retrieve the total attendee (ticket) counts for every ticket level for a given event

import { nonprofitEventTicketLevelsPath} from '../../routes';
import request from "../common/super-agent-promise";

export default function get_totals(nonprofit_id:string, event_id:string):Promise<unknown> {
	return request.get(nonprofitEventTicketLevelsPath(nonprofit_id, event_id))
		.perform();
}

