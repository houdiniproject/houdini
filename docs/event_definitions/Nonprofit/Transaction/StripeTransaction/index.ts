// License: LGPL-3.0-or-later
import type { Subtransaction} from "..";

export default interface StripeTransaction extends Subtransaction {
	object: 'stripe_transaction';
}