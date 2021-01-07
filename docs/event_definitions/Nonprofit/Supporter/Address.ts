/* eslint-disable */
import { IdType, HoudiniObject, HoudiniEvent } from '../../common';
import  Supporter  from '.';


export default interface Address extends HoudiniObject {
	city: string;
	country: string;
	address: string;
	postalCode: string;
	stateCode: string;
	supporter: IdType | Supporter;
	object: 'supporter_address';
}

export interface CreateSupporterAddress {
	address: string;
	city: string;
	country: string;
	postalCode: string;
	stateCode: string;
}


export type SupporterAddressCreated = HoudiniEvent<'supporter_address.created', Address>

export type SupporterAddressUpdated = HoudiniEvent<'supporter_address.updated', Address>

export type SupporterAddressDeleted = HoudiniEvent<'supporter_address.deleted', Address>