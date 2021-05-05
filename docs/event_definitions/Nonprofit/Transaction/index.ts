// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IDType, HouID, HoudiniEvent, PolymorphicID } from "../../common";
import type Nonprofit from '../';
import type Supporter from "../Supporter";
import type { Payment, PaymentAsId } from "./Payment";
import type { SubtransactionAsId, Subtransaction } from "./Subtransaction";

/**
 * Every descendent of a Transaction object will have the following three fields
 */
export interface TrxDescendent {
	/**
	 * The nonprofit of the transaction is assigned to.
	 */
	nonprofit: IDType | Nonprofit;
	/**
	 * The supporter of the transaction
	 */
	supporter: IDType | Supporter;
	/**
	 * The transaction itself
	 */
  transaction: HouID | Transaction;
}

/**
 * Every transaction assignment, including Donation, TicketPurchase, CampaignGiftPurchase
 * must have an amount and the type 'trx_assignment' set.
 */
export interface TrxAssignment extends TrxAssignmentAsId, TrxDescendent {
	amount: Amount;
}

export interface TrxAssignmentAsId extends PolymorphicID<HouID> {
	type: 'trx_assignment';
}

export default interface Transaction extends HoudiniObject<HouID> {
  amount: Amount;
	created: number;
	nonprofit: IDType | Nonprofit;
	object: 'transaction';
	payments: PaymentAsId[] | Payment[];
	subtransaction: SubtransactionAsId | Subtransaction;
	supporter: IDType | Supporter;
	transaction_assignments: TrxAssignmentAsId[] | TrxAssignment[];
}

export type TransactionCreated = HoudiniEvent<'transaction.created', Transaction>;
export type TransactionUpdated = HoudiniEvent<'transaction.updated', Transaction>;
export type TransactionRefunded = HoudiniEvent<'transaction.refunded', Transaction>;
export type TransactionDisputed = HoudiniEvent<'transaction.disputed', Transaction>;
export type TransactionDeleted = HoudiniEvent<'transaction.deleted', Transaction>;

export * from './Payment';
export * from './Donation';
export * from './Subtransaction';
export * as OfflineTransactionTypes from './OfflineTransaction';
export {default as OfflineTransaction} from './OfflineTransaction';
