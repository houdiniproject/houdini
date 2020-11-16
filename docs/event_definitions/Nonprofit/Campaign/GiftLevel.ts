/* eslint-disable */

import { IdType, HoudiniObject, Recurrence, Amount, HoudiniEvent } from '../../common';
import { Nonprofit } from '../../Nonprofit';

export interface GiftLevel extends HoudiniObject {
	id: IdType;
	name: string;
	nonprofit: IdType | Nonprofit;
	value: {amount:Amount, recurrence:Recurrence}
	object: "campaign_gift_level";
}

export type GiftLevelCreated = HoudiniEvent<'campaign_gift_level.created', GiftLevel>
export type GiftLevelUpdated = HoudiniEvent<'campaign_gift_level.updated', GiftLevel>
export type GiftLevelDeleted = HoudiniEvent<'campaign_gift_level.deleted', GiftLevel>