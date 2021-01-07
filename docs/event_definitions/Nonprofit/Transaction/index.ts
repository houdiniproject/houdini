/* eslint-disable */
import { IdType, Amount, HoudiniObject, FlexibleAmount } from '../../common';
import Supporter from '../Supporter';
import Nonprofit from '../';


export default interface Transaction extends HoudiniObject {
	id: IdType;
	nonprofit: IdType | Nonprofit;
	supporter: IdType | Supporter;
	status: "created" | "waiting" | "failed" | "completed";
	
	amount: Amount;
	netAmount: Amount;
	disputes: 
	refunds:
	

}

export interface CreateTransaction {
	supporter: {
		email: string
		name: string
		title: string
		organization:string
	}


	items?: TransactionItem[]
	

	
	amount: FlexibleAmount

  recurring_template: {}

}




interface CreateTicketOrder {
	amount: FlexibleAmount,
	event: IdType
	tickets: {}

}

interface CreateCampaignGiftPurchase {
	amount: FlexibleAmount,
	campaign: IdType,
	giftOptions: {}
}
