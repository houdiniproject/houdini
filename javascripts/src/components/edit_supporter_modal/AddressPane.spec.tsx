// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import AddressPane from './AddressPane'
import { SupporterApi, Address, PostSupporterSupporterIdAddress, TimeoutError, PutSupporterSupporterIdAddress } from '../../../api';
import * as _ from 'lodash';
import { NotFoundErrorException } from '../../../api/model/NotFoundError';
import { waitForMobxCondition } from '../common/test/react_test_helpers';
import { ReactWrapper } from 'enzyme';
import { ApiManager } from '../../lib/api_manager';
import { mountWithIntl } from '../../lib/tests/helpers';

function createMockApiManager(types: [{ type: any, mockApi: Function }]) {
  return jest.fn<ApiManager>(() => {
    return {
      get: jest.fn(
        (c) => {
          return _.find(types, (i) => i.type === c)
        }
      )
    }
  })
}



describe('AddressPane', () => {
  let supporters: number[]
  let addresses: Address[] = [{ id: 1 }, { id: 2 }]
  const TIMEOUT_CAUSING_ID = 999999
  const TIMEOUT_CAUSING_STREET = 'time outer'

  function createApiManager(types: [{ type: any, mockApi: Function }]) {

    return jest.fn<ApiManager>(() => {
      return {
        get: jest.fn(
          (c) => {
            return _.find(types, (i) => i.type === c).mockApi()
          }
        )
      }
    })
  }

  function apiManagerCreator() {
    return createApiManager([{
      type: SupporterApi,
      mockApi: () => {
        return {
          deleteCrmAddress:
            jest.fn<JQueryPromise<Address>>(
              (supporter_id: number, crm_address_id: number) => {
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
          createCrmAddress:
            jest.fn<JQueryPromise<Address>>(
              (supporter_id: number, address: PostSupporterSupporterIdAddress) => {
                return new Promise((resolve, reject) => {
                  if (address.address === TIMEOUT_CAUSING_STREET) {
                    reject(new TimeoutError())
                  }

                  else {
                    resolve(address)
                  }
                })
              }),

          updateCrmAddress:
            jest.fn<JQueryPromise<Address>>(
              (supporter_id: number, crm_address_id: number, putCommand: PutSupporterSupporterIdAddress) => {
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
      }
    }])()
  }




  describe('new address', () => {



    let address: ReactWrapper
    let addressAction = jest.fn()
    beforeEach(() => {
      const apiManager = apiManagerCreator()
      address = mountWithIntl(<AddressPane
        nonprofitId={0}
        initialAddress={{
          supporter: {
            id: 1
          }
        }}
        ApiManager={apiManager}
        onClose={addressAction}
      />
      )
    })

    function getForm() {
      return (address.find("AddressPane").instance() as any).getForm()
    }


    it('has an add button', () => {

      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Add').exists()).toBeTruthy()

    })

    it('has close button', () => {
      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Close').exists()).toBeTruthy()
    })

    it('has no delete button', () => {
      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Delete').exists()).toBeFalsy()
    })

    it('has a default address button', () => {
      let label = address.find('label')
      let defaultAddressLabel = label.filterWhere((l: ReactWrapper) =>
        l.text() === 'Set as Default Address');
      expect(defaultAddressLabel.exists()).toBeTruthy()
    })


    it('has a close button which closes with nothing', () => {
      let closeButton = address.find('button').filterWhere((button: ReactWrapper) => button.text() === 'Close')

      closeButton.simulate('click')

      expect(addressAction).toBeCalledWith({ type: 'none' })
    })


    it('has a disabled add button when nothing entered', () => {

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Add'
          )
      }

      let getDisabledProp = (address: any) => {
        const buttons = address.find('button')
        return findButton(buttons).prop('disabled')
      };
      address.render()

      expect(getDisabledProp(address)).toBeTruthy()

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')

      address_field.set("sinethung")
      address.update()
      expect(getDisabledProp(address)).toBeFalsy()

      address_field.set("")
      address.update()
      expect(getDisabledProp(address)).toBeTruthy();
    })

    it('has disabled add button when set as default address is selected but nothing else', () => {
      let form = getForm()
      let is_default = form.$('is_default')
      is_default.set(true)
      address.update()

      let addButton = address.find('button')
        .filterWhere(
          (button: ReactWrapper) => button.text() === 'Add'
        )

      expect(addButton.prop('disabled')).toBeTruthy()


    })

    it('handles timeout properly', (done) => {

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')
      address_field.set(TIMEOUT_CAUSING_STREET)

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Add'
          )
      }

      address.update()

      findButton(address.find('button')).simulate('click')

      //we're waiting for the submit to finish before updating and checking
      waitForMobxCondition(() => !form.submitting && form.serverError, () => {
        address.update()
        console.log(address.html())
        expect(address.find("FormNotificationBlock").prop('message')).toBe(
          "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
        done()
      }
      )
    })

    it('closes with new added address when successful', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set('good values')

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Add'
          )
      }

      address.update()

      findButton(address.find('button')).simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {
        address.update()
        expect(addressAction).toBeCalledWith({ type: 'add', address: { address: 'good values', city: '', state_code: '', country: '', zip_code: '' }, setToDefault: false })
        done()
      })

    })

    it('closes with new added address when successful and set is_default', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set('good values')

      let is_default = form.$('is_default')
      is_default.set(true)

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Add'
          )
      }



      address.update()

      findButton(address.find('button')).simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {
        address.update()
        expect(addressAction).toBeCalledWith({ type: 'add', address: { address: 'good values', city: '', zip_code: '', state_code: '', country: '' }, setToDefault: true })
        done()
      })

    })
  })

  describe('update address', () => {



    let address: ReactWrapper
    let addressAction = jest.fn()
    beforeEach(() => {
      const apiManager = apiManagerCreator()
      address = mountWithIntl(<AddressPane
        nonprofitId={0}
        initialAddress={{
          id: 1,
          supporter: {
            id: 1
          }
        }}
        ApiManager={apiManager}
        onClose={addressAction}
      />
      )
    })

    function getForm() {
      return (address.find("AddressPane").instance() as any).getForm()
    }


    it('has no add button', () => {

      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Add').exists()).toBeFalsy()

    })

    it('has close button', () => {
      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Close').exists()).toBeTruthy()
    })

    it('has a delete button', () => {
      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Delete').exists()).toBeTruthy()
    })

    it('has an update button', () => {

      let buttons = address.find('button')

      expect(buttons.filterWhere((button: ReactWrapper) => button.text() === 'Save').exists()).toBeTruthy()

    })

    it('has a default address button', () => {
      let label = address.find('label')
      let defaultAddressLabel = label.filterWhere((l: ReactWrapper) =>
        l.text() === 'Set as Default Address');
      expect(defaultAddressLabel.exists()).toBeTruthy()
    })


    it('has a close button which closes with nothing', () => {
      let closeButton = address.find('button').filterWhere((button: ReactWrapper) => button.text() === 'Close')

      closeButton.simulate('click')

      expect(addressAction).toBeCalledWith({ type: 'none' })
    })


    it('has a disabled update button when nothing entered', () => {

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Save'
          )
      }

      let getDisabledProp = (address: any) => {
        const buttons = address.find('button')
        return findButton(buttons).prop('disabled')
      };
      address.render()

      expect(getDisabledProp(address)).toBeTruthy()

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')

      address_field.set("sinethung")
      address.update()
      expect(getDisabledProp(address)).toBeFalsy()

      address_field.set("")
      address.update()
      expect(getDisabledProp(address)).toBeTruthy();
    })

    it('has disabled update button when set as default address is selected but nothing else', () => {
      let form = getForm()
      let is_default = form.$('is_default')
      is_default.set(true)
      address.update()

      let addButton = address.find('button')
        .filterWhere(
          (button: ReactWrapper) => button.text() === 'Save'
        )

      expect(addButton.prop('disabled')).toBeTruthy()

    })

    it('handles timeout properly', (done) => {

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')
      address_field.set(TIMEOUT_CAUSING_STREET)

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Save'
          )
      }

      address.update()

      findButton(address.find('Button')).simulate('click')

      //we're waiting for the submit to finish before updating and checking
      waitForMobxCondition(() => !form.submitting && form.serverError, () => {
        address.update()
        console.log(address.html())
        expect(address.find("FormNotificationBlock").prop('message')).toBe(
          "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
        done()
      }
      )
    })

    it('deletes properly', (done) => {

      let form = getForm()

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Delete'
          )
      }

      findButton(address.find('button')).simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {

        expect(addressAction).toBeCalledWith({ type: 'delete', address: { id: 1, supporter: { id: 1 } } })
        done()
      })
    })

    it('closes with updated address when successful', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set('good values')

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Save'
          )
      }

      address.update()

      findButton(address.find('button')).simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {
        address.update()
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

      let findButton = (buttons: any) => {
        return buttons
          .filterWhere(
            (button: ReactWrapper) => button.text() === 'Save'
          )
      }



      address.update()

      findButton(address.find('button')).simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {
        address.update()
        expect(addressAction).toBeCalledWith({ type: 'update', address: { address: 'good values', city: '', zip_code: '', state_code: '', id: 1, country: '' }, setToDefault: true })
        done()
      })

    })
  })
})

