// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonOfflineTransactionPayment } from '.';

export interface Dispute extends CommonOfflineTransactionPayment {
	object: 'offline_transaction_dispute';
}

export type DisputeCreated = HoudiniEvent<'offline_transaction_dispute.created', Dispute>;
export type DisputeUpdated = HoudiniEvent<'offline_transaction_dispute.updated', Dispute>;
export type DisputeDeleted = HoudiniEvent<'offline_transaction_dispute.deleted', Dispute>;