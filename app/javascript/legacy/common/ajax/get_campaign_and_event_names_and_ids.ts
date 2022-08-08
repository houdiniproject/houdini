// License: LGPL-3.0-or-later
import request from '../client';

import {
	nameAndIdNonprofitCampaignsPath,
	nameAndIdNonprofitEventsPath,
} from '../../../routes';

import type { Appl } from '../../types/appl';

declare const appl: Appl;

export default function get_campaign_and_event_names_and_ids(npo_id: string): void {
	const campaignsPath = nameAndIdNonprofitCampaignsPath(npo_id);
	const eventsPath = nameAndIdNonprofitEventsPath(npo_id);

	request.get(campaignsPath).end(function (err, resp) {
		let dataResponse = [];

		if (!err) {
			resp.body.unshift(false);
			dataResponse = resp.body.map((i: { creator?: string, id: number, isChildCampaign?: boolean, name: string }) => {
				if (i.isChildCampaign) {
					return { id: i.id, name: i.name + " - " + i.creator };
				}
				else {
					return { id: i.id, name: i.name };
				}
			});
		}
		appl.def('campaigns.data', dataResponse);
	});

	request.get(eventsPath).end(function (err, resp) {
		let dataResponse = [];
		if (!err) {
			resp.body.unshift(false);
			dataResponse = resp.body;
		}

		appl.def('events.data', dataResponse);
	});
}
