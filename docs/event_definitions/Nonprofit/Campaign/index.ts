// License: LGPL-3.0-or-later
import { IdType, HoudiniObject } from '../../common';
import Nonprofit from '../';

export default interface Campaign extends HoudiniObject {
	name: string;
  nonprofit: IdType | Nonprofit;
  object: "campaign";
}

export * from './CampaignGiftOption';
