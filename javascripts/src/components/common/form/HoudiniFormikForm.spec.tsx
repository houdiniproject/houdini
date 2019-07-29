// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import HoudiniFormikForm from './HoudiniFormikForm'
import { ReactWrapper, mount } from 'enzyme';
import { HoudiniFormikProps } from '../HoudiniFormik';

describe('HoudiniFormikForm', () => {
  let handleSubmit = jest.fn()
  let handleReset = jest.fn()
  let formik = {
    handleSubmit:handleSubmit,
    handleReset:handleReset,
    status: {
      id: "1"
    },
    values: {}
  }

  let modal:ReactWrapper

  function getForm(){
    return modal.find('form')
  }

  beforeAll(() => {
    modal = mount(<HoudiniFormikForm formik={formik as any}/>)
  })

  it('has onSubmit properly applied', () => {
    expect(getForm().prop('onSubmit')).toEqual(handleSubmit)
  })

  it('has onReset properly applied', () => {
    expect(getForm().prop('onReset')).toEqual(handleReset)
  })

  it('has correct id', () => {
    expect(getForm().prop('id')).toEqual('form---1')
  })
})