/* eslint-disable */

import { IdType, HoudiniObject, HoudiniEvent } from '../../common';

export interface Metrics extends HoudiniObject {
	id: IdType;
	name: string;
	event: IdType | Event;
	ticket_levels: [{
		
	}]
	object: "event_metrics";
}


export type EventMetricsUpdated = HoudiniEvent<'event_metrics.updated', Metrics>;