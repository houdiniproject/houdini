/* eslint-disable */

import { IdType, HoudiniObject, HoudiniEvent} from '../../common';
import Event from './'

export interface TicketLevel extends HoudiniObject {
	id: IdType;
	name: string;
	event: IdType | Event;
	
	limit?: number;
	object: "ticket_level";
}


export type TicketLevelCreated = HoudiniEvent<'ticket_level.created', TicketLevel>;