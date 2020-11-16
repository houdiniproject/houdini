/* eslint-disable */
import { IdType, HoudiniObject } from '../../common';
import { Transaction } from './Transaction';


export interface TicketOrder extends HoudiniObject {
	id: IdType;
	object: "ticket_order";

	transaction: IdType | Transaction;
	
}
