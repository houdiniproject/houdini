// License: LGPL-3.0-or-later
import { ReactWrapper } from 'enzyme';
import 'jest';
import * as React from 'react';
import { Supporter } from '../../../api';
import { mountWithIntl } from '../../lib/tests/helpers';
import FormikBasicField from '../common/FormikBasicField';
import FormikHiddenField from '../common/FormikHiddenField';
import { HoudiniFormikProps } from '../common/HoudiniFormik';
import SupporterPane from './SupporterPane';
import _ = require('lodash');
jest.mock('../common/form/FieldCreator')
jest.mock('../common/HoudiniFormik')
describe('SupporterPane', () => {

  function getButtonWithText(wrapper:ReactWrapper, text:string){
    let buttons = wrapper.find('button')

    return buttons.filterWhere((e) =>
      e.text() === text
    )
  }

  function getAddButton(wrapper:ReactWrapper)
  {
    return getButtonWithText(wrapper, 'Add Address')
  }

  function getCloseButton(wrapper:ReactWrapper)
  {
    return getButtonWithText(wrapper, 'Close')
  }

  function getSaveButton(wrapper:ReactWrapper)
  {
    return getButtonWithText(wrapper, 'Save')
  }

  let onCloseAction: any

  let defaultSupporter: Supporter = { id: 1, name: 'fake name', email: 'ema2l@cc', phone: '93912345' }

  let defaultAddressId: number = null
  let updateSupporter: any
  let addButtonClick: any
  let editButtonClick: any
  let handleSubmit: any

  function createFormik(): HoudiniFormikProps<any> {
    return {
      handleSubmit: handleSubmit
    } as HoudiniFormikProps<any>
  }

  beforeEach(() => {
    onCloseAction = jest.fn()
    updateSupporter = jest.fn();
    addButtonClick = jest.fn();
    editButtonClick = jest.fn();
    handleSubmit = jest.fn();

  })

  describe('load proper fields', () => {
    let pane: ReactWrapper
    beforeEach(() => {
      pane = mountWithIntl(
        <SupporterPane addAddress={addButtonClick} editAddress={editButtonClick} formik={createFormik()}
          onClose={onCloseAction} addresses={[{ id: 1, address: 'ehtowhetoweit' }]} isDefaultAddress={() => true}
        />)
    })

    function runFieldTest(component: any, name: string) {
      let fc = pane.find('FieldCreator').filterWhere((w) => w.prop('name') == name)
      expect(fc.prop('component')).toBe(component)
      return fc
    }

    function runBasicFieldTest(component: any, name: string, label?: string) {
      let fc = runFieldTest(component, name)
      if (label)
        expect(fc.prop('label')).toBe(label)
      expect(fc.prop('inputId')).toBe(`1--${name}`)
    }

    function runHiddenFieldTest(component: any, name: string, label?: string) {
      let fc = runFieldTest(component, name)
    }

    it('has correct properties for name', () => {
      runBasicFieldTest(FormikBasicField, 'name', 'Name')
    })

    it('has correct properties for email', () => {
      runBasicFieldTest(FormikBasicField, 'email', 'Email')
    })

    it('has correct properties for phone', () => {
      runBasicFieldTest(FormikBasicField, 'phone', 'Phone')
    })

    it('has correct properties for organization', () => {
      runBasicFieldTest(FormikBasicField, 'organization', 'Organization')
    })

    it('has correct properties for default_id', () => {
      runHiddenFieldTest(FormikHiddenField, 'default_address.id')
    })

    it('will call onClose using the Close button', () => {
      getCloseButton(pane).simulate('click')

      expect(onCloseAction).toBeCalled()
    })

    it('has save button with type submit', () => {
      const button = getSaveButton(pane)

      expect(button.props().type).toBe('submit')
      expect(button.props().disabled).toBeFalsy()
    })
  })

  describe('addresses', () => {
    let pane: ReactWrapper

    beforeEach(() => {
      pane = mountWithIntl(
        <SupporterPane addAddress={addButtonClick} editAddress={editButtonClick} formik={createFormik()}
          onClose={onCloseAction} addresses={[{ id: 1, address: 'ehtowhetoweit' }]} isDefaultAddress={(a) => a === 1}
        />)

    })

    it('runs add address properly', () => {
      getAddButton(pane).simulate('click')

      expect(addButtonClick as jest.Mock<{}>).toBeCalled()
    })


    it('changes on update address properly', () => {
      pane.update()
      pane.find('SelectableTableRow').filterWhere((e) => { return e.key() === '1' }).simulate('click')
      expect(editButtonClick).toBeCalledWith({ id: 1, address: 'ehtowhetoweit' })
    })

    it('has the proper address selected', () => {
      let ourTableRow = pane.find('SelectableTableRow').filterWhere((i) => i.key() === "1")

      expect(ourTableRow.find('Star').exists()).toBeTruthy()

    })

    it('does not have invalid table row selected', () => {
      let ourTableRow = pane.find('SelectableTableRow').filterWhere((i) => i.key() !== "1")
      expect(ourTableRow.find('Star').exists()).toBeFalsy()
    })
  })
})