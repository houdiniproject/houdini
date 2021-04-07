// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonOfflineTransactionPayment } from '.';

export interface Charge extends CommonOfflineTransactionPayment {
	object: 'offline_transaction_charge';
}

export type ChargeCreated = HoudiniEvent<'offline_transaction_charge.created', Charge>;
export type ChargeUpdated = HoudiniEvent<'offline_transaction_charge.updated', Charge>;
export type ChargeDeleted = HoudiniEvent<'offline_transaction_charge.deleted', Charge>;
