// License: LGPL-3.0-or-later
import * as React from 'react';
import FormikLabeledFieldComponent from './FormikLabeledFieldComponent';
import { FieldProps } from 'formik';
import FormikTextarea from './form/FormikTextarea';

type FormikTextareaFieldProps<V>  = FieldProps<V> & {inputId?:string, label?: string, className?:string, inputClassName?:string, rows?:number, placeholder?:string}


class FormikTextareaField<V> extends React.Component<FormikTextareaFieldProps<V>, {}> {
  render() {
    return <FormikLabeledFieldComponent
    form={this.props.form}
    field={this.props.field}
    inputId={this.props.inputId}
    labelText={this.props.label}
    className={this.props.className} >
      <FormikTextarea field={this.props.field} form={this.props.form} className={`form-control ${this.props.inputClassName || ''}`} id={this.props.inputId} rows={this.props.rows} placeholder={this.props.placeholder}/>
    </FormikLabeledFieldComponent>
 }
}

export default FormikTextareaField



