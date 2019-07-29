// License: LGPL-3.0-or-later
import * as React from 'react';
import { HoudiniFormikProps, FormikHelpers } from '../HoudiniFormik';


export interface HoudiniFormikFormProps<T> extends React.FormHTMLAttributes<HTMLFormElement>
{
  formik:HoudiniFormikProps<T>
  
}

class HoudiniFormikForm<T> extends React.Component<HoudiniFormikFormProps<T>, {}> {
  render() {
     return <form onSubmit={this.props.formik.handleSubmit} onReset={this.props.formik.handleReset} id={FormikHelpers.createFormId(this.props.formik)}>{this.props.children}</form>;
  }
}

export default HoudiniFormikForm;



