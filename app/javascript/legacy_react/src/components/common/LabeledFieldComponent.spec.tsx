// License: LGPL-3.0-or-later
import * as React from 'react';
import {render} from '@testing-library/react'
import LabeledFieldComponent from './LabeledFieldComponent'

describe('LabeledFieldComponent', () => {
  test('In Error with Children', () => {
    let result = render(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={true}
                                                error={"errorMessage"}>
      <hr/>
    </LabeledFieldComponent>)
    expect(result.baseElement).toMatchSnapshot()
  })

  test('has error checked but no message so not really in error', () => {
    let result = render(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={true} error={undefined}>
      <hr/>
    </LabeledFieldComponent>)
    expect(result.baseElement).toMatchSnapshot()
  })

  test('no error', () => {
    let result = render(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={false}>
      <hr/>
    </LabeledFieldComponent>)
    expect(result.baseElement).toMatchSnapshot()
  })

  test('add extra classNames', () => {
    let result = render(<LabeledFieldComponent inputId={"ID"} labelText={"Our Label"} inError={false}
                                                className={"a_class another_class"}>
      <hr/>
    </LabeledFieldComponent>)
    expect(result.baseElement).toMatchSnapshot()
  })
})