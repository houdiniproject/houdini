// License: LGPL-3.0-or-later
import * as React from 'react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import FormikSelect from './form/FormikSelect';
import { FieldProps } from 'formik';
import FormikLabeledFieldComponent from './FormikLabeledFieldComponent';

export interface FormikSelectFieldProps<T> extends FieldProps<T>
{
  label?:string
  className?:string
  inputId?:string
  disabled?:boolean
  inputClassName?:string
  options?:{value:any, label:string}[] 
}

class FormikSelectField<T> extends React.Component<FormikSelectFieldProps<T> & InjectedIntlProps, {}> {
  render() {
     return <FormikLabeledFieldComponent
     form={this.props.form}
     field={this.props.field}
     inputId={this.props.inputId}
     labelText={this.props.label}
     className={this.props.className} >
       <FormikSelect field={this.props.field} className={`form-control ${this.props.inputClassName || ''}`} id={this.props.inputId} options={this.props.options}/>
     </FormikLabeledFieldComponent>
  }
}

export default injectIntl(FormikSelectField)



