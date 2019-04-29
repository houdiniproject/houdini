// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import AddressModalForm, { addressPaneFormSubmission, TIMEOUT_ERROR_MESSAGE } from './AddressModalForm'
import { Address, TimeoutError, PostSupporterSupporterIdAddress, PutSupporterSupporterIdAddress, NotFoundErrorException } from '../../../api';
import _ = require('lodash');
import { SupporterEntity } from './supporter_entity';

describe('AddressModalForm', () => {
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
})