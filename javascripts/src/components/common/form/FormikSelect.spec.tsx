// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import { FormikCurrencyInput } from './FormikCurrencyInput'
import { mount, ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../../lib/tests/helpers';
import HoudiniFormik from '../HoudiniFormik';
import { Formik } from 'formik';
import { HoudiniField } from '../../../lib/houdini_form';
import { HoudiniFormikField } from './HoudiniFormikField';
import { Money } from '../../../lib/money';
import FormikSelect from './FormikSelect';
describe('FormikSelect', () => {
  //select items: one, two, three,
  // example: no value
  // are all unselected?
  // describe: manually select two
  // is two selected

  // example: value = one
  // describe: select two
  // is two selected
  const options = [{ value: 'one', label: 'Uno' }, { value: 'two', label: "Dos" }, { value: 'three', label: 'Tres' }]

  describe('no passed in value equals no selection', () => {
    let root: ReactWrapper
    let formikSelect: ReactWrapper
    let houdiniFormik: ReactWrapper
    let houdiniFormikComponent: Formik<{ test?: string }>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik
        initialValues={
          {
          }}
        onSubmit={() => { }}
        render={(form) => {
          return <HoudiniFormikField component={FormikSelect} name="test" options={options} />
        }}
      />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikSelect = root.find('FormikSelect')
    })

    it('matches snapshot', () => {
      expect(houdiniFormikComponent.getFormikBag().values.test).toBeUndefined()
    })

    describe('select two', () => {
      beforeEach(() => {
        formikSelect.simulate('change', { target: { id: 'test', value: 'two' } })
      })

      it('has two selected', () => {
        expect(houdiniFormikComponent.getFormikBag().values.test).toBe('two')
      })
    })

  })

  describe('passed in value of one', () => {
    let root: ReactWrapper
    let formikSelect: ReactWrapper
    let houdiniFormik: ReactWrapper
    let houdiniFormikComponent: Formik<{ test?: string }>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik
        initialValues={
          {
            test: 'one'
          }}
        onSubmit={() => { }}
        render={(form) => {
          return <HoudiniFormikField component={FormikSelect} name="test" options={options} />
        }}
      />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikSelect = root.find('FormikSelect')
    })

    it('has one selected', () => {
      expect(houdiniFormikComponent.getFormikBag().values.test).toBe('one')
    })

    describe('select two', () => {
      beforeEach(() => {
        formikSelect.simulate('change', {
          target: {
            id: 'test', value: 'two'
          }
        })
      })

      it('has two selected', () => {

        expect(houdiniFormikComponent.getFormikBag().values.test).toBe('two')
      })

    })

  })
})