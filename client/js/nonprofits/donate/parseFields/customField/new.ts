// License: LGPL-3.0-or-later
import { CustomFieldDescription } from ".";

export function parseCustomField(input:string) : CustomFieldDescription {
  const [name, ...rest] = input.split(":").map((s) => s.trim())
  const label = rest.length > 0 ? rest[0] : null;

  return {name, label: label || name, type: 'supporter' } as CustomFieldDescription;
};
