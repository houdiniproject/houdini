// License: LGPL-3.0-or-later
import parseCustomField, { CustomFieldDescription } from "../customField";

export function parseCustomFields(input:string|null): CustomFieldDescription[] {
  input = (input || "").trim()
  if (input === "") {
    return [];
  }
  return input.split(',').map(parseCustomField);
}