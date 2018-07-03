// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react"
import WizardTabList from "./WizardTabList";
import {WizardState} from './wizard_state';
import {ManagedWrapper} from "./ManagedWrapper";
import {WizardTabPanelProps} from "./WizardPanel";

export interface WizardProps
{

    wizardState: WizardState
    disableTabs: boolean
    children: Array<React.ReactElement<WizardTabPanelProps>>
}

@observer
export class Wizard extends React.Component<WizardProps, {}> {

  render() {
     return <ManagedWrapper onChange={this.props.wizardState.handleTabChange}
                         letterNavigation={true}
                         activeTabId={this.props.wizardState.activeTab.id}
                         tag="section"
                         style={{display: 'table'}} className="wizard-steps" manager={this.props.wizardState.manager}>
         <WizardTabList wizardState={this.props.wizardState} disableTabs={this.props.disableTabs}>
         </WizardTabList>
         <div className="modal-body">

            <form onSubmit={this.props.wizardState.form.onSubmit} >

              {this.props.children.filter((i) =>
                i.props.tab == this.props.wizardState.activeTab
              )}

            </form>

         </div>
         
     </ManagedWrapper>;
  }
}

