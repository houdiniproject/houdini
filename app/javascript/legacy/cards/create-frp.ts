// License: LGPL-3.0-or-later
import flyd from 'flyd';
import { Token } from '@stripe/stripe-js';
import type {Stripe as StripeJS} from '../stripe_wrapper';
declare const Stripe: StripeJS;
// Given an object of card data, return a stream of stripe tokenization responses
export default function createFrp(obj:unknown) : flyd.Stream<Token> {
	const $ = flyd.stream<Token>();
	Stripe.card.createToken(obj, (_status, resp) => $(resp));
	return $;
}

