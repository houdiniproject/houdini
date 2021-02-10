// License: LGPL-3.0-or-later
import type { HouID, HoudiniObject, HoudiniEvent, Amount, IDType} from '../../common';
import type Nonprofit from '..';
import type Event from '.';
import type { TicketLevel , TicketPurchase} from '.';
import type Supporter from '../Supporter';

export interface Ticket extends HoudiniObject<HouID> {
  amount: Amount;
  checked_in: boolean;
  deleted: boolean;
  event: IDType | Event;
  nonprofit: IDType | Nonprofit;
  note: string;
  object: 'ticket';
  supporter: IDType | Supporter;
  ticket_level: IDType | TicketLevel;
  ticket_purchase: HouID | TicketPurchase;
}

export type TicketCreated = HoudiniEvent<'ticket.created', Ticket>;
export type TicketUpdated = HoudiniEvent<'ticket.updated', Ticket>;
export type TicketDeleted = HoudiniEvent<'ticket.deleted', Ticket>;