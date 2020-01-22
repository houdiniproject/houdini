// License: LGPL-3.0-or-later
import * as React from 'react';
import omit =  require('lodash/omit');

export interface ProgressableButtonProps
{
  buttonText:string
  buttonTextOnProgress?:string
  inProgress?:boolean
  disableOnProgress?:boolean
  disabled?:boolean
  [props:string]: any
}


const ProgressableButton:React.StatelessComponent<ProgressableButtonProps> = (props) => {
    const ourData: {title: string, disabled: boolean, prefix: JSX.Element|null}= {
      title:props.buttonText,
      disabled:props.disabled,
      prefix: null
    }

    if (props.inProgress){
      ourData.title = props.buttonTextOnProgress || props.buttonText
      ourData.disabled = ourData.disabled || props.disableOnProgress
      ourData.prefix = <span><i className='fa fa-spin fa-spinner'></i> </span>
    }

    let selectedProps = omit(props, ['buttonText', 'disableOnProgress', 'buttonTextOnProgress', 'inProgress'])


    return <button {...selectedProps} className="button" disabled={ourData.disabled}>
      <span>{ourData.prefix}{ourData.title}</span></button>;
}

ProgressableButton.displayName = "ProgressableButton"

export default ProgressableButton



