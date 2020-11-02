/* eslint-disable @typescript-eslint/member-ordering */

/* eslint-disable */

type IdType = number;

type Amount = {valueInCents: string, currency: string}
type FlexibleAmount =  Amount | string | number

interface Nonprofit {
	id: IdType;
	location: {
		city: string;
		country: string;
		postal_code: string;
		state_code: string;
	};
	name: string;
	object: "nonprofit";
}

interface CreateNonprofit {
	location: {
		city: string;
		country: string;
		postal_code: string;
		state_code: string;
	};
	name: string;
}

interface User {
	email: string;
	id: IdType;
	object: "user";
}

interface UserRole {
	id: IdType;
	name: string;
	nonprofit: IdType | Nonprofit;
	object: "role";
	user: IdType | User;
}

interface Campaign {
	//campaign_options: {};
	id: IdType;
	name: string;
	nonprofit: IdType | Nonprofit;
	object: "campaign";
}

interface GiftOption {
	object: "gift_option";
}

interface Event {
	id: IdType;
	nonprofit: IdType | Nonprofit;
	object: "event";

}

interface TicketOrder {
	id: IdType;
	object: "ticket_order";
}

interface Supporter {
	id: IdType
	name: string
	primaryAddress: IdType | SupporterAddress
	title: string
	organization: string
	object: 'supporter'
	email: string
}

interface SupporterAddress {
	city: string;
	country: string;
	id: IdType
	postalCode: string;
	stateCode: string;
}


interface Transaction {
	id: IdType;
	nonprofit: IdType | Nonprofit
	supporter: IdType | Supporter
	status: "created"|"waiting"|"failed"|"completed"
	items:CreateTransactionItem
	amount: Amount
	recurrence: 
	paymentMethod: 
}

interface StripePaymentMethod {

}

type CreateTransactionItem = CreateDonation | CreateTicketOrder | CreateCampaignGiftPurchase

interface CreateTransaction {
	supporter: {
		email: string
		name: string
		title: string
		organization:string
	}


	items?: CreateTransactionItem[]
	

	
	amount: FlexibleAmount

  paymentData: 

}

interface StripePaymentData {
	paymentProvider:'stripe'
	token:
}





interface CreateDonation {
	type: 'donation',
	amount: FlexibleAmount,
  
	residual: boolean
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
