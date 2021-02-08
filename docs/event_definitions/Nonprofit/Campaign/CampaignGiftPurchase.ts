// License: LGPL-3.0-or-later
import type { HouID, HoudiniObject, HoudiniEvent, Amount, IdType} from '../../common';
import type Nonprofit from '..';
import type Campaign from '.';
import type { CampaignGift } from '.';
import Supporter from '../Supporter';
import { Transaction } from '../Supporter';


export interface CampaignGiftPurchase extends HoudiniObject<HouID> {
  amount: Amount;
  campaign: IdType | Campaign;
  campaign_gifts: HouID[] | CampaignGift[];
  nonprofit: IdType | Nonprofit;
  object: 'campaign_gift_purchase';
  supporter: IdType | Supporter;
  transaction: HouID | Transaction;
}


export type CampaignGiftPurchaseCreated = HoudiniEvent<'campaign_gift_purchase.created', CampaignGiftPurchase>;
export type CampaignGiftPurchaseUpdated = HoudiniEvent<'campaign_gift_purchase.updated', CampaignGiftPurchase>;
export type CampaignGiftPurchaseDeleted = HoudiniEvent<'campaign_gift_purchase.deleted', CampaignGiftPurchase>;