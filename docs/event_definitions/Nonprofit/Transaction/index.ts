// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IdType, HouID } from "../../common";
import type Nonprofit from '../';
import type Supporter from "../Supporter";
import type { Payment } from "./Payment";

export default interface Transaction extends HoudiniObject<HouID> {
  amount: Amount;
	nonprofit: IdType | Nonprofit;
	object: 'transaction';
	payments: IdType[] | Payment[];
	status: "not-submitted"|"created" | "waiting-on-supporter" | "failed" | "completed";
	supporter: IdType | Supporter;
	/**
	 * We don't specify more for now
	 */
	transaction_assignments: { id: HouID,object: string  }[];
}

export * from './Payment';
