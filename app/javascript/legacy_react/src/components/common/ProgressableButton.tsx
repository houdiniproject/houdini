// License: LGPL-3.0-or-later
import * as React from 'react';
import * as _ from 'lodash'
import {observer} from 'mobx-react';
import { injectIntl} from 'react-intl';

export interface ProgressableButtonProps
{
  buttonText:string
  buttonTextOnProgress?:string
  inProgress?:boolean
  disableOnProgress?:boolean
  disabled?:boolean
  [props:string]: any
}

@observer
class ProgressableButton extends React.Component<ProgressableButtonProps, {}> {
  render() {
    let ourData: {title: string, disabled: boolean, prefix: JSX.Element|null}= {
      title:this.props.buttonText,
      disabled: !!this.props.disabled,
      prefix: null
    }

    if (this.props.inProgress){
      ourData.title = this.props.buttonTextOnProgress || this.props.buttonText
      ourData.disabled = ourData.disabled || !!this.props.disableOnProgress
      ourData.prefix = <span><i className='fa fa-spin fa-spinner'></i> </span>
    }

    let props = _.omit(this.props, ['buttonText', 'disableOnProgress', 'buttonTextOnProgress', 'inProgress'])


    return <button {...props} className="button" disabled={ourData.disabled}>
      <span>{ourData.prefix}{ourData.title}</span></button>;
  }
}

export default ProgressableButton



