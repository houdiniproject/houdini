// License: LGPL-3.0-or-later
import 'jest';
import { Address, PostSupporterSupporterIdAddress, TimeoutError, PutSupporterSupporterIdAddress } from '../../../api';
import * as _ from 'lodash';
import { NotFoundErrorException } from '../../../api/model/NotFoundError';
import { waitForMobxCondition } from '../common/test/react_test_helpers';
import { SupporterAddressStore } from './supporter_address_store';
import { AddressPaneState } from './address_pane_state';

function createMockStore<T>(type: { new(): T }, mockApi: () => Partial<T>) {
  return mockApi
}

describe('AddressPaneState', () => {
  let supporters: number[]
  let addresses: Address[] = [{ id: 1 }, { id: 2 }]
  const TIMEOUT_CAUSING_ID = 999999
  const TIMEOUT_CAUSING_STREET = 'time outer'

  function mockStoreCreator() {

    return createMockStore(SupporterAddressStore, () => {
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




  describe('new address', () => {



    let addressPaneState: AddressPaneState
    let addressAction = jest.fn()
    beforeEach(() => {
      const mockStore = mockStoreCreator()
      addressPaneState = new AddressPaneState({ supporter: { id: 1 } }, false, { supporterAddressStore: mockStore as SupporterAddressStore }, addressAction)
    })


    it('is an add', () => {

      expect(addressPaneState.isAdd).toBeTruthy()

    })

    it('cannot delete', () => {
      expect(addressPaneState.canDelete).toBeFalsy()
    })


    it('is disabled when nothing entered', () => {


      expect(addressPaneState.modifiedEnoughToSubmit).toBeFalsy()

      let form = addressPaneState.form
      let address_field = form.$('address')

      address_field.set("sinethung")


      expect(addressPaneState.modifiedEnoughToSubmit).toBeTruthy()

      address_field.set("")
      expect(addressPaneState.modifiedEnoughToSubmit).toBeFalsy()
    })

    it('has disabled add button when set as default address is selected but nothing else', () => {
      let form = addressPaneState.form
      let is_default = form.$('is_default')
      is_default.set(true)


      expect(addressPaneState.modifiedEnoughToSubmit).toBeFalsy()
    })

    it('handles timeout properly', (done) => {

      let form = addressPaneState.form
      let address_field = form.$('address')
      address_field.set(TIMEOUT_CAUSING_STREET)

      form.submit()

      //we're waiting for the submit to finish before updating and checking
      waitForMobxCondition(() => !form.submitting && form.serverError, () => {


        expect(form.serverError).toBe(
          "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
        done()
      }
      )
    })

    it('closes with new added address when successful', (done) => {
      let form = addressPaneState.form
      let address_field = form.$('address')
      address_field.set('good values')

      form.submit()

      waitForMobxCondition(() => !form.submitting, () => {

        expect(addressAction).toBeCalledWith({ type: 'add', address: { address: 'good values', city: '', state_code: '', country: '', zip_code: '' }, setToDefault: false })
        done()
      })

    })

    it('closes with new added address when successful and set is_default', (done) => {
      let form = addressPaneState.form
      let address_field = form.$('address')
      address_field.set('good values')

      let is_default = form.$('is_default')
      is_default.set(true)


      form.submit()

      waitForMobxCondition(() => !form.submitting, () => {

        expect(addressAction).toBeCalledWith({ type: 'add', address: { address: 'good values', city: '', zip_code: '', state_code: '', country: '' }, setToDefault: true })
        done()
      })

    })
  })

  describe('update address', () => {

    let addressPaneState: AddressPaneState
    let addressAction = jest.fn()
    beforeEach(() => {
      const mockStore = mockStoreCreator()
      addressPaneState = new AddressPaneState({
        id: 1,
        supporter: {
          id: 1
        }
      }, false, { supporterAddressStore: mockStore as SupporterAddressStore }, addressAction)

    })

    function getForm() {
      return addressPaneState.form;
    }

    it('is not an add', () => {

      expect(addressPaneState.isAdd).toBeFalsy()

    })

    it('can delete', () => {
      expect(addressPaneState.canDelete).toBeTruthy()
    })

    it('has a disabled update button when nothing entered', () => {
      expect(addressPaneState.modifiedEnoughToSubmit).toBeFalsy()

      let form = getForm()
      let address_field = form.$('address')

      address_field.set("sinethung")


      expect(addressPaneState.modifiedEnoughToSubmit).toBeTruthy()

      address_field.set("")
      expect(addressPaneState.modifiedEnoughToSubmit).toBeFalsy()
    })

    it('has disabled update button when set as default address is selected but nothing else', () => {
      let form = getForm()
      let is_default = form.$('is_default')
      is_default.set(true)
      expect(addressPaneState.modifiedEnoughToSubmit).toBeFalsy()
    })

    it('handles timeout properly', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set(TIMEOUT_CAUSING_STREET)



      form.submit()

      //we're waiting for the submit to finish before updating and checking
      waitForMobxCondition(() => !form.submitting && form.serverError, () => {


        expect(form.serverError).toBe(
          "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
        done()
      }
      )
    })

    it('deletes properly', (done) => {

      let form = getForm()
      addressPaneState.delete()

      waitForMobxCondition(() => !form.submitting, () => {

        expect(addressAction).toBeCalledWith({ type: 'delete', address: { id: 1, supporter: { id: 1 } } })
        expect(addressPaneState.attemptDelete).toBeFalsy()
        done()
      })
    })

    it('closes with updated address when successful', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set('good values')
      form.submit()

      waitForMobxCondition(() => !form.submitting, () => {
        expect(addressAction).toBeCalledWith({ type: 'update', address: { id: 1, address: 'good values', city: '', state_code: '', country: '', zip_code: '' }, setToDefault: false })
        done()
      })

    })

    it('closes with updated address when successful and set is_default', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set('good values')

      let is_default = form.$('is_default')
      is_default.set(true)
      form.submit()

      waitForMobxCondition(() => !form.submitting, () => {
        expect(addressAction).toBeCalledWith({ type: 'update', address: { address: 'good values', city: '', zip_code: '', state_code: '', id: 1, country: '' }, setToDefault: true })
        done()
      })
    })


    describe('handles timeout on delete', () => {
      let addressPaneState: AddressPaneState
      let addressAction = jest.fn()
      beforeEach(() => {
        const mockStore = mockStoreCreator()

        addressPaneState = new AddressPaneState({
          id: TIMEOUT_CAUSING_ID,
          supporter: {
            id: 1
          }
        }, false, { supporterAddressStore: mockStore as SupporterAddressStore }, addressAction)

      })

      function getForm() {
        return addressPaneState.form
      }

      it('it handles delete properly', (done) => {
        let form = getForm()
        addressPaneState.delete()

        waitForMobxCondition(() => !form.submitting && form.serverError, () => {

          expect(form.serverError).toBe(
            "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")

          expect(addressPaneState.attemptDelete).toBeFalsy()
          done()
        })
      })
    })
  })
})


