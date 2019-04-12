// License: LGPL-3.0-or-later
import * as React from 'react';
import { FieldProps } from 'formik';
import _ = require('lodash');
import FormikLabeledFieldComponent from './FormikLabeledFieldComponent';
import { FormikInput } from './form/FormikInput';

export interface FormikBasicFieldProps<T> extends FieldProps<T> {
  placeholder?:string
  label?:string
  wrapperClassName?:string
  inputClassNames?:string
  inputId?:string
}

export default class FormikBasicField<T> extends React.Component<FormikBasicFieldProps<T>, {}> {
  render() {
    
    return <FormikLabeledFieldComponent
        form={this.props.form}
        field={this.props.field}
        inputId={this.props.inputId}
        labelText={this.props.label}
        className={this.props.wrapperClassName} >
        <FormikInput field={this.props.field} placeholder={this.props.placeholder} className={`form-control ${this.props.inputClassNames || ''}`} id={this.props.inputId}
        />
    </FormikLabeledFieldComponent>
  }

}

