// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {shallow} from 'enzyme'
import toJson from 'enzyme-to-json'
import LabeledFieldComponent from './LabeledFieldComponent'

describe('LabeledFieldComponent', () => {
  test('In Error with Children', () => {
    let result = shallow(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={true}
                                                error={"errorMessage"}>
      <hr/>
    </LabeledFieldComponent>)
    expect(toJson(result)).toMatchSnapshot()
  })

  test('has error checked but no message so not really in error', () => {
    let result = shallow(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={true} error={null}>
      <hr/>
    </LabeledFieldComponent>)
    expect(toJson(result)).toMatchSnapshot()
  })

  test('no error', () => {
    let result = shallow(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={false}>
      <hr/>
    </LabeledFieldComponent>)
    expect(toJson(result)).toMatchSnapshot()
  })

  test('add extra classNames', () => {
    let result = shallow(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={false}
                                                className={"a_class another_class"}>
      <hr/>
    </LabeledFieldComponent>)
    expect(toJson(result)).toMatchSnapshot()
  })
})