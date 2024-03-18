// License: LGPL-3.0-or-later
import { CustomFieldDescription } from '../customField';
import { parseCustomFields as parseSimpleCustomFields } from './legacy';
import JsonStringParser from './JsonStringParser';

export default function parseCustomFields(fieldsString:string) : CustomFieldDescription[] {
  if (fieldsString.includes("{")) {
    return new JsonStringParser(fieldsString).results;
  }
  else {
    return parseSimpleCustomFields(fieldsString);
  }
}
