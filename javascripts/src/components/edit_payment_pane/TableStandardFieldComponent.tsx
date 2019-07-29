// License: LGPL-3.0-or-later
import * as React from 'react';
import FormNotificationBlock from '../common/form/FormNotificationBlock';
import _ = require('lodash');
import { FieldProps } from 'formik';

export interface StandardFieldComponentProps<T> extends FieldProps<T> {
  [additional_properties: string]: any
}

export default class FormikStandardFieldComponent<T> extends React.Component<StandardFieldComponentProps<T>> {
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

    let errorDiv = errorMessage && fieldTouched ? <FormNotificationBlock>{errorMessage}</FormNotificationBlock> : ""

    let stickyErrorMessage = _.get(this.props.form.status, `fields.${this.props.field.name}`)
    let stickyErrorDiv = stickyErrorMessage ? <FormNotificationBlock>{stickyErrorMessage}</FormNotificationBlock> : ""

    return <div>
      {this.props.children}
      {errorDiv}
      {stickyErrorDiv}
    </div>


  }
}

