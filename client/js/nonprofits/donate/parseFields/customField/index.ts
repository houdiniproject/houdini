// License: LGPL-3.0-or-later
import { parseCustomField } from "./legacy";

export interface CustomFieldDescription {
  name: NonNullable<string>;
  label: NonNullable<string>;
}


export default parseCustomField;