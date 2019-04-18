// License: LGPL-3.0-or-later
import * as React from 'react';
import StandardFieldComponent from "./StandardFieldComponent";
import {observer} from 'mobx-react';
import {InjectedIntl, injectIntl} from 'react-intl';


export interface LabeledFieldComponentProps
{
    inputId: string
    labelText: string
    inError:boolean
    error?:string
    inStickyError?:boolean
    stickyError?:string
    className?:string
    style?:React.CSSProperties
}

@observer
export default class LabeledFieldComponent extends React.Component<LabeledFieldComponentProps, {}> {
  render() {
    let classNames:string[] = []
    if (this.props.className)
      classNames.push(this.props.className)

    let inError = this.props.inError && this.props.error !== null && this.props.error !== "";
    let inStickyError = this.props.inStickyError && this.props.stickyError !== null && this.props.stickyError !== ""

    classNames.push("form-group")
    if(inError || inStickyError){
       classNames.push("has-error")
    }

    return <fieldset className={classNames.join(" ")} style={this.props.style}><label htmlFor={this.props.inputId} className="control-label">{this.props.labelText}</label>
       <StandardFieldComponent inError={inError} error={this.props.error} inStickyError={inStickyError} stickyError={this.props.stickyError}>{this.props.children}</StandardFieldComponent>
    </fieldset>;
  }
}


