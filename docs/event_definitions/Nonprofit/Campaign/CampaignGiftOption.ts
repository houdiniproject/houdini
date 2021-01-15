// License: LGPL-3.0-or-later
import type { IdType, HoudiniObject, HoudiniEvent, Amount, RecurrenceRule } from '../../common';
import type Nonprofit from '..';
import type Campaign from '.';

interface OneTimeGiftOptionAmount {
  amount: Amount;
}

interface RecurringGiftOptionAmount {
  amount: Amount;
  recurrence: RecurrenceRule;
}

export interface CampaignGiftOption extends HoudiniObject {
  campaign: IdType | Campaign;
  deleted: boolean;
  description: string;
  gift_option_amount: Array<RecurringGiftOptionAmount | OneTimeGiftOptionAmount>;
  hide_contributions: boolean;
  name: string;
  nonprofit: IdType | Nonprofit;
  object: "campaign_gift_option";
  order: number;
  quantity?: number;
  to_ship: boolean;
}

export type CampaignGiftOptionCreated = HoudiniEvent<'campaign_gift_option.created', CampaignGiftOption>;
export type CampaignGiftOptionUpdated = HoudiniEvent<'campaign_gift_option.updated', CampaignGiftOption>;
export type CampaignGiftOptionDeleted = HoudiniEvent<'campaign_gift_option.deleted', CampaignGiftOption>;