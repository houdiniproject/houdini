// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IdType, HouID } from "../common";
import type Nonprofit from './';


export interface Transaction extends HoudiniObject<HouID> {
  amount: Amount;
	nonprofit: IdType | Nonprofit;
	object: 'transaction';
}
