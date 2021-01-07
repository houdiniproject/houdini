/* eslint-disable */
import Nonprofit from '..'
import { IdType, HoudiniObject, Amount, HoudiniEvent, FlexibleAmount } from '../../common';
import { TicketLevel } from '../Event/TicketLevel';
import Supporter from '../Supporter';

export interface TicketOrder extends HoudiniObject {
	id: IdType;
	object: "ticket_order";
	event: IdType | Event;
	nonprofit: IdType | Nonprofit;
	supporter: IdType | Supporter;
	/**
	 * the money that is associated with an online payment, such as a credit card purchase
	 */
	amount: Amount
	
	/** the money that is associated with an offline payment */
	amountAsOfflinePayment:Amount

	discountCode: string|null
	
	/**
	 * One ticket level for each ticket that they would like to buy of that level
	 */
	tickets: TicketLevel[];
	
}

export type TicketOrderCreated = HoudiniEvent<'ticket_order.created', TicketOrder>;


export interface CreateTicketOrder extends HoudiniObject {
	object: "ticket_order"
	
	supporter: IdType
	/**
	 * the money that is associated with an online payment, such as a credit card purchase
	 */
	amount: FlexibleAmount
	
	/** the money that is associated with an offline payment */
	amountAsOfflinePayment:FlexibleAmount


	discountCode: string|null
	/**
	 * One ticket level for each ticket that they would like to buy of that level
	 */
	tickets: TicketLevel[];
}
