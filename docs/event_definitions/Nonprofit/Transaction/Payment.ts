// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IDType, HouID } from "../../common";
import type Nonprofit from '../';
import type Supporter from "../Supporter";
import type Transaction from './';


export interface Payment extends HoudiniObject<HouID> {
  amount: Amount;
	nonprofit: IDType | Nonprofit;
  object: 'payment';
	supporter: IDType | Supporter;
  transaction: HouID | Transaction;

}

