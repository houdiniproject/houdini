// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import AddressPane, { addressPaneFormSubmission, TIMEOUT_ERROR_MESSAGE } from './AddressPane'
import * as _ from 'lodash';
import { ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../lib/tests/helpers';
import { Provider } from 'mobx-react';
import { Address, TimeoutError, NotFoundErrorException, PostSupporterSupporterIdAddress, PutSupporterSupporterIdAddress } from '../../../api';
import { SupporterEntity } from './supporter_entity';
import toJson from 'enzyme-to-json';

jest.mock('lodash', () => ({
  ...(jest as any).requireActual('lodash'),
  uniqueId: () => "1",
}));

describe('AddressPane', () => {


  




  describe('component renders', () => {
    function getAddButton() {
      return (() => pane)().find('Button').filterWhere((i) => i.text() === 'Add')
    }

    function getCloseButton() {
      return (() => pane)().find('Button').filterWhere((i) => i.text() === 'Close')
    }

    function getSaveButton() {
      return (() => pane)().find('Button').filterWhere((i) => i.text() === 'Save')
    }

    function getDeleteButton() {
      return (() => pane)().find('Button').filterWhere((i) => i.text() === 'Delete')
    }

    function getFormNotificationBlock() {
      return (() => pane)().find('FormNotificationBlock').filterWhere((i) => i.text() === serverErrorText)
    }


    function getInputByName( name: string) {
      return (() => pane)().find('input').filterWhere(i => i.prop('id') === "1---" + name)
    }


    let pane: ReactWrapper

    describe('renders on add', () => {
      
      beforeEach(() => {
        pane = mountWithIntl(<Provider LocalRootStore={rootStore()}>
          <AddressPane
            initialAddress={{ supporter: { id: 1 } }}
            onClose={onClose}
          /></Provider>, AddressPane)
      })

      it('has add button', () => {
        expect(getAddButton().exists()).toBeTruthy()
      })

      it('has close button', () => {
        expect(getCloseButton().exists()).toBeTruthy()
      })

      it('has disabled add button', () => {
        expect(getAddButton().prop('disabled')).toBeTruthy()
      })

      it('has no delete button', () => {
        expect(getDeleteButton().exists()).toBeFalsy()
      })

      it('has enabled close button', () => {
        getCloseButton().simulate('click')
        expect(onClose).toBeCalled()
      })

      it('on default doesnt let submission happen', () => {
        getInputByName( 'isDefault').simulate('change', {
          persist: () => { },
          target: {
            name: 'isDefault',
            value: true
          }
        })


        pane.update()
        expect(getAddButton().prop('disabled')).toBeTruthy()
      })

      it('change to city does let submission happen', () => {
        getInputByName('city').simulate('change', {
          persist: () => { },
          target: {
            name: 'city',
            value: 'wheeee'
          }
        })


        pane.update()
        expect(getAddButton().prop('disabled')).toBeFalsy()
      })
    })

    describe('renders on save properly', () => {
      beforeEach(() => {
        pane = mountWithIntl(<Provider LocalRootStore={rootStore()}>
          <AddressPane
            initialAddress={{ id: 1, address: 'addy', city: 'city', state_code: "WI", zip_code: '543', country: '3', supporter: { id: 1 } }} onClose={onClose} /></Provider>, AddressPane)
      })

      it('preloads the address correctly', () => {
        expect(getInputByName('address').prop('value')).toBe('addy')
        expect(getInputByName('city').prop('value')).toBe('city')
        expect(getInputByName('state_code').prop('value')).toBe('WI')
        expect(getInputByName('zip_code').prop('value')).toBe('543')
        expect(getInputByName('country').prop('value')).toBe('3')
      })

      it('has save button', () => {
        expect(getSaveButton().exists()).toBeTruthy()
      })

      it('has close button', () => {
        expect(getCloseButton().exists()).toBeTruthy()
      })

      it('has disabled Save button', () => {
        getSaveButton().simulate('click')

        expect(onClose).not.toBeCalled()
      })

      it('has no delete button', () => {
        expect(getDeleteButton().exists()).toBeTruthy()
      })

      it('has enabled close button', () => {
        getCloseButton().simulate('click')
        expect(onClose).toBeCalled()
      })
    })

    describe('is it modified enough to submit', () => {
      beforeEach(() => {
        pane = mountWithIntl(<Provider LocalRootStore={rootStore()}>
          <AddressPane
            initialAddress={{ id: 1, address: 'addy', city: 'city', state_code: "WI", zip_code: '543', country: '3', supporter: { id: 1 } }} onClose={onClose} /></Provider>, AddressPane)

      })

      it('modify address', () => {
        getInputByName('address').simulate('change', {
          persist: () => { },
          target: {
            name: 'address',
            value: 'new'
          }
        })

        pane.update()

        expect(getSaveButton().prop('disabled')).toBeFalsy()
      })
    })
  })
})

