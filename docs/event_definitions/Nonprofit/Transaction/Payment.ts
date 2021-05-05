// License: LGPL-3.0-or-later
import type { Amount, HouID, HoudiniEvent, PolymorphicID } from "../../common";
import type { Subtransaction, TrxDescendent } from ".";

export interface PaymentAsId extends PolymorphicID<HouID> {
	type: 'payment';
}

export interface Payment extends PaymentAsId, TrxDescendent {
	created: number;
	deleted: boolean;
	fee_total: Amount;
	gross_amount: Amount;
	net_amount: Amount;
	status: string;
	subtransaction: HouID | Subtransaction;
	type: 'payment';
}

export type PaymentCreated = HoudiniEvent<'payment.created', Payment>;
export type PaymentUpdated = HoudiniEvent<'payment.updated', Payment>;
export type PaymentDeleted = HoudiniEvent<'payment.deleted', Payment>;

