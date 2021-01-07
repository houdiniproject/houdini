/* eslint-disable */
import { IdType, HoudiniObject, HoudiniEvent } from '../../common';
import  Nonprofit  from '../';
import Address, { CreateSupporterAddress} from "./Address";
import { TagMaster } from './Tag';

/**
 * @description An individuals
 * @date 2020-11-16
 * @export
 * @interface Supporter
 */
export default interface Supporter extends HoudiniObject {
	id: IdType;
	name?: string;
	primary_address?: IdType | Address;
	title: string;
	organization: string;
	object: 'supporter';
	email?: string;
	nonprofit: IdType | Nonprofit;
	deleted?: boolean;
	merged_into?: IdType | Supporter
	merged_on?: Date

	tags?: IdType[]|TagMaster[]
}

/**
 * @description POST /api/nonprofits/{nonprofitId}/supporters
 * @date 2020-11-16
 * @export
 * @interface CreateSupporter
 */
export interface CreateSupporter {
	name: string;
	email: string,
	title: string;
	organization?: string;
	primary_address?: CreateSupporterAddress;
	tags?: IdType[]
}



export type SupporterCreated = HoudiniEvent<'supporter.created', Supporter>

export type SupporterUpdated = HoudiniEvent<'supporter.updated', Supporter>

export type SupporterDeleted = HoudiniEvent<'supporter.deleted', Supporter>
	

