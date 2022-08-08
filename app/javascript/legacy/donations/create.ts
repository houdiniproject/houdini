// License: LGPL-3.0-or-later
// This defines a create_donation function that will create a Donation and
// Charge in our database and on Stripe given a Supporter that has a valid Card
//
// Use this with the cards/fields.html.erb partial
//
// Call it like: create_donation(card_obj, donation_obj)
// where card object is the full card data (name, number, expiry, etc) from the cards/fields partial
// and donation_obj is all the donation data (amount, type, etc)
//
// This function will create a Donation if donation.recurring is falsy
// It will create a RecurringDonation if donation.recurring is true

import format_err from '../common/format_response_error';
import format  from '../common/format';
import request from '../common/super-agent-promise';
import { nonprofitsDonationsPath, nonprofitsRecurringDonationsPath } from '../../routes';

import type { Appl } from '../types/appl';

declare const app: {nonprofit_id:number};
declare const appl: Appl;

export default function create_donation(donation:{amount?: number, dollars?:string|number, recurring_donation:boolean}):Promise<unknown> {
	const path = donation.recurring_donation ?
		nonprofitsRecurringDonationsPath(app.nonprofit_id) :
		nonprofitsDonationsPath(app.nonprofit_id);
	if(donation.dollars) {
		donation.amount = format.dollarsToCents(donation.dollars);
		delete donation.dollars;
	}
	return request.post(path).set('Content-Type', 'application/json').send( donation).perform()
		// Reset the card form ui
		.then(function(resp) {
			appl.def('card_form', {status: '', error: false});
			return resp.body;
		})
		// Display any errors
		.catch(function(resp) {
			appl.def('card_form', {
				loading: false,
				error: true,
				status: format_err(resp),
				progress_width: '0%',
			});
			throw new Error(resp);
		});
}

