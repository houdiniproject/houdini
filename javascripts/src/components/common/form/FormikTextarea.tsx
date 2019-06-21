// License: LGPL-3.0-or-later
import * as React from 'react';
import { FieldProps } from 'formik';
import _ = require('lodash');
import { Omit } from '../../../lib/types';

type FormikTextareaProps<V> = Omit<React.TextareaHTMLAttributes<HTMLTextAreaElement>, 'form'> & FieldProps<V>

class FormikTextarea<V> extends React.Component<FormikTextareaProps<V>> {
  render() {
    const {form, field, ...props} = this.props
    return <textarea {...props} {...this.props.field}/>
  }
}

export default FormikTextarea



