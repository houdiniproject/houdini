/* eslint-disable */
import { IdType, HoudiniObject, HoudiniEvent } from './common';
import { Campaign } from '.';
import { Nonprofit } from '../../Nonprofit';

export interface nCampaigMetrics extends HoudiniObject {
	id: IdType;
	campaign: IdType | Campaign;
	object: "campaign_metrics";
}


export type CampaignMetricsUpdated = HoudiniEvent<'campaign_metrics.updated', CampaignMetrics>;
