// License: LGPL-3.0-or-later
import type { IDType, HoudiniObject, Amount, HoudiniEvent } from '../../common';
import type Nonprofit from '..';
import type Event from '.';
import type { TicketLevel } from './TicketLevel';


type DiscountType = { percent: number } | { amount: Amount };
/**
 * Describes an EventDiscount (shell)
 */
export interface EventDiscount extends HoudiniObject {
  code: string;
  discount: DiscountType;
  event: IDType | Event;
  nonprofit: IDType | Nonprofit;
  object: "event_discount";
  ticket_levels: IDType[] | TicketLevel[];
}

export type EventDiscountCreated = HoudiniEvent<'event_discount.created', EventDiscount>;
export type EventDiscountlUpdated = HoudiniEvent<'event_discount.updated', EventDiscount>;
export type EventDiscountDeleted = HoudiniEvent<'event_discount.deleted', EventDiscount>;