// License: LGPL-3.0-or-later
import * as React from 'react';
import TableLabeledFieldComponent from './TableLabeledFieldComponent';
import { FormikInput } from '../common/form/FormikInput';
import { FieldProps } from 'formik';



export interface TableLabeledBasicFieldProps<T> extends FieldProps<T> {
  placeholder?: string
  label?: string
  className?: string
  inputClassNames?: string
  inputId?: string
  disabled?: boolean
}

export default class FormikBasicField<T> extends React.Component<TableLabeledBasicFieldProps<T>> {
  render() {

    return <TableLabeledFieldComponent
        form={this.props.form}
        field={this.props.field}
        inputId={this.props.inputId}
        labelText={this.props.label}
        className={this.props.className} >
        <FormikInput field={this.props.field} placeholder={this.props.placeholder} className={`form-control ${this.props.inputClassNames || ''}`} id={this.props.inputId} disabled={this.props.disabled}
        />
      </TableLabeledFieldComponent>
  }
}


