/* eslint-disable @typescript-eslint/member-ordering */

/* eslint-disable */

import type {IdType, FlexibleAmount, HoudiniObject, Logo} from '../common';
import Nonprofit from './'

export default interface EmailTemplate extends HoudiniObject {
	id: IdType;
	nonprofit: IdType | Nonprofit;
	
	object: "email_template";
}



