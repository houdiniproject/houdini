// License: LGPL-3.0-or-later
import type { HouID, HoudiniObject, HoudiniEvent, Amount, IDType} from '../../common';
import type Campaign from '.';
import type { CampaignGiftPurchase, CampaignGiftOption } from '.';
import { TrxDescendent } from '../Transaction';

export interface TransactionAddress {
  address: string;
  city: string;
  country: string;
  state_code: string;
  zip_code: string;
}

export interface CampaignGift extends HoudiniObject<HouID>, TrxDescendent {
  address?: TransactionAddress;
  amount: Amount;
  campaign: IDType | Campaign;
  campaign_gift_option: IDType | CampaignGiftOption;
  campaign_gift_purchase: IDType | CampaignGiftPurchase;
  deleted: boolean;
  event: IDType | Event;
  object: 'campaign_gift';
}

export type CampaignGiftCreated = HoudiniEvent<'campaign_gift.created', CampaignGift>;
export type CampaignGiftUpdated = HoudiniEvent<'campaign_gift.updated', CampaignGift>;
export type CampaignGiftDeleted = HoudiniEvent<'campaign_gift.deleted', CampaignGift>;