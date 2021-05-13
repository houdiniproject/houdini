// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonStripeTransactionPayment } from '.';
import type { PaymentAsId } from "..";

export interface RefundAsId extends PaymentAsId {
	object: 'stripe_transaction_refund';
}

export type Refund = CommonStripeTransactionPayment & RefundAsId;

export type RefundCreated = HoudiniEvent<'stripe_transaction_refund.created', Refund>;
export type RefundUpdated = HoudiniEvent<'stripe_transaction_refund.updated', Refund>;
export type RefundDeleted = HoudiniEvent<'stripe_transaction_refund.deleted', Refund>;