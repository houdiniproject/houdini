// License: LGPL-3.0-or-later
import {map as Rmap, split as Rsplit } from "ramda";
import parseCustomField, { CustomFieldDescription } from "../customField";

export function parseCustomFields(fields:string): CustomFieldDescription[] {
  return Rmap(parseCustomField, Rsplit(',',  fields))
}
