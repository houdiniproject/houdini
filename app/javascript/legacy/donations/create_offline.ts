// License: LGPL-3.0-or-later
import request from '../common/super-agent-promise';
import format from '../common/format';
import type { Response }from 'superagent';
import { createOffsiteNonprofitsDonationsPath } from '../../routes';
import { UI } from '../types/UI';

declare const app: {nonprofit_id: number};

export default function create_offsite_donation(data:{amount?:number, date?:string, dollars?:string|number }, ui:UI): Promise<Response> {
	ui.start();
	if(data.dollars) {
		data.amount = format.dollarsToCents(data.dollars);
		delete data.dollars;
	}
	if(data.date) data.date = format.date.toStandard(data.date);
	return request.post(createOffsiteNonprofitsDonationsPath(app.nonprofit_id))
		.send({donation: data}).perform()
		.then(function(resp) {
			ui.success(resp);
			return resp;
		})
		.catch(function(resp) {
			ui.fail(resp);
			throw new Error(resp);
		});
}
