// License: LGPL-3.0-or-later
import type { HouID, HoudiniEvent, IDType} from '../../common';
import type Event from '.';
import type { EventDiscount, Ticket } from '.';
import type { TrxAssignment } from '../Transaction';

export interface TicketPurchase extends TrxAssignment {
  event: IDType | Event;
  event_discount?: IDType | EventDiscount | null;
  object: 'ticket_purchase';
  tickets: Ticket[] | HouID[];
}


export type TicketPurchaseCreated = HoudiniEvent<'ticket_purchase.created', TicketPurchase>;
export type TicketPurchaseUpdated = HoudiniEvent<'ticket_purchase.updated', TicketPurchase>;
export type TicketPurchaseDeleted = HoudiniEvent<'ticket_purchase.deleted', TicketPurchase>;