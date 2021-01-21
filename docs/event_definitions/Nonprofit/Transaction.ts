// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IdType, UuidType } from "../common";
import type Nonprofit from './';


export interface Transaction extends HoudiniObject<UuidType> {
  amount: Amount;
	nonprofit: IdType | Nonprofit;
	object: 'transaction';
}
