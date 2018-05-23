// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import * as Component from './Wizard'
import {WizardState, WizardTabPanelState} from "./wizard_state";
import {Form} from "mobx-react-form";
import {computed, observable, action} from 'mobx';
import {Wizard} from "./Wizard";
import {shallow} from 'enzyme';
import {WizardPanel} from "./WizardPanel";
import toJson from 'enzyme-to-json';

class MockableTabPanelState extends WizardTabPanelState
{
  @observable
  customIsValid: boolean

  @action.bound
  setValid(validity:boolean){
    this.customIsValid = validity;
  }

  @computed
  get isValid():boolean {
    return this.customIsValid
  }

}

class EasyWizardState extends WizardState{
  constructor(){
    super(MockableTabPanelState)
  }
  createForm(i: any): Form {
    return new Form(i)
  }

}

describe('Wizard', () => {
  let data =
    {
      tab1: {
        tabName: "Tab1",
        label: "Label1",
        subFormDef: {extra: "nothing" }
      },
      tab2: {
        tabName: "Tab2",
        label: "Label2",
        subFormDef: {extra: "not" }
      },
      tab3: {
        tabName: "Tab3",
        label: "Label3",
        subFormDef: {extra: "no3t" }
      },


    }

  let state:EasyWizardState = null
  let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3 : MockableTabPanelState = null

  beforeEach(() => {
    state = new EasyWizardState()
    state.addTab(data.tab1.tabName, data.tab1.label, data.tab1.subFormDef)
    state.addTab(data.tab2.tabName, data.tab2.label, data.tab2.subFormDef)
    state.addTab(data.tab3.tabName, data.tab3.label, data.tab3.subFormDef)
    state.initialize()
    tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
    tab1.setValid(true)
    tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState)
    tab2.setValid(true)
    tab3 = (state.tabsByName[data.tab3.tabName] as MockableTabPanelState)
  })

  function createWizard(disabledTabs:boolean) {
    return <Wizard wizardState={state} disableTabs={disabledTabs}>
      <WizardPanel tab={tab1} />
      <WizardPanel tab={tab2} />
      <WizardPanel tab={tab3} />
    </Wizard>

  }

  test('Mounts the first item only', () => {
    const tree = shallow(createWizard(false) )
    let panels = tree.find(WizardPanel)
    expect(panels.length).toBe(1)
    expect(panels.first().props().tab).toBe(tab1)
  })

  test('Mounts the second tab only', () => {
    state.activateTab(tab2)
    const tree = shallow(createWizard(false) )
    let panels = tree.find(WizardPanel)
    expect(panels.length).toBe(1)
    expect(panels.first().props().tab).toBe(tab2)
  })

  test('Mounts the third tab only', () => {
    state.activateTab(tab2)
    state.activateTab(tab3)
    const tree = shallow(createWizard(false) )
    let panels = tree.find(WizardPanel)
    expect(panels.length).toBe(1)
    expect(panels.first().props().tab).toBe(tab3)
  })

})