// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../../common";
import type { CommonOfflineTransactionPayment } from '.';
import type { PaymentAsId } from "..";

export interface RefundAsId extends PaymentAsId {
	object: 'offline_transaction_refund';
}

export type Refund = CommonOfflineTransactionPayment & RefundAsId;

export type RefundCreated = HoudiniEvent<'offline_transaction_refund.created', Refund>;
export type RefundUpdated = HoudiniEvent<'offline_transaction_refund.updated', Refund>;
export type RefundDeleted = HoudiniEvent<'offline_transaction_refund.deleted', Refund>;