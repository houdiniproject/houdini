// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import AddressPane from './AddressPane'
import { SupporterApi, Address, PostSupporterSupporterIdAddress, TimeoutError, PutSupporterSupporterIdAddress } from '../../../api';
import * as _ from 'lodash';
import { NotFoundErrorException } from '../../../api/model/NotFoundError';
import { waitForMobxCondition } from '../common/test/react_test_helpers';
import { ReactWrapper } from 'enzyme';
import { mountWithIntl, createMockApiManager, createMockApi } from '../../lib/tests/helpers';

describe('AddressPane', () => {
  let supporters: number[]
  let addresses: Address[] = [{ id: 1 }, { id: 2 }]
  const TIMEOUT_CAUSING_ID = 999999
  const TIMEOUT_CAUSING_STREET = 'time outer'

  function apiManagerCreator() {
    return createMockApiManager(createMockApi(SupporterApi, () => {
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
    }))()
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

    function findButton(buttonText:string) {
      let buttons = address.find('button')

      return buttons.filterWhere((button: ReactWrapper) => button.text() === buttonText)
    }


    it('has an add button', () => {

      let buttons = address.find('button')

      expect(findButton('Add').exists()).toBeTruthy()

    })

    it('has close button', () => {
      let buttons = address.find('button')

      expect(findButton('Close').exists()).toBeTruthy()
    })

    it('has no delete button', () => {
      let buttons = address.find('button')

      expect(findButton('Delete').exists()).toBeFalsy()
    })

    it('has a default address button', () => {
      let label = address.find('label')
      let defaultAddressLabel = label.filterWhere((l: ReactWrapper) =>
        l.text() === 'Set as Default Address');
      expect(defaultAddressLabel.exists()).toBeTruthy()
    })


    it('has a close button which closes with nothing', () => {
      findButton('Close').simulate('click')

      expect(addressAction).toBeCalledWith({ type: 'none' })
    })


    it('has a disabled add button when nothing entered', () => {
      address.render()

      expect(findButton('Add').prop('disabled')).toBeTruthy()

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')

      address_field.set("sinethung")
      address.update()
      expect(findButton('Add').prop('disabled')).toBeFalsy()

      address_field.set("")
      address.update()
      expect(findButton('Add').prop('disabled')).toBeTruthy();
    })

    it('has disabled add button when set as default address is selected but nothing else', () => {
      let form = getForm()
      let is_default = form.$('is_default')
      is_default.set(true)
      address.update()

      expect(findButton('Add').prop('disabled')).toBeTruthy()
    })

    it('handles timeout properly', (done) => {

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')
      address_field.set(TIMEOUT_CAUSING_STREET)

      address.update()

      findButton('Add').simulate('click')

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

      address.update()

      findButton('Add').simulate('click')

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

      address.update()

      findButton('Add').simulate('click')

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

    function findButton(buttonText:string) {
      let buttons = address.find('button')

      return buttons.filterWhere((button: ReactWrapper) => button.text() === buttonText)
    }


    it('has no add button', () => {

      let buttons = address.find('button')

      expect(findButton('Add').exists()).toBeFalsy()

    })

    it('has close button', () => {
      let buttons = address.find('button')

      expect(findButton('Close').exists()).toBeTruthy()
    })

    it('has a delete button', () => {
      let buttons = address.find('button')

      expect(findButton('Delete').exists()).toBeTruthy()
    })

    it('has an update button', () => {

      let buttons = address.find('button')

      expect(findButton('Save').exists()).toBeTruthy()

    })

    it('has a default address button', () => {
      let label = address.find('label')
      let defaultAddressLabel = label.filterWhere((l: ReactWrapper) =>
        l.text() === 'Set as Default Address');
      expect(defaultAddressLabel.exists()).toBeTruthy()
    })


    it('has a close button which closes with nothing', () => {
     

      findButton('Close').simulate('click')

      expect(addressAction).toBeCalledWith({ type: 'none' })
    })


    it('has a disabled update button when nothing entered', () => {
      const saveButton = findButton('Save')

      address.render()

      expect(saveButton.prop('disabled')).toBeTruthy()

      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')

      address_field.set("sinethung")
      address.update()
      expect(findButton('Save').prop('disabled')).toBeFalsy()

      address_field.set("")
      address.update()
      expect(saveButton.prop('disabled')).toBeTruthy();
    })

    it('has disabled update button when set as default address is selected but nothing else', () => {
      let form = getForm()
      let is_default = form.$('is_default')
      is_default.set(true)
      address.update()
      expect(findButton('Save').prop('disabled')).toBeTruthy()
    })

    it('handles timeout properly', (done) => {
      let form = (address.find("AddressPane").instance() as any).getForm()
      let address_field = form.$('address')
      address_field.set(TIMEOUT_CAUSING_STREET)
      address.update()
      findButton('Save').simulate('click')

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
      findButton('Delete').simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {
        
        expect(addressAction).toBeCalledWith({ type: 'delete', address: { id: 1, supporter: { id: 1 } } })
        expect((address.instance() as any).attemptDelete).toBeFalsy()
        done()
      })
    })

    describe('handles timeout on delete', () => {
      let address: ReactWrapper
      let addressAction = jest.fn()
      beforeEach(() => {
        const apiManager = apiManagerCreator()
        address = mountWithIntl(<AddressPane
          nonprofitId={0}
          initialAddress={{
            id: TIMEOUT_CAUSING_ID,
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
  
      function findButton(buttonText:string) {
        let buttons = address.find('button')
  
        return buttons.filterWhere((button: ReactWrapper) => button.text() === buttonText)
      }

      it('it handles delete properly', (done) => {
        let form = getForm()
        findButton('Delete').simulate('click')

        waitForMobxCondition(() => !form.submitting && form.serverError, () => {
          address.update()
          expect(address.find("FormNotificationBlock").prop('message')).toBe(
            "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
          
          expect((address.instance() as any).attemptDelete).toBeFalsy()
          done()
        })
      
      })
    })

    it('closes with updated address when successful', (done) => {
      let form = getForm()
      let address_field = form.$('address')
      address_field.set('good values')

      address.update()

      findButton('Save').simulate('click')

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

      address.update()

      findButton('Save').simulate('click')

      waitForMobxCondition(() => !form.submitting, () => {
        address.update()
        expect(addressAction).toBeCalledWith({ type: 'update', address: { address: 'good values', city: '', zip_code: '', state_code: '', id: 1, country: '' }, setToDefault: true })
        done()
      })

    })
  })
})

