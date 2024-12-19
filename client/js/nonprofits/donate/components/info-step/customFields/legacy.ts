// License: LGPL-3.0-or-later
import { CustomFieldDescription } from '../../../types';
import customField from './customField';
const h = require('snabbdom/h');

export function customFields(fields?:CustomFieldDescription[]|null): ReturnType<typeof h> | '' {
  if (!fields) return '';
  
  return h('div', fields.map(customField));
}
