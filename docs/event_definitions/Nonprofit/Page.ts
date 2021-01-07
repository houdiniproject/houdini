/* eslint-disable @typescript-eslint/member-ordering */

/* eslint-disable */

import type {IdType, FlexibleAmount, HoudiniObject, Logo, HoudiniEvent} from '../common';
import Nonprofit  from './';

export interface Page extends HoudiniObject {
	id: IdType;
	nonprofit: string|Nonprofit;
	slug: string;
	categories: string;
	full_description: string;
	facebook: string; 
	twitter: string;
	youtube: string;
	instagram: string;
	blog: string

	background_image: string;
	main_image:string;
	second_image:string;
	third_image:string
}



export type NonprofitPageUpdated = HoudiniEvent<'nonprofit_page.updated', Page>;


