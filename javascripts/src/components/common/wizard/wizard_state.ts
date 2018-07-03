// License: LGPL-3.0-or-later
import {observable, action, computed, toJS, reaction, runInAction} from "mobx";
import {Field, Form, FieldDefinition, FieldHandlers, FieldHooks} from "mobx-react-form";
import _ = require("lodash");
import {TabManager} from "./manager"
import {Wizard} from "./Wizard";

interface SubFormDefinition {
  related?: string[]
  bindings?: any
  options?: any
  extra?: any
  hooks?: FieldHooks
  handlers?: FieldHandlers
  fields?: Array<FieldDefinition>
}

export abstract class WizardState<PanelStateType extends WizardTabPanelState = WizardTabPanelState> {
  panelType: { new(): PanelStateType }

  constructor(panelType: { new(): PanelStateType } = null) {
    this.panelType = panelType
  }

  @observable
  lastRequestedTab: WizardTabPanelState

  @observable panels = new Array<WizardTabPanelState>()
  @observable form: Form

  @observable manager: TabManager

  abstract createForm(i: any): Form;

  @action.bound
  private createChildState(): WizardTabPanelState {
    if (this.panelType)
      return new this.panelType()
    else
      return new WizardTabPanelState()
  }

  @action.bound
  addTab(tabName: string, label: string, tabFieldDefinition: SubFormDefinition): WizardTabPanelState {

    var newTab = this.createChildState()
    newTab.id = _.uniqueId('tab')
    newTab.tabName = tabName
    newTab.label = label
    if (this.panels.length == 0) {
      this.activeTab = newTab
    }
    newTab.parent = this
    newTab.panelFormDefinition = tabFieldDefinition as FieldDefinition
    this.panels.push(newTab)

    if (!this.manager) {
      this.manager = new TabManager({
        onChange: this.handleTabChange, letterNavigation: true, activeTabId: this.activeTab.id,
        canChangeTo: this.canChangeTo
      })
    }


    reaction(() => this.lastConsistentlyEnabledTab, (data, react) => {
      if (data.before(this.activeTab)) {
        this.activateTab(data)
      }
    })
    return newTab;
  }

  @action.bound
  initialize(): void {
    if (this.panels.length > 0) {
      //let's create the forms
      let lastIndex = this.panels.length
      for (let i = 0; i < lastIndex; i++) {
        let ourPanel = this.panels[i]

        if (!ourPanel.panelFormDefinition.hooks)
          ourPanel.panelFormDefinition.hooks = {}

        ourPanel.originalOnSuccessHook = toJS(ourPanel.panelFormDefinition.hooks['onSuccess'])

        ourPanel.panelFormDefinition.hooks['onSuccess'] = this.onSuccessForPanel

        /// this won't work because the hook is already replaced
        if (ourPanel.panelFormDefinition.hooks)
          ourPanel.originalOnErrorHook = ourPanel.panelFormDefinition.hooks['onError']
        ourPanel.panelFormDefinition.hooks['onError'] = this.onErrorForPanel

        ourPanel.panelFormDefinition.name = ourPanel.tabName
      }

      //we need to change these back to JS objects because they're likely observable and fieldDefinitions
      // can't handle that
      let fieldDefinition = toJS(this.panels.map((i) => toJS(i.panelFormDefinition)))
      this.form = this.createForm({fields: fieldDefinition})

      _.forEach(this.panels, (i) => {
        //add the form to each panel
        i.parentForm = this.form
        i.form = this.form.$(i.tabName)
      })
    }
  }

  @computed
  get tabsByName(): { [name: string]: WizardTabPanelState } {
    return _.fromPairs(this.panels.map((i) => [i.tabName, i]));
  }

  @observable activeTab: WizardTabPanelState

  activateTab(tab: WizardTabPanelState | string) {
    let tabId: string = null
    if (tab instanceof WizardTabPanelState) {
      tabId = tab.id
    }
    else {
      tabId = tab;
    }

    this.manager.activateTab(tabId)
  }

  @action.bound
  handleTabChange(tabId: string): WizardTabPanelState {
    let self = this

    let tabInfo = _.find(self.panels, (i) => i.id == tabId)
    if (tabInfo && tabInfo.enabled) {
      this.activeTab = tabInfo

      return self.activeTab === tabInfo ? tabInfo : null;
    }
    return null
  }

  @action.bound
  private canChangeTo(tabId: string): boolean {

    let tab = _.find(this.panels, (i) => i.id == tabId)
    return tab && tab.enabled

  }

  @action.bound
  moveToNextTab() {
    let self = this

    if (this.nextTab) {
      self.manager.activateTab(this.nextTab.id)

    }
  }

  @action.bound
  onSuccessForPanel(a: Field): void {

    if (this.activeTab.originalOnSuccessHook) {
      this.activeTab.originalOnSuccessHook(a)
    }

    if (a.submitting) {
      if (this.nextTab)
        this.moveToNextTab()
      else
        this.form.submit()
    }
  }


  @action.bound
  onErrorForPanel(a: Field): any {
    if (this.activeTab.originalOnErrorHook) {
      this.activeTab.originalOnErrorHook(a)
    }
  }

  @computed
  get firstDisabledTab(): WizardTabPanelState {
    return _.find(this.panels, (i) => !i.enabled)
  }

  @computed
  get lastConsistentlyEnabledTab(): WizardTabPanelState {
    return this.firstDisabledTab ? this.firstDisabledTab.previous : _.last(this.panels)
  }


  @computed
  get nextTab(): WizardTabPanelState {
    return this.activeTab.next
  }

  @computed
  get previousTab(): WizardTabPanelState {
    return this.activeTab.previous
  }
}

export class WizardTabPanelState {
  @observable parent: WizardState

  @observable parentForm: Form

  @observable form: Field


  @observable id: string
  @observable tabName: string
  @observable label: string

  @observable originalOnSuccessHook: Function
  @observable originalOnErrorHook: Function

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

  @computed
  get active(): boolean {
    return this.parent.activeTab === this
  }

  @computed
  get enabled(): boolean {

    let previous = this.previous
    let next = this.next

    if (previous) {
      let enabled = previous.enabled
      let valid = previous.isValid;
      return enabled && valid
    }
    return true
  }


  @computed
  get previous(): WizardTabPanelState {
    if (!this.parent || !this.parent.panels)
      return null;
    let index = _.findIndex(this.parent.panels, (i) => i == this)
    if (index === null) {
      // return null but we have a problem here
      return null
    }
    if (index === 0) {
      // there is no previous one because we're first!
      return null;
    }

    return this.parent.panels[index - 1]
  }

  @computed
  get next(): WizardTabPanelState {
    if (!this.parent || !this.parent.panels)
      return null;

    let index = _.findIndex(this.parent.panels, (i) => i == this)
    let panelLength = this.parent.panels.length
    if (index === null) {
      // return null but we have a problem here
      return null
    }

    if (index + 1 >= panelLength) {
      //we have no advanced
      return null;
    }

    return this.parent.panels[index + 1]
  }

  before(tab: WizardTabPanelState): boolean {
    let testItem: WizardTabPanelState = this
    while (testItem.next != tab) {
      if (!testItem.next)
        return false;
      testItem = testItem.next
    }

    return true
  }


  after(tab: WizardTabPanelState): boolean {
    let testItem: WizardTabPanelState = this
    while (testItem.previous != tab) {
      if (!testItem.previous)
        return false;
      testItem = testItem.previous
    }

    return true
  }
}