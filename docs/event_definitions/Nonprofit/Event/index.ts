/* eslint-disable */

import { IdType, HoudiniObject, Logo } from '../../common';
import Nonprofit from '../';

export default interface Event extends HoudiniObject {
	id: IdType;
	name: string;
	nonprofit: IdType | Nonprofit;
	start_date: Date;
	end_date: Date;
	logo: Logo;
	object: "event";
}
