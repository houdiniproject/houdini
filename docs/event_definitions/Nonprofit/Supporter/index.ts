// License: LGPL-3.0-or-later
import type { IDType, HoudiniObject, HoudiniEvent } from '../../common';
import type Nonprofit from '../';
import type { SupporterAddress } from './SupporterAddress';

export default interface Supporter extends HoudiniObject {
  anonymous: boolean;
  deleted: boolean;
  email: string;
  merged_into: IDType | Supporter | null;
	name: string;
  nonprofit: IDType | Nonprofit;
  object: "supporter";
  organization: string;
  phone: string;
  supporter_addresses: IDType[] | SupporterAddress[];
}

export type SupporterCreated = HoudiniEvent<'supporter_address.created', Supporter>;
export type SupporterUpdated = HoudiniEvent<'supporter_address.updated', Supporter>;
export type SupporterDeleted = HoudiniEvent<'supporter_address.deleted', Supporter>;

export * from './SupporterNote';
export * from './SupporterAddress';
export * from './Transaction';
