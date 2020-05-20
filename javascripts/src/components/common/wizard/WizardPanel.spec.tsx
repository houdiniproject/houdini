// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';

import * as Component from './WizardPanel'

import {Form, Field} from 'mobx-react-form';
import { shallow, render } from 'enzyme';
import toJson from 'enzyme-to-json';
import {WizardState, WizardTabPanelState} from "./wizard_state";

class EasyWizardState extends WizardState{
  constructor(){
    super(WizardTabPanelState)
  }
  createForm(i: any): Form {
    return new Form(i)
  }

}

describe('WizardPanel', () => {
    test('shallow render', () => {
      let fields = [{name: 'fun', id: 'fun', label: 'alsofun'}]
      const form = new Form({fields});

      const ws = new EasyWizardState()
      ws.addTab({tabName:'something', label:'something label',tabFieldDefinition:{} })
      ws.initialize()

      const tree = shallow(<Component.WizardPanel tab={ws.tabsByName['something']} anotherProp={false}><hr/></Component.WizardPanel>)
        
        
      expect(toJson(tree)).toMatchSnapshot()
    })
})