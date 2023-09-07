// License: LGPL-3.0-or-later
import {map as Rmap} from 'ramda';
import { CustomFieldDescription } from '../../../types';
import customField from './customField';
const h = require('snabbdom/h');

export default function customFields(fields?:CustomFieldDescription[]|null): ReturnType<typeof h> | '' {
  if (!fields) return '';
  
  return h('div', Rmap(customField, fields));
}
