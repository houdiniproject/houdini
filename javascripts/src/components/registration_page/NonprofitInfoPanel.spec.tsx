// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';


import { Form} from "mobx-react-form";

import { shallowWithIntl} from "../../lib/tests/helpers";
import {HoudiniForm} from "../../lib/houdini_form";
import {WizardState, WizardTabPanelState} from "../common/wizard/wizard_state";

import toJson from 'enzyme-to-json';
import NonprofitInfoPanel from "./NonprofitInfoPanel";


class EasyWizardState extends WizardState{
  constructor(){
    super(WizardTabPanelState)
  }
  createForm(i: any): Form {
    return new HoudiniForm(i)
  }

}


describe('NonprofitInfoPanel', () => {


  let wiz:WizardState
  test('includes correct elements and attributes', () => {
    wiz = new EasyWizardState()
    wiz.addTab({tabName:'tab1', label:"label", tabFieldDefinition:{}})
    wiz.initialize()

    // let root = shallowWithIntl(<NonprofitInfoPanel buttonText={"Text"} tab={wiz.activeTab}/> )
    // expect(toJson(root)).toMatchSnapshot()

  })
  // beforeEach(() => {
  //   outerForm = new HoudiniForm({fields: createSubFormInitialization('none', NIF.FieldDefinitions)}, {
  //     validateOnInit: true,
  //     validateOnChange: true,
  //     retrieveOnlyDirtyValues: true,
  //     retrieveOnlyEnabledFields: true
  //   });
  //   form = outerForm.$('none')
  // })
  // afterEach(() => {
  //   wrapper.detach();
  // })
  // test('validations', async () => {
  //   wrapper = mountWithIntl(<NonprofitInfoForm form={form} buttonText={"none.none"}/>)
  //   let organization_name = form.$('organization_name')
  //   let city = form.$('city')
  //   let state = form.$('state')
  //
  //   try {
  //     //await organization_name.validate()
  //   }
  //   catch(e){
  //     console.log(e)
  //   }
  //   wrapper.find(`#${organization_name.id}`).simulate('focus')
  //   wrapper.find(`#${organization_name.id}`).simulate('blur')
  //   wrapper.find(`#${state.id}`).simulate('click')
  //   organization_name.focus()
  //   state.focus()
  //
  //   //jest.runTimersToTime(100000);
  //   try {
  //    await organization_name.validate()
  //   }
  //   catch(e){
  //     console.log(e)
  //   }
  //   expect(organization_name.error).toBe(false)
  //   expect(state.hasError).toBe(true)
  //   expect(city.hasError).toBe(true)
  //
  //
  //   console.log(wrapper.html())
  // })
})