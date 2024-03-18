// License: LGPL-3.0-or-later
import { CustomFieldDescription } from "../../../types";
const h = require('snabbdom/h');


const typeToFormInputName = {
  'supporter': 'customFields'
}

export default function customField(field: CustomFieldDescription) : ReturnType<typeof h> {
  return h('input', {
    props: {
      name: `${typeToFormInputName[field.type]}[${field.name}]`,
      placeholder: field.label
    }
  });
}