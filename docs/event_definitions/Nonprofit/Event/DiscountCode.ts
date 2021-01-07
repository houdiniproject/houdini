import { HoudiniObject, FlexibleAmount, IdType, HoudiniEvent } from "../../common";
import Nonprofit from '..';



export interface DiscountCode extends HoudiniObject, CreateDiscountCode {
	event: IdType | Event;
	id: IdType;
	nonprofit: IdType | Nonprofit;
	object: 'discount_code';
}

type DiscountDetails =  { percent: number|string } | {flatAmount: FlexibleAmount}

export interface CreateDiscountCode {
	code: string;
	description: string;
	discount: DiscountDetails;
}

export type DiscountCodeCreated = HoudiniEvent<'discount_code.created', DiscountCode>