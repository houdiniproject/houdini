// License: LGPL-3.0-or-later
import { IdType, HoudiniObject, HoudiniEvent, Amount } from '../../common';
import Nonprofit from '..';
import Event from './';
import { EventDiscount } from './EventDiscount';

/**
 * Describes a single ticket level for an event. Each Ticket is associated with a TicketLevel
 */
export interface TicketLevel extends HoudiniObject {
  /** The cost of one ticket of the given amount */
  amount: Amount;
  /**
   * Who can see and/or buy the ticket. 'everyone' is every visitor, 'admins' means event
   * and nonprofit admins only
   */
  available_to: 'everyone' | 'admins';
  deleted: boolean;
  description: string;
  event: IdType | Event;
  /**
   * at some time, event discounts will be associated with a given ticket level.
   * For now, this returns all of the discounts for the event though.
   */
  event_discounts: IdType[] | EventDiscount[];
  /**
   * the max number of tickets to be sold on this TicketLevel, null means unlimited.
   * If you edit this and decide to lower the limit below the number of tickets currently sold,
   * we don't remove the tickets already there.
   */
  limit?: number;
  /**
   * Nice readable name fo the ticket level
   */
  name: string;
  nonprofit: IdType | Nonprofit;
  object: "ticket_level";
  /** order to be displayed */
  order: number;
}

export type TicketLevelCreated = HoudiniEvent<'ticket_level.created', TicketLevel>;
export type TicketLevelUpdated = HoudiniEvent<'ticket_level.updated', TicketLevel>;
export type TicketLevelDeleted = HoudiniEvent<'ticket_level.deleted', TicketLevel>;