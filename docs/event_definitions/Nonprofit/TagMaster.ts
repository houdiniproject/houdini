// License: LGPL-3.0-or-later

import type { HoudiniEvent, HoudiniObject, IdType } from "../common";
import type Nonprofit from './';

export interface TagMaster extends HoudiniObject {
	deleted: boolean;
	name: string;
	nonprofit: IdType | Nonprofit;
	object: 'tag_master';
}

/** POST /nonprofits/:id/tag_masters */
export interface CreateTagMaster {
	name: string;
}

export type TagMasterCreated = HoudiniEvent<'tag_master.created', TagMaster>;

export type TagMasterDeleted = HoudiniEvent<'tag_master.deleted', TagMaster>;