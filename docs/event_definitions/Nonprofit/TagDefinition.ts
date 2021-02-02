// License: LGPL-3.0-or-later

import type { HoudiniEvent, HoudiniObject, IdType } from "../common";
import type Nonprofit from './';

export interface TagDefinition extends HoudiniObject {
	deleted: boolean;
	name: string;
	nonprofit: IdType | Nonprofit;
	object: 'tag_definition';
}

/** POST /nonprofits/:id/tag_definitions */
export interface CreateTagDefinition {
	name: string;
}

export type TagMasterCreated = HoudiniEvent<'tag_definition.created', TagDefinition>;

export type TagMasterDeleted = HoudiniEvent<'tag_definition.deleted', TagDefinition>;