// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonOfflineTransactionPayment } from '.';
import type { PaymentAsId } from "..";

export interface ChargeAsId extends PaymentAsId {
	object: 'offline_transaction_charge';
}

export type Charge = CommonOfflineTransactionPayment & ChargeAsId;

export type ChargeCreated = HoudiniEvent<'offline_transaction_charge.created', Charge>;
export type ChargeUpdated = HoudiniEvent<'offline_transaction_charge.updated', Charge>;
export type ChargeDeleted = HoudiniEvent<'offline_transaction_charge.deleted', Charge>;
