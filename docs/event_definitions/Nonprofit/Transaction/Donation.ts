// License: LGPL-3.0-or-later
import type { HoudiniEvent } from "../../common";
import type { TrxAssignment } from './';

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

export interface Donation extends TrxAssignment {
  dedication?: Dedication | null;
  designation?: string | null;
  object: 'donation';
}

export type DonationCreated = HoudiniEvent<'donation.created', Donation>;
export type DonationUpdated = HoudiniEvent<'donation.updated', Donation>;
export type DonationDeleted = HoudiniEvent<'donation.deleted', Donation>;
