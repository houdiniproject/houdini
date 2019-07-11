// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import _ = require('lodash');
import { mountWithIntl } from '../../../lib/tests/helpers';
import AddressModal, { AddressModalProps } from './AddressModal';
import { ReactWrapper } from 'enzyme';
import { ModalProps } from '../../common/modal/Modal';
import { ModalManager } from '../../common/modal/modal_manager';

import { supporterEntity } from './supporter_entity_mock';
import { SupporterEntity } from '../supporter_entity';
import { ModalManagerProvider } from '../../common/modal/connect_modal_manager';
import { simulateChange } from '../../../lib/tests/helpers/mounted';

jest.mock('lodash', () => ({
  ...(jest as any).requireActual('lodash'),
  uniqueId: () => "1",
}));

jest.useFakeTimers()



describe('AddressModal', () => {
  let pane:ReactWrapper

  function instance(): React.Component<AddressModalProps, {}> {
    return pane.find('AddressModal').instance() as any
  }

  function modalComponent(): React.Component<ModalProps, {}> {
    return pane.find('HoudiniModal').first().instance() as React.Component<ModalProps, {}>
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
      pane = mountWithIntl(<ModalManagerProvider value={new ModalManager()}>><AddressModal initialAddress={initialAddress}
        onClose={onClose} modalActive={true} titleText={titleText} supporterEntity={entity as SupporterEntity}
      /></ModalManagerProvider>)
      pane.mount()
    })

    it("modal title text is Edit Address", () => {
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

    describe('save button', () => {
      it('is pointing at correct form', () =>{
        expect(getSaveButton().prop('form')).toBe('form---1')
      })

      it('is a submit button', () => {
        expect(getSaveButton().prop('type')).toBe("submit")
      })

      it('doesnt have an onClick set (if onClick set were overriding default form)', () => {
        expect(getSaveButton().prop('onClick')).toBeFalsy()
      })
    })

  it("modifying an input does make save button work", () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')
 
      expect(getSaveButton().prop('disabled')).toBeFalsy()
    })

  })
  
})