// License: LGPL-3.0-or-later
import * as React from 'react';
import {FormattedMessage, injectIntl, InjectedIntlProps} from 'react-intl';
import {observer} from 'mobx-react';
import {WizardTabPanelState} from "./wizard_state";
import {Tab} from "./RAT/Tab";

interface MiniTabInfo{
  active:boolean
  enabled:boolean
  label:string
  id: string
}

export interface WizardTabProps
{
  tab: MiniTabInfo
  widthPercentage:number
  style?: any
  disableTabs?: boolean
}


class WizardTab extends React.Component<WizardTabProps & InjectedIntlProps, {}> {
  render() {
    let percentageToString = this.props.widthPercentage.toString() + "%"
    let style=  {width: percentageToString}
    
    
    let className = "wizard-index-label"
    if (this.props.tab.active){
      className += " is-current"
    }
    let disableOverrideTab = this.props.disableTabs

    if (this.props.tab.enabled || disableOverrideTab){
      className += " is-accessible"
    }
    
    return <Tab tag={'span'} active={this.props.tab.active} className={className} style={style} id={this.props.tab.id}>

        {this.props.intl.formatMessage({id:this.props.tab.label})}
    </Tab>
  }
}

export default injectIntl(observer(WizardTab))
