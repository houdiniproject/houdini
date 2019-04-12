// License: LGPL-3.0-or-later
import * as React from 'react';
import { FieldProps } from 'formik';

type FormikHiddenFieldProps<T> = React.DetailedHTMLProps<React.InputHTMLAttributes<HTMLInputElement>, HTMLInputElement> & FieldProps<T>

export default class FormikHiddenField<T> extends React.Component<FormikHiddenFieldProps<T>, {}> {
  render() {
    return <input type='hidden' {...this.props} {...this.props.field}
        />
  }

}

