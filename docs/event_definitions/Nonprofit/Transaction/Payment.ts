// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, HouID, HoudiniEvent } from "../../common";
import type { Subtransaction, TrxDescendent } from ".";

export interface Payment extends HoudiniObject<HouID>, TrxDescendent {
	created: number;
	deleted: boolean;
	fees: Amount;
	gross_amount: Amount;
	net_amount: Amount;
	status: string;
	subtransaction: HouID | Subtransaction;
	type: 'payment';
}

export type PaymentCreated = HoudiniEvent<'payment.created', Payment>;
export type PaymentUpdated = HoudiniEvent<'payment.updated', Payment>;
export type PaymentDeleted = HoudiniEvent<'payment.deleted', Payment>;

