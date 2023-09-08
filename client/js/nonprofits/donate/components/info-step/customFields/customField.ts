// License: LGPL-3.0-or-later
import { CustomFieldDescription } from "../../../types";
const h = require('snabbdom/h');

export default function customField(field: CustomFieldDescription) : ReturnType<typeof h> {
  return h('input', {
    props: {
      name: `customFields[${field.name}]`,
      placeholder: field.label
    }
  });
}