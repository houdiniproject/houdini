// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react"
import WizardTabList from "./WizardTabList";
import {WizardState} from './wizard_state';
import {WizardTabPanelProps} from "./WizardPanel";
import {Wrapper} from "./RAT/Wrapper";

export interface WizardProps
{

    wizardState: WizardState
    disableTabs: boolean
    children: Array<React.ReactElement<WizardTabPanelProps>>
}

@observer
export class Wizard extends React.Component<WizardProps, {}> {

  render() {
     return <Wrapper manager={this.props.wizardState}
                         tag="section"
                         style={{display: 'table'}} className="wizard-steps">
         <WizardTabList wizardState={this.props.wizardState} disableTabs={this.props.disableTabs}>
         </WizardTabList>
         <div className="modal-body">

            <form onSubmit={this.props.wizardState.form.onSubmit} >

              {this.props.children}

            </form>

         </div>
         
     </Wrapper>;
  }
}

