// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {FormikCurrencyInput}from './FormikCurrencyInput'
import { mount, ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../../lib/tests/helpers';
import HoudiniFormik from '../HoudiniFormik';
import { Formik } from 'formik';
describe('FormikCurrencyInput', () => {
  describe('empty initial item', () => {
    let root:ReactWrapper
    let formikCurrencyInput:ReactWrapper
    let houdiniFormik:ReactWrapper
    let houdiniFormikComponent:Formik<{test?:{value?:number, maskedValue?:string}}>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik 
        initialValues={
          {
            test: {
            value: 2222
          }
        }}
        onSubmit={() => {}}
        render={(form) => {
          return <FormikCurrencyInput name={'test'}/>
        }}
        />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikCurrencyInput = root.find('FormikCurrencyInput')

      let s = formikCurrencyInput.find('input') as any
      s.simulate('focus')
      s.simulate('blur')
    })

    it('has a value of $2,222.00 in the input field', () => {
      expect(formikCurrencyInput.find('input').prop('value')).toBe('$2,222.00')
    })

    it('has a value of 2222 in the formik value', () => {
      
      expect(houdiniFormikComponent.state.values.test.value).toBe(2222)
    })

    it('has a value of 2222 in the formik masked value', () => {
      expect(houdiniFormikComponent.state.values.test.maskedValue).toBe('$22.22')
    })
  })
  
})