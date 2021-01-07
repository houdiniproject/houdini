/* eslint-disable */
import { IdType, HoudiniObject, HoudiniEvent } from './common';


export default interface User extends HoudiniObject {
	email: string;
	id: IdType;
	object: "user";
	disabled: boolean;
}

export interface CreateUser {
	email: string;
	password:string;
}


export type UserCreated = HoudiniEvent<'user.created', User>
export type UserUpdated = HoudiniEvent<'user.updated', User>
export type UserDeleted = HoudiniEvent<'user.deleted', User>