// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import AddressPane from './AddressPane'
import * as _ from 'lodash';
import { ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../lib/tests/helpers';
import { AddressPaneState } from './address_pane_state';
import { Provider } from 'mobx-react';
import { Field } from 'mobx-react-form';


describe('AddressPane', () => {


  let onClose: jest.Mock<{}>
  let onSubmit: jest.Mock<{}>
  let onDelete: jest.Mock<{}>
  const serverErrorText = "some server error is errored"
  beforeEach(() => {
    onClose = jest.fn()
    onSubmit = jest.fn()
    onDelete = jest.fn()
  })

  interface CreateOptions {
    serverError?: string,
    modifiedEnoughToSubmit?: true
    shouldAdd?: boolean
  }

  function createAddressPane(options: CreateOptions = {}): AddressPaneState {
    return jest.fn<AddressPaneState>(() => {
      return {
        form: {
          $: jest.fn<Field>(() => { return { bind: jest.fn(), set: jest.fn() } }),
          serverError: options.serverError,
          onSubmit: onSubmit
        },
        modifiedEnoughToSubmit: options.modifiedEnoughToSubmit,
        shouldAdd: options.shouldAdd,
        delete: onDelete,
        close: onClose,
      }
    })()
  }

  function getAddButton(pane: ReactWrapper) {
    return pane.find('Button').filterWhere((i) => i.text() === 'Add')
  }

  function getCloseButton(pane: ReactWrapper) {
    return pane.find('Button').filterWhere((i) => i.text() === 'Close')
  }

  function getSaveButton(pane: ReactWrapper) {
    return pane.find('Button').filterWhere((i) => i.text() === 'Save')
  }

  function getFormNotificationBlock(pane: ReactWrapper) {
    return pane.find('FormNotificationBlock').filterWhere((i) => i.text() === serverErrorText)
  }

  let pane: ReactWrapper

  describe('renders on add properly', () => {

    beforeEach(() => {
      pane = mountWithIntl(<Provider LocalRootStore={null}>
        <AddressPane
          initialAddress={null}
          addressPaneState={createAddressPane({ shouldAdd: true })} /></Provider>, AddressPane)
    })

    it('has add button', () => {
      expect(getAddButton(pane).exists()).toBeTruthy()
    })

    it('has close button', () => {
      expect(getCloseButton(pane).exists()).toBeTruthy()
    })

    it('has disabled add button', () => {
      getAddButton(pane).simulate('click')

      expect(onSubmit).not.toBeCalled()
    })

    it('has enabled close button', () => {
      getCloseButton(pane).simulate('click')
      expect(onClose).toBeCalled()
    })
  })

  describe('renders on save properly', () => {

    beforeEach(() => {
      pane = mountWithIntl(<Provider LocalRootStore={null}>
        <AddressPane
          initialAddress={null}
          addressPaneState={createAddressPane()} /></Provider>, AddressPane)
    })

    it('has save button', () => {
      expect(getSaveButton(pane).exists()).toBeTruthy()
    })

    it('has close button', () => {
      expect(getCloseButton(pane).exists()).toBeTruthy()
    })

    it('has disabled Save button', () => {
      getSaveButton(pane).simulate('click')

      expect(onSubmit).not.toBeCalled()
    })

    it('has enabled close button', () => {
      getCloseButton(pane).simulate('click')
      expect(onClose).toBeCalled()
    })
  })

  describe('add with modified enough to submit works', () => {
    beforeEach(() => {
      pane = mountWithIntl(<Provider LocalRootStore={null}>
        <AddressPane
          initialAddress={null}
          addressPaneState={createAddressPane({ shouldAdd: true, modifiedEnoughToSubmit:true })} /></Provider>, AddressPane)
    })

    it('has add button', () => {
      expect(getAddButton(pane).exists()).toBeTruthy()
    })

    it('has close button', () => {
      expect(getCloseButton(pane).exists()).toBeTruthy()
    })

    it('has enabled add button', () => {
      getAddButton(pane).simulate('click')

      expect(onSubmit).toBeCalled()
    })

    it('has enabled close button', () => {
      getCloseButton(pane).simulate('click')
      expect(onClose).toBeCalled()
    })
  })

  describe('save with modified enough to submit works', () => {
    beforeEach(() => {
      pane = mountWithIntl(<Provider LocalRootStore={null}>
        <AddressPane
          initialAddress={null}
          addressPaneState={createAddressPane({ modifiedEnoughToSubmit:true })} /></Provider>, AddressPane)
    })

    it('has add button', () => {
      expect(getSaveButton(pane).exists()).toBeTruthy()
    })

    it('has close button', () => {
      expect(getCloseButton(pane).exists()).toBeTruthy()
    })

    it('has enabled save button', () => {
      getSaveButton(pane).simulate('click')

      expect(onSubmit).toBeCalled()
    })

    it('has enabled close button', () => {
      getCloseButton(pane).simulate('click')
      expect(onClose).toBeCalled()
    })
  })
  describe('server erro', () => {

    
    beforeEach(() => {
      pane = mountWithIntl(<Provider LocalRootStore={null}>
        <AddressPane
          initialAddress={null}
          addressPaneState={createAddressPane({ serverError:serverErrorText })} /></Provider>, AddressPane)
    })
    it('has close button', () => {
      expect(getCloseButton(pane).exists()).toBeTruthy()
    })

    it('has server error shown', () => {
      expect(getFormNotificationBlock(pane).exists()).toBeTruthy()
    })
  })
})

