// License: LGPL-3.0-or-later
import type { IdType, HoudiniObject } from '../../common';
import type Nonprofit from '..';
import type Event from '.';
import type { TicketLevel } from './TicketLevel';

/**
 * Describes an EventDiscount (shell)
 */
export interface EventDiscount extends HoudiniObject {
  event: IdType | Event;
  nonprofit: IdType | Nonprofit;
  object: "event_discount";
  ticket_levels: IdType[] | TicketLevel[];
}