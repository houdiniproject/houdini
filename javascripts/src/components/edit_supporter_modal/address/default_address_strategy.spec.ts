// License: LGPL-3.0-or-later
import 'jest';
import { DefaultAddressStrategy } from './default_address_strategy';
import { Address } from '../../../../api';

describe('DefaultAddressHandler', () => {

  let setDefaultAddressIdMock: jest.Mock<{}>
  beforeEach(() => {
    setDefaultAddressIdMock = jest.fn((a) =>{})
  })
  describe('add', () => {
    const addressToAdd = {
      id: 111
    };

    it('no default', () => {
      let addresses = [addressToAdd]
      
      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 1, setDefaultAddressIdMock);
      strategy.handleAddressAction({type: 'add', address: addressToAdd})
      expect(setDefaultAddressIdMock.mock.calls[0][0]).toBe(addressToAdd.id)
    })

    it('has default already', () => {
      let addresses = [addressToAdd, {}]
      let strategy = new DefaultAddressStrategy(() => addresses, 
      () => 1, setDefaultAddressIdMock);

      strategy.handleAddressAction({type:'add', address:addressToAdd})
      expect(setDefaultAddressIdMock.mock.calls.length).toBe(0)
    })

    it('has default and we want to set', () => {
      let addresses = [addressToAdd, {}]
      
      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 1, setDefaultAddressIdMock);
      strategy.handleAddressAction({type: 'add', address: addressToAdd, setToDefault:true})
      expect(setDefaultAddressIdMock.mock.calls[0][0]).toBe(addressToAdd.id)
    })
  })

  describe('delete', () => { 
    const addressToDelete = {
      id: 111
    };

    it('we have default and we deleted a different one', () => {
      let addresses = [ {}]
      
      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 1, setDefaultAddressIdMock);
      strategy.handleAddressAction({type:'delete', address:addressToDelete})
      expect(setDefaultAddressIdMock.mock.calls.length).toBe(0)
    })

    it('we deleted us and no other addresses exists', () => {
      let addresses:Address[] = []
      
      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 111, setDefaultAddressIdMock);
      strategy.handleAddressAction({type:'delete', address: addressToDelete})
      expect(setDefaultAddressIdMock.mock.calls[0][0]).toBeFalsy()
    })

    it('we deleted us and other addreses do exist', () => {
      //these need to be sorted
      let addresses:Address[] = [
        {id: 2, updated_at:new Date(2012, 1, 2)},
        {id: 3, updated_at: new Date(2018, 1, 2)},
        {id: 4, updated_at: new Date(2015, 1, 2)}
      ]

      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 111, setDefaultAddressIdMock);

      strategy.handleAddressAction({type:'delete', address: addressToDelete})

      expect(setDefaultAddressIdMock.mock.calls[0][0]).toBe(3)

    })

  })

  describe('update', () => {
    const addressToUpdate = {
      id: 111
    };
    
    it('we didnt want to set default', () => {
      let addresses:Address[] = []
      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 111, setDefaultAddressIdMock);

      strategy.handleAddressAction({type:'update', address:addressToUpdate})
      
      expect(setDefaultAddressIdMock.mock.calls.length).toBe(0)
    })

    it('we wanted to set as default', () => {
      let addresses:Address[] = []
      let strategy = new DefaultAddressStrategy(() => addresses, 
                () => 111, setDefaultAddressIdMock);

      strategy.handleAddressAction({type:'update', address:addressToUpdate, setToDefault:true})

      expect(setDefaultAddressIdMock.mock.calls[0][0]).toBe(addressToUpdate.id)
    })

  })

  it('none', () => {
    let addresses:Address[] = []
    let strategy = new DefaultAddressStrategy(() => addresses, 
              () => 111, setDefaultAddressIdMock);
    strategy.handleAddressAction({type:'none'})
    expect(setDefaultAddressIdMock.mock.calls.length).toBe(0)
  })
})

