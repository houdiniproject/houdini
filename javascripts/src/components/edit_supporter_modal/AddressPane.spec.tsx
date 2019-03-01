// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import AddressPane, { AddressPaneProps, AddressPaneForm } from './AddressPane'
import { SupporterApi, Address } from '../../../api';
import _ = require('lodash');
import { NotFoundErrorException } from '../../../api/model/NotFoundError';
import { mountForMobxWithIntl, mountForMobx } from '../common/test/react_test_helpers';
import toJson from 'enzyme-to-json';
import { ReactWrapper } from 'enzyme';
import { ApiManager } from '../../lib/api_manager';
import { mountWithIntl } from '../../lib/tests/helpers';

function createMockApiManager(types:[{type:any, mockApi:Function}]) {
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

  function deleteSupporterAddress(ret: any): jest.Mock<SupporterApi> {
    return jest.fn<SupporterApi>(
      () => {
        return {
          deleteCrmAddress:
            jest.fn<JQueryPromise<Address>>(
              (supporter_id: number, crm_address_id: number) => {
                return new Promise((resolve, reject) => {
                  const address = _.find(addresses, (i) => i.id === crm_address_id)
                  if (!address) {
                    reject(new NotFoundErrorException({}))
                  }
                  else {
                    resolve(address)
                  }
                })
              })
        }
      })
  }


  describe('new address', () => {
    

    function createApiManager(types:[{type:any, mockApi:Function}]) {
      
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

    function apiManagerCreator() {
       return createApiManager([{type:SupporterApi, 
        mockApi:() => {
          return {
            deleteCrmAddress:
              jest.fn<JQueryPromise<Address>>(
                (supporter_id: number, crm_address_id: number) => {
                  return new Promise((resolve, reject) => {
                    const address = _.find(addresses, (i) => i.id === crm_address_id)
                    if (!address) {
                      reject(new NotFoundErrorException({}))
                    }
                    else {
                      resolve(address)
                    }
                  })
                })
          }
        }}])()
    }
    let address:ReactWrapper
    
    beforeEach(() => {
      const apiManager = apiManagerCreator()
      address = mountWithIntl(<AddressPane 
          nonprofitId={0} 
          initialAddress={{ 
            supporter: { 
              id: 1 } 
            }}
          ApiManager={apiManager}
          />
      )
    })

    
    it('has an add button', () => {
      
      let buttons = address.find('button')

      expect(buttons.filterWhere((button:ReactWrapper) => button.text() === 'Add').exists()).toBeTruthy()
      
    })

    it('has close button', () => {
      let buttons = address.find('button')

      expect(buttons.filterWhere((button:ReactWrapper) => button.text() === 'Close').exists()).toBeTruthy()
    })

    it('has no delete button', () => {
      let buttons = address.find('button')

      expect(buttons.filterWhere((button:ReactWrapper) => button.text() === 'Delete').exists()).toBeFalsy()
    })

    it('has a disabled add button when nothing entered', () => {
      
    let findButton = (buttons:any) => {
      return buttons
      .filterWhere(
        (button:ReactWrapper) => button.text() === 'Add'
        )
    }

      let getDisabledProp = (address:any) => {
        const buttons = address.find('button')
        return findButton(buttons).prop('disabled')
        };
      address.render()

      expect(getDisabledProp(address)).toBeTruthy()
      
      let s = (address.find("AddressPane").instance() as any).getForm()
      let address_field = s.$('address')
      
      address_field.set("sinethung")
      address.update()
      expect(getDisabledProp(address)).toBeFalsy()
      
      address_field.set("")
      address.update()
      expect(getDisabledProp(address)).toBeTruthy();
    })

    
  })

  
  
  
  // test('display', () => {
  //   let address = mountForMobxWithIntl<AddressPaneProps>({ 
  //     nonprofitId: 0,
  //     initialAddress: { 
  //       supporter: { 
  //         id: 1 } 
  //       } 
  //     }, 
  //     (props) => {
  //       return <AddressPane 
  //       nonprofitId={props.nonprofitId} 
  //       initialAddress={props.initialAddress}
  //       />
  //   })



  //   expect(toJson(address)).toMatchSnapshot()
  // })
})

