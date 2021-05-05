// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonStripeTransactionPayment } from ".";
import type { PaymentAsId } from "..";

export interface ChargeAsId extends PaymentAsId {
	object: 'stripe_transaction_charge';
}

export type Charge = CommonStripeTransactionPayment & ChargeAsId;

export type ChargeCreated = HoudiniEvent<'stripe_transaction_charge.created', Charge>;
export type ChargeUpdated = HoudiniEvent<'stripe_transaction_charge.updated', Charge>;
export type ChargeDeleted = HoudiniEvent<'stripe_transaction_charge.deleted', Charge>;
