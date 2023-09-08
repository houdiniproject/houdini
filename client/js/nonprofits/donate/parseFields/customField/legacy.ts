// License: LGPL-3.0-or-later
import {map as Rmap, split as Rsplit, trim as Rtrim} from 'ramda';
import { CustomFieldDescription } from '.';

export function parseCustomField(f:string) :CustomFieldDescription {
  const [name, label] = Rmap(Rtrim, Rsplit(':', f))
  return {name, label: label ? label : name}
}