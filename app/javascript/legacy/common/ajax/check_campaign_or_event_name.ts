// License: LGPL-3.0-or-later
import includes from 'lodash/includes';
import request from '../client';

import {
	nameAndIdNonprofitCampaignsPath,
	nameAndIdNonprofitEventsPath,
} from '../../../routes';

import type {Appl} from '../../types/appl';

declare const appl: Appl;
declare const app: {nonprofit_id: string};

export default function check_campaign_or_event_name(name:string, event_or_campaign:'event'|'campaign', callback:() => void):void {
	const url = event_or_campaign == "event" ?
		nameAndIdNonprofitCampaignsPath(app.nonprofit_id) :
		nameAndIdNonprofitEventsPath(app.nonprofit_id);

	request.get(url)
		.end(function (_err, resp) {
			const names = resp.body.map((x:{name:string}) => x.name);
			if (includes(names, name)) {
				appl.notify(`Oops.  It looks like you already have ${event_or_campaign === 'campaign' ? 'a' : 'an'} ${event_or_campaign} named '${name}'.  Please choose a different name and try again.`);
				return;
			}
			callback();
		});
}

