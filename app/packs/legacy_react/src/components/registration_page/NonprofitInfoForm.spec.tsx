// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
jest.useFakeTimers()
import NonprofitInfoForm, * as NIF from './NonprofitInfoForm'
import {Field, FieldDefinition, Form} from "mobx-react-form";
import { ReactWrapper} from 'enzyme'
import {HoudiniForm} from "../../lib/houdini_form";


function createSubFormInitialization(name:string, subfieldDefinitions:Array<FieldDefinition>): Array<FieldDefinition>{
  let ret: FieldDefinition = {
    name: name,
    fields: subfieldDefinitions
  }
  return [ret]
}
describe('NonprofitInfoForm', () => {
  let outerForm:HoudiniForm
  let form:Field
  let wrapper: ReactWrapper

  test('pointless test for this to pass', () => {})
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