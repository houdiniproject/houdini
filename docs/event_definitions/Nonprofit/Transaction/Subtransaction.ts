// License: LGPL-3.0-or-later
import type { Amount, HouID, HoudiniEvent, PolymorphicID } from "../../common";
import type {  Payment, PaymentAsId, TrxDescendent } from ".";

export interface SubtransactionAsId extends PolymorphicID<HouID> {
	type: 'subtransaction';
}

export interface Subtransaction extends SubtransactionAsId, TrxDescendent {
	created: number;
	initial_amount: Amount;
	net_amount: Amount;
	payments: PaymentAsId[]|Payment[];
}

export type SubtransactionCreated = HoudiniEvent<'subtransaction.created', Subtransaction>;
export type SubtransactionUpdated = HoudiniEvent<'subtransaction.updated', Subtransaction>;
export type SubtransactionDeleted = HoudiniEvent<'subtransaction.deleted', Subtransaction>;

