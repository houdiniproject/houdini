// License: LGPL-3.0-or-later
import type { IDType, HoudiniObject, HoudiniEvent } from '../../common';
import type Nonprofit from '..';
import type Supporter from '.';

export interface SupporterAddress extends HoudiniObject {
  address: string;
  city: string;
  country: string;
  deleted: boolean;
  nonprofit: IDType | Nonprofit;
  object: "supporter_address";
  state_code: string;
  supporter: IDType | Supporter;
  zip_code: string;
}

export type SupporterAddressCreated = HoudiniEvent<'supporter_address.created', SupporterAddress>;
export type SupporterAddressUpdated = HoudiniEvent<'supporter_address.updated', SupporterAddress>;
export type SupporterAddressDeleted = HoudiniEvent<'supporter_address.deleted', SupporterAddress>;