// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IdType, HouID } from "../../common";
import type Nonprofit from '..';
import type Supporter from ".";

/**
 * Represents a transaction made by a supporter
 */
export interface Transaction extends HoudiniObject<HouID> {
	amount: Amount;
	nonprofit: IdType | Nonprofit;
	object: 'transaction';
	payment_methods: Array<unknown>;
	payments:  Array<unknown>;
	status: string;
	supporter: IdType | Supporter;
	transaction_assignments:  Array<unknown>;
}
