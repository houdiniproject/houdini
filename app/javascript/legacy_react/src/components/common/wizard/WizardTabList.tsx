// License: LGPL-3.0-or-later
import * as React from 'react';
import WizardTab from './WizardTab';
import {observer} from 'mobx-react';
import {WizardState} from "./wizard_state";
import {TabList} from "./RAT/TabList";


export interface WizardTabListProps
{
  wizardState: WizardState
  disableTabs?: boolean
}

@observer
export default class WizardTabList extends React.Component<WizardTabListProps, {}> {
  render() {
    let widthOfTab =  100 / this.props.wizardState.panels.length
    let output =  this.props.wizardState.panels.map((i) => {
      return <WizardTab tab={i} widthPercentage={widthOfTab}  key={i.id + "key"} disableTabs={this.props.disableTabs}></WizardTab>})
    return <TabList tag={"div"} className="wizard-index">
      {output}       
    </TabList>;
  }
}

