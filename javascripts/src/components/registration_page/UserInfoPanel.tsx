// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {Field} from "mobx-react-form";
import {computed} from 'mobx';
import {WizardPanel, WizardTabPanelProps} from "../common/wizard/WizardPanel";
import {WizardTabPanelState} from "../common/wizard/wizard_state";

export interface UserInfoPanelProps extends WizardTabPanelProps {
  buttonText: string
}

class UserInfoPanel extends React.Component<UserInfoPanelProps & InjectedIntlProps, {}> {

  @computed
  get wizardTab(): WizardTabPanelState {
    return this.props.tab
  }

  @computed
  get form():Field{
    return this.wizardTab.form
  }

  @computed
  get submit() {
    return this.form.onSubmit
  }

  @computed
  get tabName() {
    return this.wizardTab.tabName;
  }

  render() {
    let parentForm = this.form.container() || this.form.state.form
    let submitting = parentForm.submitting

    return <WizardPanel
                        tab={this.wizardTab} key={this.wizardTab.tabName}
    >


    </WizardPanel>;
  }


}

export default injectIntl(observer(UserInfoPanel))



