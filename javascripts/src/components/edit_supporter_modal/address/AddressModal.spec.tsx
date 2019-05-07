// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import _ = require('lodash');
import { mountWithIntl } from '../../../lib/tests/helpers';
import AddressModal, { AddressModalProps } from './AddressModal';
import { ReactWrapper } from 'enzyme';
import { ModalProps } from '../../common/modal/Modal';
import { ModalManager } from '../../common/modal/modal_manager';
import { Provider } from 'mobx-react';
import { supporterEntity } from './supporter_entity_mock';
import { SupporterEntity } from '../supporter_entity';


describe('AddressModal', () => {
  let pane:ReactWrapper

  function instance(): React.Component<AddressModalProps, {}> {
    return pane.find('AddressModal').instance() as any
  }

  function modalComponent(): React.Component<ModalProps, {}> {
    return pane.find('Modal').first().instance()
  }
  
  function getSaveButton(): ReactWrapper {
    return pane.find('ModalFooter').find('Button').filterWhere(i => i.text() === 'Save')
  }

  function getDeleteButton(): ReactWrapper {
    return pane.find('ModalFooter').find('Button').filterWhere(i => i.text() === 'Delete')
  }

  function getCloseButton(): ReactWrapper {
    return pane.find('ModalFooter').find('Button').filterWhere(i => i.text() === 'Close')
  }

  function getFormikCheckbox(): ReactWrapper {
    return pane.find('FormikCheckbox').find('input')
  }
  
  describe('handles an add', () => {
    const initialAddress = {}
    let onClose: jest.Mock
    const titleText = "Edit Address"
    beforeEach(() => {
      onClose = jest.fn()
      let entity = supporterEntity()
      pane = mountWithIntl(<Provider ModalManager={new ModalManager()}><AddressModal initialAddress={initialAddress}
        onClose={onClose} modalActive={true} titleText={titleText} supporterEntity={entity as SupporterEntity}
      /></Provider>)
      pane.mount()
    })

    it("modal title text is EditAddress", () => {
      expect(modalComponent().props.titleText).toBe(titleText)
    })

    it('save button doesnt exist', () => {
      expect(getSaveButton().exists()).toBeTruthy()
      expect(getSaveButton().prop('disabled')).toBeTruthy()
    })

    it('delete button doesnt exist', () => {
      expect(getDeleteButton().exists()).toBeFalsy()
    })

    it('close button exists and enabled', () => {
      expect(getCloseButton().exists()).toBeTruthy()

      expect(getCloseButton().prop('disabled')).toBeFalsy()
    })

    it("modifying set default doesnt make it save button work", () => {
      getFormikCheckbox().simulate('change', {target: {value: true}})

      expect(getSaveButton().prop('disabled')).toBeTruthy()
    })

    it("modifying an input does make save button work", () => {
      pane.find('input').filterWhere((w) => w.prop('name') === 'address').simulate('change', {target: {name: 'address', value: 'me'}})

      expect(getSaveButton().prop('disabled')).toBeFalsy()
    })

  })
  
})