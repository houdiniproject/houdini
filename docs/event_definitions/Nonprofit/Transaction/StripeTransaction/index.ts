// License: LGPL-3.0-or-later
import type { HouID, HoudiniEvent } from "../../../common";
import type { Payment, Subtransaction} from "..";

export interface CommonStripeTransactionPayment extends Payment {
	stripe_id: string;
	subtransaction: HouID | StripeTransaction;
}

export default interface StripeTransaction extends Subtransaction {
	object: 'stripe_transaction';
}

export type StripeTransactionCreated = HoudiniEvent<'stripe_transaction.created', StripeTransaction>;
export type StripeTransactionUpdated = HoudiniEvent<'stripe_transaction.updated', StripeTransaction>;
export type StripeTransactionRefunded = HoudiniEvent<'stripe_transaction.refunded', StripeTransaction>;
export type StripeTransactionDisputed = HoudiniEvent<'stripe_transaction.disputed', StripeTransaction>;
export type StripeTransactionDeleted = HoudiniEvent<'stripe_transaction.deleted', StripeTransaction>;

export * from './Charge';