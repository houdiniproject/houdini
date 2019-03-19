// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import SupporterPane from './SupporterPane'
import { ReactWrapper } from 'enzyme';
import { mountWithIntl, createMockApiManager, createMockApi } from '../../lib/tests/helpers';
import { SupporterAddressController } from './supporter_address_controller';
import { Supporter } from '../../../api';
import { Provider } from 'mobx-react';
import { SupporterApi } from '../../../api/api/SupporterApi';

describe('SupporterPane', () => {
  let onCloseAction: any

  let defaultSupporter: Supporter = { id: 1, name: 'fake name', email: 'ema2l@cc', phone: '93912345' }

  beforeEach(() => {
    onCloseAction = jest.fn()
  })

  it('handle loading error', () => {
    let supporter = jest.fn<SupporterAddressController>(() => {
      return {
        init: async () => {
        throw new Error()
      }
    }
    })

    let modal: ReactWrapper = mountWithIntl(<SupporterPane nonprofitId={1} supporterId={2} onSave={null} SupporterAddressController={supporter()} />)

    expect(modal.find('FailedToLoad').exists()).toBeTruthy
  })

  describe('non-loading error', () => {
    let defaultAddressId:number = null

    let supporterController = jest.fn<SupporterAddressController>(() => {
      return {
        init: async () => { return;},
        supporter: defaultSupporter,
        addresses: [{ id: 1, address: 'ehtowhetoweit' }],
        get defaultAddressId() {
          return defaultAddressId
        },
        handleAddressAction: async (...args:any[]) => {
          defaultAddressId = 1
        },
        isDefaultAddress: (i) => {return i === defaultAddressId}
      }
    })

    describe('address selection', () => {
      let modal: ReactWrapper
      let instance:any

      beforeEach(() => {
        modal = mountWithIntl(<Provider ApiManager={createMockApiManager(createMockApi(SupporterApi, () => { return {}}))()}>
        <SupporterPane
          nonprofitId={0} supporterId={1}
          onSave={onCloseAction} SupporterAddressController={supporterController()}
        />
        </Provider>)

        instance = modal.find('SupporterPane').instance() as any
        modal.update()
      })
      
      it('changes on add address properly', () => {
        modal.update()
        let buttons = modal.find('button')
        
        buttons.filterWhere((e) => 
          e.text() === 'Add Address'
        ).simulate('click')

        modal.update()

        expect(modal.find('AddressPane').exists()).toBeTruthy()
      })

      it('changes on update address properly', () => {
        modal.update()
        modal.find('SelectableTableRow').filterWhere((e) => {return e.key() === '1'}).simulate('click')

        modal.update()

        expect(modal.find('AddressPane').exists()).toBeTruthy()
      })

      it('changes back on update address', async (done) => {
        modal.update()
        let buttons = modal.find('button')
        
        buttons.filterWhere((e) => 
          e.text() === 'Add Address'
        ).simulate('click')

        modal.update()
        
        await instance.handleAddressPaneClose({type:'none'})

        modal.update()

        expect(modal.find('AddressPane').exists()).toBeFalsy()
        done()
        
      })

    })

    describe('handleDefaultAddressChange', () => {
      let modal: ReactWrapper
      let instance:any
      beforeAll(() => {
        modal = mountWithIntl(<Provider ApiManager={createMockApiManager(createMockApi(SupporterApi, () => { return {}}))()}><SupporterPane
          nonprofitId={0} supporterId={1}
          onSave={onCloseAction}
          SupporterAddressController={supporterController()}
        /></Provider>)
        instance = modal.find('SupporterPane').instance() as any
      })
      
      it('properly denotes the default', async (done) => {
        await instance.handleAddressPaneClose({type:'none'})

        modal.update()

        expect(modal.find('Star').exists()).toBeTruthy()
        done()
      })

    })
  })
})