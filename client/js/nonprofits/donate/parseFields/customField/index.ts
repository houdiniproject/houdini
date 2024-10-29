// License: LGPL-3.0-or-later
import { parseCustomField } from "./legacy";
import has from 'lodash/has';
import get from 'lodash/get';

export interface CustomFieldDescription {
  name: NonNullable<string>;
  label: NonNullable<string>;
  type: 'supporter';
}

export function isCustomFieldDescription(item:unknown) : item is CustomFieldDescription {
  return typeof item == 'object' && 
    has(item, 'name') && 
    has(item, 'label') && 
    ['supporter'].includes(get(item, 'type'));
}


export default parseCustomField;