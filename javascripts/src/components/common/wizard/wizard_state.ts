// License: LGPL-3.0-or-later
import {observable, action, computed, toJS, reaction, runInAction} from "mobx";
import {Field, Form, FieldDefinition, FieldHandlers, FieldHooks} from "mobx-react-form";
import _ = require("lodash");
import {AbstractWizardState, AbstractWizardTabPanelState} from "./abstract_wizard_state";

interface SubFormDefinition {
  related?: string[]
  bindings?: any
  options?: any
  extra?: any
  hooks?: FieldHooks
  handlers?: FieldHandlers
  fields?: Array<FieldDefinition>
}

export abstract class WizardState<PanelStateType extends WizardTabPanelState = WizardTabPanelState,
  FormStateType extends Form = Form> extends AbstractWizardState<PanelStateType> {

  protected constructor(panelType: { new(): PanelStateType }) {
    super(panelType)
  }

  @observable form: FormStateType;

  abstract createForm(i: any): FormStateType;

  addTab(tab: { tabName: string, label: string, tabFieldDefinition: SubFormDefinition}): PanelStateType {
    const ret = super.addTab(tab);

    runInAction(() => {
      ret.panelFormDefinition = tab.tabFieldDefinition as FieldDefinition
    });

    return ret;
  }

  @action.bound
  initialize(): void {
    if (this.panels.length > 0) {
      //let's create the forms
      const lastIndex = this.panels.length;
      for (let i = 0; i < lastIndex; i++) {
        let ourPanel = this.panels[i]

        if (!ourPanel.panelFormDefinition.hooks)
          ourPanel.panelFormDefinition.hooks = {}

        //ourPanel.originalOnSuccessHook = toJS(ourPanel.panelFormDefinition.hooks['onSuccess'])

        ourPanel.panelFormDefinition.hooks['onSuccess'] = this.onSuccessForPanel

        /// this won't work because the hook is already replaced
        // if (ourPanel.panelFormDefinition.hooks)
        //   ourPanel.originalOnErrorHook = ourPanel.panelFormDefinition.hooks['onError']
        ourPanel.panelFormDefinition.hooks['onError'] = this.onErrorForPanel

        ourPanel.panelFormDefinition.name = ourPanel.tabName
      }

      //we need to change these back to JS objects because they're likely observable and fieldDefinitions
      // can't handle that
      const fieldDefinition = toJS(this.panels.map((i) => toJS(i.panelFormDefinition)))
      this.form = this.createForm({fields: fieldDefinition})

      _.forEach(this.panels, (i) => {
        //add the form to each panel
        i.parentForm = this.form
        i.form = this.form.$(i.tabName)
      })
    }
  }

  @action.bound
  onSuccessForPanel(a: Field): void {

    // if (this.activeTab.originalOnSuccessHook) {
    //   this.activeTab.originalOnSuccessHook(a)
    // }

    if (a.submitting) {
      if (this.nextTab)
        this.moveToNextTab();
      else
        this.form.submit();
    }
  }


  @action.bound
  onErrorForPanel(a: Field): any {
    // if (this.activeTab.originalOnErrorHook) {
    //   this.activeTab.originalOnErrorHook(a)
    // }
  }
}

export class WizardTabPanelState<ParentFormStateType extends Form = Form> extends AbstractWizardTabPanelState {
  @observable parentForm: ParentFormStateType

  @observable form: Field


  // @observable originalOnSuccessHook: Function
  // @observable originalOnErrorHook: Function

  panelFormDefinition: FieldDefinition

  /**
   * Whether this tab's form is valid. We override this in a mock so we can manually set the validity
   * via a simple function call
   * @returns {boolean} true if this tab's form is valid, otherwise false
   */
  @computed
  get isValid(): boolean {
    return this.form.isValid
  }
}