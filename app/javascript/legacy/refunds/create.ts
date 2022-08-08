// License: LGPL-3.0-or-later
import { Response } from 'superagent';
import format from '../common/format';

import format_err, { ErrorResponseType } from '../common/format_response_error';
import request from '../common/super-agent-promise';
import type { ApplWithPayments } from '../types/appl';

declare const appl: ApplWithPayments;
declare const app: {nonprofit_id:number};

appl.def('ajax_refunds', {
	create: function (charge_id:number, form_obj:{amount: string|number}, _node: unknown) {
		const obj = {...form_obj,
			amount: format.dollarsToCents(form_obj.amount),
		};

		appl.def({
			loading: true,
			refunds: { error: '', loading: true },
		});
		post_refund(charge_id, obj)
			.then(function (resp) {
				not_loading();
				appl.close_modal();
				return resp;
			})
			.then(function (resp) { return resp.body; })
			.then(fetch_data_on_success)
			.then(display_success_message)
			.catch(show_err);
	},
});

// Re-fetch all the payment data on the page after a refund has been made
function fetch_data_on_success<Refund=unknown>(refund:Refund):Refund {
	appl.payments.index();
	appl.ajax_payment_details.fetch(appl.payment_details.data.id);
	return refund;
}

// Display a nice message confirming the amounts of the refund they just made
function display_success_message<Refund = unknown>(refund: Refund): Refund {
	appl.notify(
		"Your refund was successful!"
	);
	return refund;
}

// Reset the loading state in the ui
function not_loading(x?: unknown): unknown {
	appl.def({ loading: false, refunds: { loading: false } });
	return x;
}

// Display an error in the ui
function show_err(resp:Response) {
	not_loading();
	console.warn('Error in promise chain: ', resp);
	appl.def('refunds', {
		error: format_err(resp as unknown as ErrorResponseType),
		loading: false,
	});
}

// Make the ajax request, returning a Promise
function post_refund(charge_id:number, obj:Record<string,unknown>): Promise<Response> {
	return request
		.post('/nonprofits/' + app.nonprofit_id + '/charges/' + charge_id + '/refunds')
		.send({ refund: obj })
		.perform();
}

