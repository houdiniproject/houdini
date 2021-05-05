// License: LGPL-3.0-or-later
import type { HouID, HoudiniEvent } from "../../../common";
import type { Payment, Subtransaction} from "..";
import type { Charge, Refund, Dispute, ChargeAsId, DisputeAsId, RefundAsId } from '.';

export interface CommonOfflineTransactionPayment extends Payment {
	// The kind of offline charge. Could be cash, check or something else
	// NOT implemented yet
	kind: string|null;
	// NOT implemented yet
	// the ID related to the kind. As example, you could put a check number here.
	kind_id: string|null;
	subtransaction: HouID | OfflineTransaction;
}

export default interface OfflineTransaction extends Subtransaction {
	deleted: boolean;
	object: 'offline_transaction';
	payments: (ChargeAsId|RefundAsId|DisputeAsId)[]| (Charge|Refund|Dispute)[];
}

export type OfflineTransactionCreated = HoudiniEvent<'offline_transaction.created', OfflineTransaction>;
export type OfflineTransactionUpdated = HoudiniEvent<'offline_transaction.updated', OfflineTransaction>;
export type OfflineTransactionRefunded = HoudiniEvent<'offline_transaction.refunded', OfflineTransaction>;
export type OfflineTransactionDisputed = HoudiniEvent<'offline_transaction.disputed', OfflineTransaction>;
export type OfflineTransactionDeleted = HoudiniEvent<'offline_transaction.deleted', OfflineTransaction>;

export * from './Charge';
export * from './Dispute';
export * from './Refund';