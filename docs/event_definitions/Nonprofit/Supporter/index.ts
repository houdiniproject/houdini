// License: LGPL-3.0-or-later
import type { IdType, HoudiniObject } from '../../common';
import type Nonprofit from '../';
import type { SupporterAddress } from './SupporterAddress';

export default interface Supporter extends HoudiniObject {
  anonymous: boolean;
  deleted: boolean;
  email: string;
  merged_into: IdType | Supporter | null;
	name: string;
  nonprofit: IdType | Nonprofit;
  object: "supporter";
  organization: string;
  phone: string;
  supporter_addresses: IdType[] | SupporterAddress[];
}

export * from './SupporterNote';
export * from './SupporterAddress';
