/* eslint-disable */
import { IdType, HoudiniObject, HoudiniEvent } from './common';
import Nonprofit from './Nonprofit';
import User  from "./User";

export default interface UserRole extends HoudiniObject {
	id: IdType;
	name: string;
	nonprofit: IdType | Nonprofit;
	object: "role";
	user: IdType | User;
}


export type UserRoleCreated = HoudiniEvent<'user_role.created', UserRole>
export type UserRoleUpdated = HoudiniEvent<'user_role.updated', UserRole>
export type UserRoleDeleted = HoudiniEvent<'user_role.deleted', UserRole>