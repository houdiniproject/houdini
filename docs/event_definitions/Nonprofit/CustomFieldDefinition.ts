// License: LGPL-3.0-or-later

import type { HoudiniEvent, HoudiniObject, IdType } from "../common";
import type Nonprofit from '.';

export interface CustomFieldDefinition extends HoudiniObject {
	deleted: boolean;
	name: string;
	nonprofit: IdType | Nonprofit;
	object: 'custom_field_definition';
}


export type CustomFieldDefinitionCreated = HoudiniEvent<'custom_field_definition.created', TagDefinition>;

export type CustomFieldDefinitionDeleted = HoudiniEvent<'custom_field_definition.deleted', TagDefinition>;