// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IdType, HoudID } from "../common";
import type Nonprofit from './';


export interface Transaction extends HoudiniObject<HoudID> {
  amount: Amount;
	nonprofit: IdType | Nonprofit;
	object: 'transaction';
}
