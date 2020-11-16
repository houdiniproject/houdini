/* eslint-disable */

import { IdType, HoudiniObject, Logo, HoudiniEvent } from '../../common';
import Nonprofit  from '../../Nonprofit';

export interface Campaign extends HoudiniObject {
	id: IdType;
	name: string;
	nonprofit: IdType | Nonprofit;
	start_date: Date;
	end_date: Date;
	logo: Logo;
	parent_campaign?: IdType|Campaign;
	child_campaigns?: IdType[]|Campaign[];
	object: "campaign";
}

export type CampaignCreated = HoudiniEvent<'campaign.created', Campaign>
export type CampaignUpdated = HoudiniEvent<'campaign.updated', Campaign>
export type CampaignDeleted = HoudiniEvent<'campaign.deleted', Campaign>