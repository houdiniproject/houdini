/* eslint-disable */

import { IdType, HoudiniObject, HoudiniEvent, Amount, FlexibleAmount} from '../../common';
import Event from './'

export interface TicketLevel extends HoudiniObject {
	id: IdType;
	name: string;
	event: IdType | Event;
	amount: Amount
	limit?: number;
	object: "ticket_level";
}


export interface CreateTicketLevel {
	name: string;
	amount: FlexibleAmount;
	limit?:number;
	adminOnly: boolean;
}


export type TicketLevelCreated = HoudiniEvent<'ticket_level.created', TicketLevel>;