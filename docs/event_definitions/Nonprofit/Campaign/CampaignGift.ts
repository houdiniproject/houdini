// License: LGPL-3.0-or-later
import type { HouID, HoudiniObject, HoudiniEvent, Amount, IdType} from '../../common';
import type Nonprofit from '..';
import type Campaign from '.';
import type { CampaignGiftPurchase, CampaignGiftOption } from '.';
import type Supporter from '../Supporter';

export interface TransactionAddress {
  address: string;
  city: string;
  country: string;
  state_code: string;
  zip_code: string;
}

export interface CampaignGift extends HoudiniObject<HouID> {
  address?: TransactionAddress;
  amount: Amount;
  campaign: IdType | Campaign;
  campaign_gift_option: IdType | CampaignGiftOption;
  campaign_gift_purchase: IdType | CampaignGiftPurchase;
  deleted: boolean;
  event: IdType | Event;
  nonprofit: IdType | Nonprofit;
  object: 'campaign_gift';
  supporter: IdType | Supporter;
}

export type CampaignGiftCreated = HoudiniEvent<'campaign_gift.created', CampaignGift>;
export type CampaignGiftUpdated = HoudiniEvent<'campaign_gift.updated', CampaignGift>;
export type CampaignGiftDeleted = HoudiniEvent<'campaign_gift.deleted', CampaignGift>;