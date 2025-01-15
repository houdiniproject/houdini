// License: LGPL-3.0-or-later
export { CustomFieldDescription } from './parseFields/customField';
import { CustomFieldDescription } from './parseFields/customField';
import { AmountButtonInput } from './amt';

export type DedicationData = any;

export interface StandardizedParams {
  campaign_id?:number;
  custom_amounts?:AmountButtonInput[];
  custom_fields?: CustomFieldDescription[];
  designation?:string;
  designation_desc?:string;
  designation_prompt?:string;
  embedded?:boolean
  gift_option?:{name:string, id?:number};
  gift_option_id?:number
  gift_option_name?:string;
  hide_anonymous?:boolean;
  hide_dedication?:boolean;
  manual_cover_fees?:boolean;
  hide_cover_fees_option?:boolean;
  mode?:string;
  modal?:boolean;
  multiple_designations?:string[];
  offsite?:boolean;
  redirect?:string;
  single_amount?:number;
  type?: 'recurring'|'one-time';
  tags?:string[];
  weekly?:boolean;
}

