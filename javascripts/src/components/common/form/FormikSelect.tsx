// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import { FormikHandlers } from 'formik';
import _ = require('lodash');

export interface FormikSelectProps extends React.SelectHTMLAttributes<HTMLSelectElement>
{
  field: {
    onChange: FormikHandlers['handleChange'],
    onBlur: FormikHandlers['handleBlur'],
    value: any,
    name: string;
  }

  options: {id:string, name:string}[]
}

export default class FormikSelect extends React.Component<FormikSelectProps, {}>{
  static defaultProps:Partial<FormikSelectProps> = {
    options: []
  }

  render() {
      const {field, form, options, ...props} = this.props
      return <select {...props} {...field}>
      { options ? options.map(option =>
        <option key={option.id} value={option.id}>{option.name}</option>
      ) : this.props.children
       }
    </select>

  }
}



