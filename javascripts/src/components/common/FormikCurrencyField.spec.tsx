// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import FormikCurrencyField from './FormikCurrencyField'
import { ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../lib/tests/helpers';
import HoudiniFormik from './HoudiniFormik';
import { Formik } from 'formik';
import { FieldCreator } from './form/FieldCreator';
import { Money } from '../../lib/money';

jest.useFakeTimers()
describe('FormikCurrencyField', () => {
  describe('empty item', () => {
    let root: ReactWrapper
    let formikCurrencyInput: ReactWrapper
    let houdiniFormik: ReactWrapper
    let houdiniFormikComponent: Formik<{ test?: Money }>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik
        initialValues={
          {
            test: undefined
          }}
        onSubmit={() => { }}
        render={() => {
          return <FieldCreator component={FormikCurrencyField} name={'test'} />
        }}
      />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikCurrencyInput = root.find('FormikCurrencyInput')
      //since we have a 0 timeout to handle the setValue on mount, we need to run to the timer to make the change update
      jest.runAllTimers()

    })

    it('has a value of in the input field', () => {
      expect(formikCurrencyInput.find('input').prop('value')).toBe('$0.00')
    })

    it('has a value of 0 in the formik value', () => {
      expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(0, 'USD'))
    })
  })

  describe('zero item', () => {
    let root: ReactWrapper
    let formikCurrencyInput: ReactWrapper
    let houdiniFormik: ReactWrapper
    let houdiniFormikComponent: Formik<{ test?: Money }>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik
        initialValues={
          {
            test: Money.fromCents(0, "EUR")
          }}
        onSubmit={() => { }}
        render={() => {
          return <FieldCreator component={FormikCurrencyField} name={'test'} />
        }}
      />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikCurrencyInput = root.find('FormikCurrencyInput')
      jest.runAllTimers()
      let s = formikCurrencyInput.find('input') as any
    })

    it('has a value of in the input field', () => {
      expect(formikCurrencyInput.find('input').prop('value')).toBe('€0.00')
    })

    it('has a value of amount of 0 in the formik value', () => {
      expect(houdiniFormikComponent.state.values.test.amountInCents).toBe(0)
    })

    it('has a currency of amount of EUR in the formik value', () => {
      expect(houdiniFormikComponent.state.values.test.currency).toBe("eur")
    })
  })

  describe('basic item', () => {
    let root: ReactWrapper
    let formikCurrencyInput: ReactWrapper
    let houdiniFormik: ReactWrapper
    let houdiniFormikComponent: Formik<{ test?: Money }>
    beforeEach(() => {
      root = mountWithIntl(<HoudiniFormik
        initialValues={
          {
            test: Money.fromCents(2222, 'usd')
          }}
        onSubmit={() => { }}
        render={() => {
          return <FieldCreator component={FormikCurrencyField} name={'test'} />
        }}
      />)
      houdiniFormik = root.find('Formik')
      houdiniFormikComponent = houdiniFormik.instance() as any
      formikCurrencyInput = root.find('FormikCurrencyInput')
      jest.runAllTimers()
      let s = formikCurrencyInput.find('input') as any
    })

    it('has a value of in the input field', () => {
      expect(formikCurrencyInput.find('input').prop('value')).toBe('$22.22')
    })

    it('has a value of 2222 in the formik value', () => {

      expect(houdiniFormikComponent.state.values.test.amountInCents).toBe(2222)
    })

  })

  describe('allowNegative', () => {
    let root: ReactWrapper
    let formikCurrencyInput: ReactWrapper
    let houdiniFormik: ReactWrapper
    let houdiniFormikComponent: Formik<{ test?: Money }>
    describe('empty input', () => {
      beforeEach(() => {
        root = mountWithIntl(<HoudiniFormik
          initialValues={
            {
              test: undefined
            }}
          onSubmit={() => { }}
          render={() => {
            return <FieldCreator component={FormikCurrencyField} name={'test'} />
          }}
        />)
        houdiniFormik = root.find('Formik')
        houdiniFormikComponent = houdiniFormik.instance() as any
        formikCurrencyInput = root.find('FormikCurrencyInput')
        //since we have a 0 timeout to handle the setValue on mount, we need to run to the timer to make the change update
        jest.runAllTimers()

      })

      it('has a value of in the input field', () => {
        expect(formikCurrencyInput.find('input').prop('value')).toBe('$0.00')
      })

      it('has a value of null in the formik value', () => {
        expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(0, 'USD'))
      })
    })

    describe('putting a negative as input', () => {
      beforeEach(() => {
        root = mountWithIntl(<HoudiniFormik
          initialValues={
            {
              test: undefined
            }}
          onSubmit={() => { }}
          render={() => {
            return <FieldCreator component={FormikCurrencyField} name={'test'} requireNegative={true} />
          }}
        />)
        houdiniFormik = root.find('Formik')
        houdiniFormikComponent = houdiniFormik.instance() as any
        formikCurrencyInput = root.find('FormikCurrencyInput')
        //since we have a 0 timeout to handle the setValue on mount, we need to run to the timer to make the change update
        jest.runAllTimers()

      })

      it('has a value of in the input field', () => {
        expect(formikCurrencyInput.find('input').prop('value')).toBe('$0.00')
      })

      it('has a value of null in the formik value', () => {
        expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(0, 'USD'))
      })

      describe('after change', () => {

        beforeEach(() => {
          formikCurrencyInput.find('input').simulate('change', {target: {value: "400"}})
          jest.runAllTimers()

        })

        it('has a value of -$4.00 in the input field', () => {
          expect(formikCurrencyInput.find('input').getDOMNode().getAttribute('value')).toBe('-$4.00')
        })
  
        it('has a value of null in the formik value', () => {
          expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(-400, 'USD'))
        })

        it('keeps a negative value when simulating a second negative', () => {
          formikCurrencyInput.find('input').simulate('change', {target: {value: "--400"}})
          jest.runAllTimers()
          expect(formikCurrencyInput.find('input').getDOMNode().getAttribute('value')).toBe('-$4.00')
          expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(-400, 'USD'))
        })
      })
    })

    describe('allow negative is false', () => {
      beforeEach(() => {
        root = mountWithIntl(<HoudiniFormik
          initialValues={
            {
              test: undefined
            }}
          onSubmit={() => { }}
          render={() => {
            return <FieldCreator component={FormikCurrencyField} name={'test'} requirePositive={true}/>
          }}
        />)
        houdiniFormik = root.find('Formik')
        houdiniFormikComponent = houdiniFormik.instance() as any
        formikCurrencyInput = root.find('FormikCurrencyInput')
        //since we have a 0 timeout to handle the setValue on mount, we need to run to the timer to make the change update
        jest.runAllTimers()

      })

      it('has a value of $0.00 in the input field', () => {
        expect(formikCurrencyInput.find('input').prop('value')).toBe('$0.00')
      })

      it('has a value of 0 in the formik value', () => {
        expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(0, 'USD'))
      })

      it('converts negatives properly', () => {
        formikCurrencyInput.find('input').simulate('change', {target: {value: "-400"}})
        jest.runAllTimers()

        expect(formikCurrencyInput.find('input').getDOMNode().getAttribute('value')).toBe('$4.00')
        expect(houdiniFormikComponent.state.values.test).toEqual(Money.fromCents(400, 'USD'))
      })
    })
  })
})
