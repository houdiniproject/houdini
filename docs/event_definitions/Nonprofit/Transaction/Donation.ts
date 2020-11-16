/* eslint-disable */
import { IdType, HoudiniObject, FlexibleAmount } from '../../common';
import  Transaction  from './';


export interface Donation extends HoudiniObject {
	id: IdType;
	object: "donation";

	transaction: IdType | Transaction;

	dedication?: Dedication
	designation?: string
}

interface CreateDonation {
	type: 'donation',
	amount: FlexibleAmount,
  
	
}


interface Dedication {
	
}
