// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonStripeTransactionPayment } from '.';
import type { PaymentAsId } from "..";


export interface DisputeAsId extends PaymentAsId {
	object: 'stripe_transaction_dispute';
}
export type Dispute = CommonStripeTransactionPayment & DisputeAsId;

export type DisputeCreated = HoudiniEvent<'stripe_transaction_dispute.created', Dispute>;
export type DisputeUpdated = HoudiniEvent<'stripe_transaction_dispute.updated', Dispute>;
export type DisputeDeleted = HoudiniEvent<'stripe_transaction_dispute.deleted', Dispute>;