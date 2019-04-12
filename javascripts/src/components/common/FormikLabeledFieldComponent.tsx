// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from 'mobx-react';
import { FieldProps } from 'formik';
import _ = require('lodash');
import FormikStandardFieldComponent from './FormikStandardFieldComponent';


export interface FormikLabeledFieldComponentProps<T>  extends FieldProps<T> 
{
  labelText:string
  inputId: string

  className?:string
}

@observer
export default class FormikLabeledFieldComponent<T> extends React.Component<FormikLabeledFieldComponentProps<T>, {}> {
  render() {
    let error = _.get(this.props.form.errors, this.props.field.name)
    let serverError = _.get(this.props.form.status, `fields.${this.props.field.name}`)
    let classNames:string[] = []
    if (this.props.className)
      classNames.push(this.props.className)

    classNames.push("form-group")
    if(error || serverError){
       classNames.push("has-error")
    }

    return <fieldset className={classNames.join(" ")}><label htmlFor={this.props.inputId} className="control-label">{this.props.labelText}</label>
       <FormikStandardFieldComponent form={this.props.form} field={this.props.field} id={this.props.inputId}>{this.props.children}</FormikStandardFieldComponent>
    </fieldset>;
  }
}


