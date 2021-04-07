// License: LGPL-3.0-or-later
import type { HouID, HoudiniObject, HoudiniEvent, Amount, IDType} from '../../common';
import type Event from '.';
import type { TicketLevel , TicketPurchase} from '.';
import { TrxDescendent } from '../Transaction';

export interface Ticket extends HoudiniObject<HouID>, TrxDescendent {
  amount: Amount;
  checked_in: boolean;
  deleted: boolean;
  event: IDType | Event;
  note: string;
  object: 'ticket';
  ticket_level: IDType | TicketLevel;
  ticket_purchase: HouID | TicketPurchase;
}

export type TicketCreated = HoudiniEvent<'ticket.created', Ticket>;
export type TicketUpdated = HoudiniEvent<'ticket.updated', Ticket>;
export type TicketDeleted = HoudiniEvent<'ticket.deleted', Ticket>;