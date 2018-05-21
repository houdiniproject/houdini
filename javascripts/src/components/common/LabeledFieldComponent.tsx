// License: LGPL-3.0-or-later
import * as React from 'react';
import StandardFieldComponent from "./StandardFieldComponent";
import { observer } from 'mobx-react';
import {Field} from "../../../../types/mobx-react-form";
import {injectIntl, InjectedIntl} from 'react-intl';


export interface LabeledFieldComponentProps
{
    inputId: string
    labelText: string
    inError:boolean
    error?:string
    className?:string
}

@observer
export default class LabeledFieldComponent extends React.Component<LabeledFieldComponentProps, {}> {
  render() {
     let className = this.props.className || ""
     let inError = this.props.inError && this.props.error !== null && this.props.error !== "";
     className += " form-group"
      className += inError ? " has-error" : ""
     return <fieldset className={className}><label htmlFor={this.props.inputId} className="control-label">{this.props.labelText}</label>
         <StandardFieldComponent inError={inError} error={this.props.error} >{this.props.children}</StandardFieldComponent>
     </fieldset>;
  }
}


