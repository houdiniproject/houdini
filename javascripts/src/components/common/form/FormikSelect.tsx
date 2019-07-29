// License: LGPL-3.0-or-later
import * as React from 'react';
import { FormikHandlers } from 'formik';

export interface FormikSelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  field: {
    onChange: FormikHandlers['handleChange'],
    onBlur: FormikHandlers['handleBlur'],
    value: any,
    name: string;
  }

  options: { value: any, label: string }[]
}

export default class FormikSelect extends React.Component<FormikSelectProps, {}>{
  static defaultProps: Partial<FormikSelectProps> = {
    options: []
  }

  render() {
    const { field, form, options, ...props } = this.props
    return <select {...props} {...field} >
      {options ? options.map(option => {
        let attributes: React.OptionHTMLAttributes<HTMLOptionElement> = {
          value: option.value
        }
        return <option key={option.value} {...attributes}>{option.label}</option>
      }
      ) : this.props.children
      }
    </select>

  }
}



