// License: LGPL-3.0-or-later
import type { IdType, HoudiniObject } from '../../common';
import type Nonprofit from '../';

export default interface Supporter extends HoudiniObject {
  deleted: boolean;
  email: string;
	name: string;
  nonprofit: IdType | Nonprofit;
  object: "supporter";
  organization: string;
}

export * from './SupporterNote';
