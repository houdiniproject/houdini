// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonOfflineTransactionPayment } from '.';
import type { PaymentAsId } from "..";


export interface DisputeAsId extends PaymentAsId {
	object: 'offline_transaction_dispute';
}
export type Dispute = CommonOfflineTransactionPayment & DisputeAsId;

export type DisputeCreated = HoudiniEvent<'offline_transaction_dispute.created', Dispute>;
export type DisputeUpdated = HoudiniEvent<'offline_transaction_dispute.updated', Dispute>;
export type DisputeDeleted = HoudiniEvent<'offline_transaction_dispute.deleted', Dispute>;