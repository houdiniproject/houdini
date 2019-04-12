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


  let onClose: jest.Mock<{}>
  const serverErrorText = "some server error is errored"
  beforeEach(() => {
    onClose = jest.fn()
  })

  let supporters: number[] = [1]
  let addresses: Address[] = [{ id: 1 }, { id: 2 }]
  const TIMEOUT_CAUSING_ID = 999999
  const TIMEOUT_CAUSING_STREET = 'time outer'

  function createMockStore<T>(type: { new(): T }, mockApi: () => Partial<T>) {
    return mockApi
  }
  function mockStoreCreator() {

    return createMockStore(SupporterEntity, () => {
      return {
        deleteAddress:
          jest.fn<JQueryPromise<Address>>(
            (crm_address_id: number) => {
              return new Promise((resolve, reject) => {
                if (crm_address_id === TIMEOUT_CAUSING_ID)
                  reject(new TimeoutError())
                else {
                  const address = _.find(addresses, (i) => i.id === crm_address_id)
                  if (!address) {
                    reject(new NotFoundErrorException({}))
                  }
                  else {
                    resolve(address)
                  }
                }
              })
            }),
        createAddress:
          jest.fn<JQueryPromise<Address>>(
            (address: PostSupporterSupporterIdAddress) => {
              return new Promise((resolve, reject) => {
                if (address.address === TIMEOUT_CAUSING_STREET) {
                  reject(new TimeoutError())
                }

                else {
                  resolve(address)
                }
              })
            }),

        updateAddress:
          jest.fn<JQueryPromise<Address>>(
            (crm_address_id: number, putCommand: PutSupporterSupporterIdAddress) => {
              return new Promise((resolve, reject) => {
                if (putCommand.address === TIMEOUT_CAUSING_STREET)
                  reject(new TimeoutError())
                else {
                  const address = _.find(addresses, (i) => i.id === crm_address_id)
                  if (!address) {
                    reject(new NotFoundErrorException({}))
                  }

                  else {
                    resolve({ ...putCommand, ...{ id: crm_address_id } })
                  }
                }
              })
            })
      }
    })()
  }

  function rootStore() {
    return {
      supporterAddressStore: mockStoreCreator()
    }
  }

  describe('addressPaneFormSubmission', () => {

    let setFieldValue: jest.Mock<{}>

    let setStatus: jest.Mock<{}>
    let commonValues: any
    beforeEach(() => {
      setFieldValue = jest.fn()
      setStatus = jest.fn()
      let store = rootStore()
      commonValues = {
        action: jest.fn(() => { return { setFieldValue: setFieldValue, setStatus: setStatus } })(),
        supporterAddressStore: jest.fn(() => store.supporterAddressStore)(), onClose: onClose
      }

    })

    describe('new address', () => {
      const values = { address: '' }
      describe('has succeeded', () => {
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('has fired onClose with the new object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'add', address: values })
          done()
        })

        it('has set status with correct id', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ })
          done()
        })
      })

      describe('timed out', () => {
        let values = {address: TIMEOUT_CAUSING_STREET}
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })
        
        it('error is properly set', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({form: TIMEOUT_ERROR_MESSAGE})
          done()
        })
      })
    })

    describe('update address', () => {
      
      describe('has succeeded', () => {
        const values = { address: '', id: 1 }
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('has fired onClose with the updated object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'update', address: values })
          done()
        })

        it('has set status with correct id', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({})
          done()
        })
      })
      describe('timed out', () => {
        let values = {id: TIMEOUT_CAUSING_ID, address:TIMEOUT_CAUSING_STREET}
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('error is properly set', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({id:undefined, form: TIMEOUT_ERROR_MESSAGE})
          done()
        })
      })
    })

    describe('delete address', () => {
      const values = { address: '', id: 1, shouldDelete: true }
      describe('has successed', () => {
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('has fired onClose', () => {
          
        })

        it('has fired onClose with the delete object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'delete', address: { id: 1 } })
          done()
        })

        it('has set status with correct id', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ id: undefined })
          done()
        })

        it('shouldDelete was properly reset', (done) => {
          expect(setFieldValue).toBeCalledWith('shouldDelete', false)
          done()
        })
      })

      describe('timed out', () => {
        let values = {id: TIMEOUT_CAUSING_ID, shouldDelete:true}
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('shouldDelete was properly reset', (done) => {
          expect(setFieldValue).toBeCalledWith('shouldDelete', false)
          done()
        })
        
        it('error is properly set', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({id:undefined, form: TIMEOUT_ERROR_MESSAGE})
          done()
        })
      })
    })
  })




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

