/* eslint-disable */

export type IdType = number;

export type Amount = {valueInCents: string, currency: string}
export type FlexibleAmount =  Amount | string | number

export interface HoudiniObject {
	id: IdType;
	object: string
}

export interface HoudiniEvent<EventType extends string, DataObject extends HoudiniObject> {
	id: IdType;
	object: 'event'
	type: EventType
	data: {
		object: DataObject
	}
}

export type Logo = string;

export type Recurrence = {};