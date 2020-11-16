/* eslint-disable @typescript-eslint/member-ordering */

/* eslint-disable */

import type {IdType, FlexibleAmount, HoudiniObject, Logo} from '../common';

export default interface Nonprofit extends HoudiniObject {
	id: IdType;
	location: {
		city: string;
		country: string;
		postal_code: string;
		state_code: string;
	};
	name: string;
	timezone: string;
	logo: Logo;
	url: string;
	tagline: string;
	phone: string;
	email: string;
	currency: string;
	brand_color: string;
	object: "nonprofit";
}

export interface CreateNonprofit {
	location?: {
		city?: string;
		country?: string;
		postal_code?: string;
		state_code?: string;
	};
	timezone?: string;
	logo?: string
	name: string;
}

export interface UpdateNonprofit {
	location: {
		city: string;
		country: string;
		postal_code: string;
		state_code: string;
	}

	name: string;
}


export type CreateTransactionItem = CreateDonation | CreateTicketOrder | CreateCampaignGiftPurchase

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






