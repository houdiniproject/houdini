import { Campaign } from './nonprofit/Campaign';
/* eslint-disable */

import { IdType, HoudiniObject, Logo, HoudiniEvent } from '../../common';


export interface Page extends HoudiniObject {
	id: IdType;
	name: string;
	campaign: IdType | Campaign;
	logo: Logo;
	object: "campaign_page";
	public: boolean
}

export type PageUpdated = HoudiniEvent<'campaign_page.updated', Page>;
