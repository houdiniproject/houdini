// License: LGPL-3.0-or-later
import * as React from 'react';

export interface StandardFieldComponentProps
{
    inError:boolean
    error?:string
    inStickyError?:boolean
    stickyError?:string
    children?:React.ReactNode
    [additional_properties:string]: any
}

export default class StandardFieldComponent extends React.Component<StandardFieldComponentProps, {}> {
    constructor(props:StandardFieldComponentProps){
        super(props)
    }
    renderChildren(){
        return React.Children.map(this.props.children, child  => {
            return React.cloneElement(child as React.ReactElement<any>,  {
              className: "form-control"
            })
        })
    }
  render() {
    let errorMessage = this.props.inError ? this.props.error : undefined
    let errorDiv = this.props.inError? <div className="help-block" role="alert">{errorMessage}</div> : ""

    let stickyErrorMessage = this.props.inStickyError ? this.props.stickyError : undefined
    let stickyErrorDiv = this.props.inStickyError ? <div className="help-block" role="alert">{stickyErrorMessage}</div> : ""

    return <div>
        {this.props.children}
        {errorDiv}
        {stickyErrorDiv }
      </div>


  }
}

