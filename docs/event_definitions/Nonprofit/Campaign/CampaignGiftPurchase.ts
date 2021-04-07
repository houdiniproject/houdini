// License: LGPL-3.0-or-later
import type { HouID, HoudiniEvent, Amount, IDType} from '../../common';
import type Nonprofit from '..';
import type Campaign from '.';
import type { CampaignGift } from '.';
import type { TrxAssignment } from '../Transaction';

export interface CampaignGiftPurchase extends TrxAssignment {
  amount: Amount;
  campaign: IDType | Campaign;
  campaign_gifts: HouID[] | CampaignGift[];
  nonprofit: IDType | Nonprofit;
  object: 'campaign_gift_purchase';
}


export type CampaignGiftPurchaseCreated = HoudiniEvent<'campaign_gift_purchase.created', CampaignGiftPurchase>;
export type CampaignGiftPurchaseUpdated = HoudiniEvent<'campaign_gift_purchase.updated', CampaignGiftPurchase>;
export type CampaignGiftPurchaseDeleted = HoudiniEvent<'campaign_gift_purchase.deleted', CampaignGiftPurchase>;