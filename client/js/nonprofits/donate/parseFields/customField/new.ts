// License: LGPL-3.0-or-later
import { CustomFieldDescription } from ".";

export function newParseCustomField(input:string) : CustomFieldDescription {
  const [name, ...rest] = input.split(":").map((s) => s.trim())
  let label = null;
  if (rest.length > 0) {
    label = rest[0]
  }

  return {name, label: label || name } as CustomFieldDescription;
};
