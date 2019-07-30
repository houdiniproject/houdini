// License: LGPL-3.0-or-later
import * as React from 'react';
import { FieldProps } from 'formik';
import _ = require('lodash');
import FormikLabeledFieldComponent from './FormikLabeledFieldComponent';
import { FormikInput } from './form/FormikInput';

export interface FormikBasicFieldProps<T> extends FieldProps<T> {
  placeholder?:string
  label?:string
  className?:string
  inputClassNames?:string
  inputId?:string
  disabled?:boolean
  style?:React.CSSProperties
  prefixInputAddon?: JSX.Element
  postfixInputAddon?: JSX.Element
}

const InputGroupAddon: React.StatelessComponent<{ children: JSX.Element }> = (props) => {
  return <span className="input-group-addon">{props.children}</span>
}

InputGroupAddon.displayName = "InputGroupAddon"

function wrapInInputGroupWhenNeeded({ input, prefixInputAddon, postfixInputAddon }: { input: JSX.Element; prefixInputAddon?: JSX.Element; postfixInputAddon?: JSX.Element; }): JSX.Element {
  const prefix = prefixInputAddon ? <InputGroupAddon>{prefixInputAddon}</InputGroupAddon> : false;

  const postfix = postfixInputAddon ? <InputGroupAddon>{postfixInputAddon}</InputGroupAddon> : false;

  if (prefix || postfix) {
    return <div className="input-group">
      {prefix}
      {input}
      {postfix}
    </div>
  }
  else {
    return input
  }
}


export default class FormikBasicField<T> extends React.Component<FormikBasicFieldProps<T>, {}> {
  render() {
    
    return <FormikLabeledFieldComponent
        form={this.props.form}
        field={this.props.field}
        inputId={this.props.inputId}
        labelText={this.props.label}
        className={this.props.className}
        style={this.props.style}
        >
        {wrapInInputGroupWhenNeeded({input:<FormikInput field={this.props.field} placeholder={this.props.placeholder} className={`form-control ${this.props.inputClassNames || ''}`} id={this.props.inputId} disabled={this.props.disabled}
        />,
        prefixInputAddon: this.props.prefixInputAddon, postfixInputAddon: this.props.postfixInputAddon})}
    </FormikLabeledFieldComponent>
  }

}

