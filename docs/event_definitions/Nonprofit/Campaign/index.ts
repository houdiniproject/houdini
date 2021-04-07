// License: LGPL-3.0-or-later
import { IDType, HoudiniObject } from '../../common';
import Nonprofit from '..';

export default interface Campaign extends HoudiniObject {
	name: string;
  nonprofit: IDType | Nonprofit;
  object: "campaign";
}

export * from './CampaignGiftOption';
export * from './CampaignGiftPurchase';
export * from './CampaignGift';
