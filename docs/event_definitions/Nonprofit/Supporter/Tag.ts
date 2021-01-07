/* eslint-disable @typescript-eslint/member-ordering */
import { HoudiniEvent, HoudiniObject, IdType } from "../../common";
import Nonprofit from '..';



export interface TagMaster extends HoudiniObject {
	object: 'tag_master';
	nonprofit: IdType | Nonprofit;
	value: string;
}


export interface CreateTagMaster {
	value: string;
}


export type TagMasterCreated = HoudiniEvent<'tag_master.created', TagMaster>;