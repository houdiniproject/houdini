// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import {FormikCurrencyInput}from './FormikCurrencyInput'
import { mount, ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../../lib/tests/helpers';
import HoudiniFormik from '../HoudiniFormik';
import { Formik } from 'formik';
import { HoudiniField } from '../../../lib/houdini_form';
import { HoudiniFormikField } from './HoudiniFormikField';
import { Money } from '../../../lib/money';
describe('FormikCurrencyInput', () => {

  describe('empty amount passed in gives values of zero in formik and input', () => {
    let root:ReactWrapper
    let formikCurrencyInput:ReactWrapper
    let houdiniFormik:ReactWrapper
    let houdiniFormikComponent:Formik<{test?:Money}>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik 
        initialValues={
          {
          test: Money.fromCents(0, 'usd')
        }}
        onSubmit={() => {}}
        render={(form) => {
          return <HoudiniFormikField component={FormikCurrencyInput} name="test"/>
        }}
        />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikCurrencyInput = root.find('FormikCurrencyInput')

      let s = formikCurrencyInput.find('input') as any
      s.simulate('focus')
      s.simulate('blur')
    })

    it('has a value of 0.00 in the input field', () => {
      expect(formikCurrencyInput.find('input').prop('value')).toBe('$0.00')
    })

    it('has a value of 0 in the formik value', () => {
      expect(houdiniFormikComponent.state.values.test.amountInCents).toBe(0)
    })
  })
  
  describe('passed in amount is handled properly', () => {
    let root:ReactWrapper
    let formikCurrencyInput:ReactWrapper
    let houdiniFormik:ReactWrapper
    let houdiniFormikComponent:Formik<{test?:Money}>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik 
        initialValues={
          {
            test: {
              amountInCents: 222200,
              currency: 'usd'
          }
        }}
        onSubmit={() => {}}
        render={(form) => {
          return <HoudiniFormikField component={FormikCurrencyInput} name="test"/>
        }}
        />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikCurrencyInput = root.find('FormikCurrencyInput')

      let s = formikCurrencyInput.find('input') as any
      s.simulate('focus')
      s.simulate('blur')
    })

    it('has a value of 2222.00 in the input field', () => {
      expect(formikCurrencyInput.find('input').prop('value')).toBe('$2,222.00')
    })

    it('has a value of 2222 in the formik value', () => {
      expect(houdiniFormikComponent.state.values.test.amountInCents).toBe(222200)
    })
  })
  
})