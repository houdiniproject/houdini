// License: LGPL-3.0-or-later
import { IdType, HoudiniObject } from '../../common';
import Nonprofit from '../';

export default interface Event extends HoudiniObject {
  end_date: Date;
	name: string;
  nonprofit: IdType | Nonprofit;
  object: "event";
	start_date: Date;
}

export * from './TicketLevel';
export * from './EventDiscount';