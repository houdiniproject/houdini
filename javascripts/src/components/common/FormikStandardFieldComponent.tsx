// License: LGPL-3.0-or-later
import * as React from 'react';
import { FieldProps } from 'formik';
import _ = require('lodash');

export interface StandardFieldComponentProps<T> extends FieldProps<T> {
  [additional_properties: string]: any
}

export default class FormikStandardFieldComponent<T> extends React.Component<StandardFieldComponentProps<T>, {}> {
  constructor(props: StandardFieldComponentProps<T>) {
    super(props)
  }
  renderChildren() {
    return React.Children.map(this.props.children, child => {
      return React.cloneElement(child as React.ReactElement<any>, {
        className: "form-control"
      })
    })
  }
  render() {

    let errorMessage = _.get(this.props.form.errors, this.props.field.name)
    let fieldTouched = _.get(this.props.form.touched, this.props.field.name)

    let errorDiv = errorMessage && fieldTouched ? <div className="help-block" role="alert">{errorMessage}</div> : ""

    let stickyErrorMessage = _.get(this.props.form.status, `fields.${this.props.field.name}`)
    let stickyErrorDiv = stickyErrorMessage ? <div className="help-block" role="alert">{stickyErrorMessage}</div> : ""

    return <div>
      {this.props.children}
      {errorDiv}
      {stickyErrorDiv}
    </div>


  }
}

