// License: LGPL-3.0-or-later
import * as React from 'react';
import { HoudiniFormikProps, FormikHelpers } from '../HoudiniFormik';


export interface HoudiniFormikFormProps extends React.FormHTMLAttributes<HTMLFormElement>
{
  formik:HoudiniFormikProps<any>
  
}

class HoudiniFormikForm extends React.Component<HoudiniFormikFormProps, {}> {
  render() {
     return <form onSubmit={this.props.formik.handleSubmit} onReset={this.props.formik.handleReset} id={FormikHelpers.createFormId(this.props.formik)}>{this.props.children}</form>;
  }
}

export default HoudiniFormikForm;



