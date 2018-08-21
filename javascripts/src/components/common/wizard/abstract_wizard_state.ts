// License: LGPL-3.0-or-later
import {computed, reaction} from "mobx";
import {AbstractTabComponentState, AbstractTabPanelState} from "./RAT/abstract_tabcomponent_state";
import _ = require("lodash");

export abstract class AbstractWizardState<PanelStateType extends AbstractWizardTabPanelState = AbstractWizardTabPanelState>
  extends AbstractTabComponentState<PanelStateType> {


  addTab(tab: { tabName: string, label: string }): PanelStateType {
    const ret = super.addTab(tab);

    reaction(() => this.lastConsistentlyEnabledTab, (data, react) => {
      this.strategy(this)
    });

    return ret;
  }

  @computed
  get firstDisabledTab(): PanelStateType {
    return _.find(this.panels, (i) => !i.enabled)
  }

  @computed
  get lastConsistentlyEnabledTab(): PanelStateType {
    return this.firstDisabledTab ? this.firstDisabledTab.previous : _.last(this.panels)
  }

  protected strategy(state: this) {
    if (this.lastConsistentlyEnabledTab.before(this.activeTab)) {
      this.activateTab(this.lastConsistentlyEnabledTab)
    }
  }
}

export abstract class AbstractWizardTabPanelState extends AbstractTabPanelState {
  /**
   * Whether this tab's form is valid. We override this in a mock so we can manually set the validity
   * via a simple function call
   * @returns {boolean} true if this tab's form is valid, otherwise false
   */
  abstract get isValid(): boolean

  @computed
  get enabled(): boolean {

    const previous = this.previous;

    if (previous) {
      const enabled = previous.enabled;
      const valid = previous.isValid;
      return enabled && valid
    }
    return true
  }

}