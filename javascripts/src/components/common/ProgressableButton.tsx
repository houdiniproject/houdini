// License: LGPL-3.0-or-later
import * as React from 'react';
import * as _ from 'lodash'
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';

export interface ProgressableButtonProps
{
  title:string
  titleOnProgress?:string
  inProgress?:boolean
  disableOnProgress?:boolean
  disabled?:boolean
  [props:string]: any
}

@observer
class ProgressableButton extends React.Component<ProgressableButtonProps, {}> {
  render() {
    let ourData: {title: string, disabled: boolean, prefix: JSX.Element|null}= {
      title:this.props.title,
      disabled:this.props.disabled,
      prefix: null
    }

    if (this.props.inProgress){
      ourData.title = this.props.titleOnProgress || this.props.title
      ourData.disabled = ourData.disabled || this.props.disableOnProgress
      ourData.prefix = <span><i className='fa fa-spin fa-spinner'></i> </span>
    }

    let props = _.omit(this.props, ['title', 'disableOnProgress', 'titleOnProgress', 'inProgress'])


    return <button {...props} className="button" disabled={ourData.disabled}>
      <span>{ourData.prefix}{ourData.title}</span></button>;
  }
}

export default ProgressableButton



