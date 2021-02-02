// License: LGPL-3.0-or-later
import type { HouID, HoudiniObject, HoudiniEvent, Amount, IdType} from '../../common';
import type Nonprofit from '..';
import type Event from '.';
import type { EventDiscount, Ticket } from '.';
import Supporter from '../Supporter';
import { Transaction } from '../Supporter';


export interface TicketPurchase extends HoudiniObject<HouID> {
  amount: Amount;
  event: IdType | Event;
  event_discount?: IdType | EventDiscount | null;
  nonprofit: IdType | Nonprofit;
  object: 'ticket_purchase';
  supporter: IdType | Supporter;
  tickets: Ticket[] | HouID[];
  transaction: HouID | Transaction;
}


export type TicketPurchaseCreated = HoudiniEvent<'ticket_purchase.created', TicketPurchase>;
export type TicketPurchaseUpdated = HoudiniEvent<'ticket_purchase.updated', TicketPurchase>;
export type TicketPurchaseDeleted = HoudiniEvent<'ticket_purchase.deleted', TicketPurchase>;