// License: LGPL-3.0-or-later
import type { Amount, HoudiniObject, IDType, HouID, HoudiniEvent } from "../../common";
import type Nonprofit from '../';
import type Supporter from "../Supporter";
import type Transaction from './';

interface Dedication {
  contact?: {
    address?: string;
    email?: string;
    phone?: string;
  };
  name: string;
  note?: string;
  type: 'honor' | 'memory';
}

export interface Donation extends HoudiniObject<HouID> {
  amount: Amount;
  dedication?: Dedication | null;
  designation?: string | null;
  nonprofit: IDType | Nonprofit;
  object: 'donation';
  supporter: IDType | Supporter;
  transaction: HouID | Transaction;
}

export type DonationCreated = HoudiniEvent<'donation.created', Donation>;
export type DonationUpdated = HoudiniEvent<'donation.updated', Donation>;
export type DonationDeleted = HoudiniEvent<'donation.deleted', Donation>;
