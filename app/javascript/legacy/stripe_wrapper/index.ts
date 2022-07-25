// License: LGPL-3.0-or-later
import jQuery from 'jquery';
import type { Token} from '@stripe/stripe-js';
/**
 * A wrapper for replicating Stripe.js v2's tokenizing features
 * with a compatible API. It allows a service provider to use fully free software
 * for Stripe integration. Whether that meets your needs is up to you :)
 *
 * To use it set the `payment_provider.stripe_proprietary_v2_js` to `false`
 * (which is the default in settings)
 */
class Stripe {
	bankAccount: TokenizerWrapper;
	card: TokenizerWrapper;


	setPublishableKey(key: string): void {

		this.card = new TokenizerWrapper('card', key);
		this.bankAccount = new TokenizerWrapper('bank_account', key);
	}
}

class TokenizerWrapper {
	constructor(private inner_field_name: string, private key: string) {
		Object.bind(this.createToken);
	}

	createToken(outer_obj: unknown, callback: (status: number, data: Token) => void) {
		const auth = 'Bearer ' + this.key;


		const inner_field_name = this.inner_field_name;

		const obj = {} as {[inner_field_name:string]: unknown};

		obj[inner_field_name] = outer_obj;

		jQuery.ajax('https://api.stripe.com/v1/tokens', {
			headers: {
				'Authorization': auth,
				'Accept': 'application/json',
				'Content-Type': 'application/x-www-form-urlencoded',
			},
			method: 'POST',
			data: obj,
		}).done((data, _textStatus, jqXHR) => {
			callback(jqXHR.status, data);
		}).fail((jqXHR, _textStatus, _errorThrown) => {
			callback(jqXHR.status, jqXHR.responseJSON);
		});
	}
}

type GlobalAndStripeType = typeof global & { Stripe: Stripe };

const globalWithStripe = global as GlobalAndStripeType;

globalWithStripe.Stripe = new Stripe();