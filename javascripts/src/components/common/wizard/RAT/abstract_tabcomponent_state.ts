// License: LGPL-3.0-or-later
import {action, computed, observable, reaction, runInAction} from "mobx";
import _ = require("lodash");

const createFocusGroup = require('focus-group');

export interface TabManagerParent {
  registerTabElement(tab: { id: string, node: any}): void

  registerTabPanelElement(tabPanel: { tabId: string, node: any }): void

  unregisterTabElement(tab: { id: string }): void

  unregisterTabPanelElement(tabPanel: { id: string }): void

  handleTabFocus(tabId: string): void

  getTabPanelId(id: string): string

  focusTab(id: string): void

  activate(): void

  destroy(): void
}


export abstract class AbstractTabComponentState<PanelStateType extends AbstractTabPanelState = AbstractTabPanelState>
  implements TabManagerParent {

  @observable focusGroup: any;
  @observable panels:Array<PanelStateType> = [];
  @observable activeTab: PanelStateType;


  protected constructor(readonly panelType: { new(): PanelStateType }) {

    const focusGroupOptions = {
      wrap: true,
      forwardArrows: ['down', 'right'],
      backArrows: ['up', 'left'],
      stringSearch: true,
    };

    this.focusGroup = createFocusGroup(focusGroupOptions);

    reaction(() => this.activeTab && this.activeTab.enabled , () => {
      if (!this.activeTab.enabled){
        this.strategy(this)
      }

    })
  }

  @computed
  get tabsByName(): { [name: string]: PanelStateType } {
    return _.fromPairs(this.panels.map((i) => [i.tabName, i]));
  }

  @computed
  get nextTab(): PanelStateType {
    return this.activeTab.next
  }

  @computed
  get previousTab(): PanelStateType {
    return this.activeTab.previous
  }


  addTab(tab:{ tabName: string, label: string }): PanelStateType {
    let newTab:PanelStateType;
    runInAction(() => {
      newTab = this.createChildState();
      newTab.id = this.uniqueIdFunction('tab');
      newTab.tabName = tab.tabName;
      newTab.label = tab.label;
      if (this.panels.length == 0) {
        this.activeTab = newTab
      }
      newTab.parent = this;

      this.panels.push(newTab)
    });
    return newTab;
  }

  moveToTab(tab: PanelStateType | string) {

    let tabState: PanelStateType = null;
    if (tab instanceof AbstractTabPanelState) {
      tabState = tab
    }
    else {
      tabState = _.find(this.panels, (i) => i.id == tab)
    }

    this.focusTab(tabState.id)
  }

  @action.bound
  activateTab(tab: PanelStateType | string) {

    let tabState: PanelStateType = null;
    if (tab instanceof AbstractTabPanelState) {
      tabState = tab
    }
    else {
      tabState = _.find(this.panels, (i) => i.id == tab)
    }

    if (this.canChangeTo(tabState.id)) {
      this.activeTab = tabState
    }
  }

  @action.bound
  moveToNextTab() {
    const self = this;

    if (this.nextTab) {
      self.focusTab(this.nextTab.id)
    }
  }


  @action.bound
  moveToPreviousTab() {
    const self = this;

    if (this.previousTab) {
      self.focusTab(this.previousTab.id)
    }
  }

  @action.bound
  canChangeTo(tabId: string): boolean {

    const tab = _.find(this.panels, (i) => i.id == tabId);
    return tab && tab.enabled
  }

  focusTab(id: string): void {
    runInAction(() => {
      let tabMemberToFocus = _.find(this.panels, (panel) => panel.id === id);
      if (!tabMemberToFocus) return;
      this.focusFunction(tabMemberToFocus)
    })
  }

  getTabPanelId(id: string): string {
    return id + '-panel';
  }

  @action.bound
  handleTabFocus(tabId: string): void {
    this.activateTab(tabId);
  }

  @action.bound
  unregisterTabPanelElement(tabPanel: { id: string; }): void {

  }

  @action.bound
  unregisterTabElement(tab: { id: string; }): void {
    //throw new Error("Method not implemented.");
  }

  @action.bound
  registerTabPanelElement(tabPanel: { tabId: string; node: any; }): void {

  }

  @action.bound
  registerTabElement(tabMember: { id: string; node: any }): void {
    let tabMemberToRegister = _.find(this.panels, (panel) => panel.id === tabMember.id);
    let focusGroupMember = (tabMemberToRegister.letterNavigationText) ? {
      node: tabMember.node,
      text: tabMemberToRegister.letterNavigationText,
    } : tabMember.node;
    tabMemberToRegister.node = tabMember.node;
    this.focusGroup.addMember(focusGroupMember, tabMember);
  }

  @action.bound
  activate() {
    this.focusGroup.activate();
  }

  @action.bound
  destroy() {
    this.focusGroup.destroy();
  }

  @action.bound
  protected createChildState(): PanelStateType {
    return new this.panelType()
  }

  /**
   * TESTING ONLY: The function used to focus on a particular tab. We override in Enzyme tests
   * @param {PanelStateType} panel
   */
  protected focusFunction(panel:PanelStateType) {
    panel.node.focus()
  }

  /**
   * TESTING ONLY: The function used for getting unique id. We override in tests to get consistent ids.
   * @param {string} prefix
   * @returns {string}
   */
  protected uniqueIdFunction(prefix?:string):string {
    return _.uniqueId(prefix)
  }

  protected strategy(state:this)  {
    let testTab = state.activeTab ? state.activeTab.previous : null;
    while (testTab)
    {
      if (testTab.enabled)
      {
        state.activeTab = testTab;
        return
      }
      testTab = testTab.previous
    }
    state.activeTab = _.first(state.panels)
  };
}

export abstract class AbstractTabPanelState {
  @observable parent: AbstractTabComponentState;
  @observable id: string;
  @observable tabName: string;
  @observable label: string;

  @observable letterNavigationText: string;

  @observable node: any;

  abstract get enabled(): boolean

  @computed
  get active(): boolean {
    return this.parent.activeTab === this
  }

  @computed
  get previous(): this {
    if (!this.parent || !this.parent.panels)
      return null;
    const index = _.findIndex(this.parent.panels, (i) => i == this);
    if (index === null) {
      // return null but we have a problem here
      return null
    }
    if (index === 0) {
      // there is no previous one because we're first!
      return null;
    }

    return this.parent.panels[index - 1] as this
  }

  @computed
  get next(): this {
    if (!this.parent || !this.parent.panels)
      return null;

    const index = _.findIndex(this.parent.panels, (i) => i == this);
    const panelLength = this.parent.panels.length;
    if (index === null) {
      // return null but we have a problem here
      return null;
    }

    if (index + 1 >= panelLength) {
      //we have no advanced
      return null;
    }

    return this.parent.panels[index + 1] as this
  }

  before(tab: this): boolean {
    let testItem: this = this;
    while (testItem.next != tab) {
      if (!testItem.next)
        return false;
      testItem = testItem.next
    }

    return true
  }


  after(tab: this): boolean {
    let testItem: this = this;
    while (testItem.previous != tab) {
      if (!testItem.previous)
        return false;
      testItem = testItem.previous;
    }

    return true
  }
}