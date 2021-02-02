// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IdType, HouID } from "../../common";
import type Nonprofit from '../';
import type Supporter from "../Supporter";
import type Transaction from './';


export interface Payment extends HoudiniObject<HouID> {
  amount: Amount;
	nonprofit: IdType | Nonprofit;
  object: 'payment';
	supporter: IdType | Supporter;
  transaction: HouID | Transaction;

}

