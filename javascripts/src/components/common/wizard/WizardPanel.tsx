// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react'
import { WizardTabPanelState} from './wizard_state';
import {computed} from 'mobx';
import * as _ from 'lodash'
import {TabPanel} from "./RAT/TabPanel";


export interface WizardTabPanelProps {
  tab: WizardTabPanelState
}

export interface WizardPanelProps extends WizardTabPanelProps {
    [props:string]:any
}

@observer
export class WizardPanel extends React.Component<WizardPanelProps, {}> {
    @computed
    get tab():WizardTabPanelState{
        return this.props.tab
    }
    @computed
    get isActive(){
        return this.tab.active
    }
    render() {

        let props = _.omit(this.props, ['tab'])
        return <TabPanel {...props} tabId={this.tab.id} active={this.isActive}
         className="wizard-step">
          {this.props.children}
        </TabPanel>
    }
}

