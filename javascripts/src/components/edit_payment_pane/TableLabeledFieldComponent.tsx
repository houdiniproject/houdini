// License: LGPL-3.0-or-later
import * as React from 'react';
import TableStandardFieldComponent from "./TableStandardFieldComponent";
import { FieldProps } from 'formik';
import _ = require('lodash');


export interface TableLabeledFieldComponentProps<T> extends FieldProps<T> {
  labelText: string
  inputId: string

  className?: string
}

export default class TableLabeledFieldComponent<T> extends React.Component<TableLabeledFieldComponentProps<T>> {
  render() {
    let error = _.get(this.props.form.errors, this.props.field.name)
    let serverError = _.get(this.props.form.status, `fields.${this.props.field.name}`)

    let classNames: string[] = []
    if (this.props.className)
      classNames.push(this.props.className)

    if (error || serverError) {
      classNames.push("has-error")
    }

    return <tr className={classNames.join(' ')}>
      <th>
        <label htmlFor={this.props.inputId} className="control-label">{this.props.labelText}</label>
      </th>
      <td>
        <TableStandardFieldComponent form={this.props.form} field={this.props.field} id={this.props.inputId}>{this.props.children}</TableStandardFieldComponent>
      </td>
    </tr>
  }
}


