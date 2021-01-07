/* eslint-disable */
import { IdType, HoudiniObject } from '../../common';
import  Transaction  from '.';


export interface CampaignGiftPurchase extends HoudiniObject {
	id: IdType;
	object: "campaign_gift_purchase";

	gifts: []

	dedication?: Dedication
	designation?: string
}


interface Dedication {
	
}
