// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {Wizard} from './Wizard'
import {WizardState, WizardTabPanelState} from "./wizard_state";
import {Form} from "mobx-react-form";
import {action, computed, observable} from 'mobx';
import {ReactWrapper} from 'enzyme';
import {WizardPanel} from "./WizardPanel";

import {mountForMobxWithIntl, runTestsOnConditions, TriggerAndAction} from "../test/react_test_helpers";
import {UniqueIdMock} from "../test/unique_id_mock";

let uniqueIdMock = new UniqueIdMock();
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

  uniqueIdFunction(prefix?:string) {
    return uniqueIdMock.uniqueId.bind(uniqueIdMock)(prefix);
  }

  focusFunction(panel:MockableTabPanelState){
    this.wrapperForFocus.find(`#${panel.id}`).hostNodes().prop('onFocus')(null)
  }

  wrapperForFocus: ReactWrapper;

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

  beforeEach(() => {
    uniqueIdMock.reset()
  });



  let state:EasyWizardState = null
  let tab1: MockableTabPanelState, tab2: MockableTabPanelState, tab3 : MockableTabPanelState = null
  let wrapper: ReactWrapper;
  let disabledTabs: boolean = false

  beforeEach(() => {
    state = new EasyWizardState()
    state.addTab({tabName: data.tab1.tabName, label: data.tab1.label, tabFieldDefinition: data.tab1.subFormDef});
    state.addTab({tabName: data.tab2.tabName, label: data.tab2.label, tabFieldDefinition: data.tab2.subFormDef});
    state.addTab({tabName: data.tab3.tabName, label: data.tab3.label, tabFieldDefinition: data.tab3.subFormDef});
    state.initialize()
    tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
    tab1.setValid(true)
    tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState)
    tab2.setValid(true)
    tab3 = (state.tabsByName[data.tab3.tabName] as MockableTabPanelState)
    wrapper = mountForMobxWithIntl({state:state, disabledTabs: disabledTabs}, (props) => {
      return <Wizard wizardState={props.state} disableTabs={props.disabledTabs}>
        {
          props.state.panels.map((tab:any) => {
            return <WizardPanel tab={tab}>
              <button onClick={tab.parent.moveToNextTab}/>
            </WizardPanel>
          })
        }
      </Wizard>

    })
    state.wrapperForFocus = wrapper

  })

  it('first tab is active', (done) => {
    //if disabledTabs changed, we change
    runTestsOnConditions(new TriggerAndAction(
      () => disabledTabs || !disabledTabs,
      () => {
        wrapper.instance().forceUpdate();
        wrapper.update();
        expect(wrapper.debug()).toMatchSnapshot();
        done();
      }))
    disabledTabs = false

  })

  describe('go to the second tab', () => {
    let commonCondition:any
    beforeEach(() => {
      commonCondition = (done: Function) => {
        runTestsOnConditions(new TriggerAndAction(
          () => state.activeTab.tabName == data.tab2.tabName,
          () => {
            wrapper.instance().forceUpdate();
            wrapper.update();
            expect(wrapper.debug()).toMatchSnapshot();
            done();
          }))
      }
    })

    it('set via tab click', (done) => {
      commonCondition(done);
      let secondTab = wrapper.find('#tab2');

      secondTab.hostNodes().simulate('focus');
    })

    it('set via next click', (done) => {
      commonCondition(done);
      let button = wrapper.find('button').at(0);
      button.hostNodes().simulate('click');
    })

    it('go to next via backend', (done) => {
      commonCondition(done);
      state.moveToTab(state.tabsByName[data.tab2.tabName].id);

    })
  })

  describe('Move back on disabled', () => {

    function waitingOnWhatTabName(tabName:string, done:any){
      runTestsOnConditions({
          finishCondition: () => state.activeTab.tabName == data.tab3.tabName,
          action: () => {
            wrapper.instance().forceUpdate();
            wrapper.update();
          }
        },
        {
          finishCondition: () => state.activeTab.tabName == tabName,
          action: () => {
            wrapper.instance().forceUpdate();
            wrapper.update();
            expect(wrapper.debug()).toMatchSnapshot();
            done();
          }
        })
    }


    it('make second invalid so move back there', (done) => {
      waitingOnWhatTabName(data.tab2.tabName, done)
      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
      tab1.setValid(true)
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState)
      tab2.setValid(true)
      tab3 = (state.tabsByName[data.tab3.tabName] as MockableTabPanelState)

      state.focusTab(state.tabsByName[data.tab3.tabName].id)

      tab2.setValid(false)
    })

    it('make first invalid so move back there', (done) => {
      waitingOnWhatTabName(data.tab1.tabName, done)
      tab1 = (state.tabsByName[data.tab1.tabName] as MockableTabPanelState)
      tab1.setValid(true)
      tab2 = (state.tabsByName[data.tab2.tabName] as MockableTabPanelState)
      tab2.setValid(true)
      tab3 = (state.tabsByName[data.tab3.tabName] as MockableTabPanelState)

      state.focusTab(state.tabsByName[data.tab3.tabName].id)
      wrapper.instance().forceUpdate();
      wrapper.update();
      expect(state.activeTab.tabName).toEqual(data.tab3.tabName)
      tab1.setValid(false)
      wrapper.instance().forceUpdate();
      wrapper.update();
      expect(wrapper.debug()).toMatchSnapshot();

    })
  })

})