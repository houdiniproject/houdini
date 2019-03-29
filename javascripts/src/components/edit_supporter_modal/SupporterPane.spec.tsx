// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import SupporterPane from './SupporterPane'
import { ReactWrapper } from 'enzyme';
import { mountWithIntl, createMockApiManager, createMockApi } from '../../lib/tests/helpers';
import { Supporter } from '../../../api';
import { Provider } from 'mobx-react';
import { SupporterApi } from '../../../api/api/SupporterApi';
import { LocalRootStore } from './local_root_store';
import { SupporterAddressStore } from './supporter_address_store';
import { SupporterPaneStore } from './supporter_pane_store';
import _ = require('lodash');

describe('SupporterPane', () => {
  let onCloseAction: any

  let defaultSupporter: Supporter = { id: 1, name: 'fake name', email: 'ema2l@cc', phone: '93912345' }

  beforeEach(() => {
    onCloseAction = jest.fn()
  })

  it('handle loading error', () => {
    let supporter = jest.fn<LocalRootStore>(() => {
      return {
        supporterPaneStore: {
          loading: false,
          loadFailure: true
        }

      }
    })()

    let modal: ReactWrapper = mountWithIntl(<SupporterPane nonprofitId={1} supporterId={2} onSave={null} LocalRootStore={supporter} />)

    expect(modal.find('FailedToLoad').exists()).toBeTruthy
  })

  describe('non-loading error', () => {
    
  function generateRootStore(paneStore?:Partial<SupporterPaneStore>): LocalRootStore {
    let supporterPaneStore = {
      attemptInit: () => { },
      loaded: true,
      form: SupporterPaneStore.initializeSupporterForm(updateSupporter, {}),
      get defaultAddressId() {
        return defaultAddressId
      },
      handleAddressAction: async (...args: any[]) => {
        defaultAddressId = 1
      },
      isDefaultAddress: (i:any) => { return i === defaultAddressId },
      addAddress:addButtonClick,
      editAddress:editButtonClick
    }
    if (paneStore){
      _.merge(supporterPaneStore, paneStore)
    }

    return jest.fn<LocalRootStore>(() => {
      return {
        supporterPaneStore: supporterPaneStore,
        supporterAddressStore: {
          supporter: defaultSupporter,
          addresses: [{ id: 1, address: 'ehtowhetoweit' }]
        } as SupporterAddressStore
      }

    })()
  }

    let defaultAddressId: number = null
    let updateSupporter: any
    let localRootStore: LocalRootStore
    let addButtonClick:any
    let editButtonClick:any
    beforeEach(() => {
      updateSupporter = jest.fn();
      addButtonClick = jest.fn();
      editButtonClick = jest.fn();
      localRootStore = generateRootStore()

    })

    describe('address selection', () => {
      let modal: ReactWrapper
      let instance: any

      beforeEach(() => {
        modal = mountWithIntl(
          <SupporterPane
            nonprofitId={0} supporterId={1}
            onSave={onCloseAction} LocalRootStore={localRootStore}
          />
        )

        instance = modal.find('SupporterPane').instance() as any
        modal.update()
      })

      it('runs add address properly', () => {
        modal.update()
        let buttons = modal.find('button')

        buttons.filterWhere((e) =>
          e.text() === 'Add Address'
        ).simulate('click')

        expect(addButtonClick as jest.Mock<{}>).toBeCalled()

      })

      describe('addressPane is on', () => {
        beforeEach(() => {
          localRootStore = generateRootStore({addressToEdit: {supporter:{id:1}}, editingAddress: true})
          
          modal = mountWithIntl(
            <Provider LocalRootStore={localRootStore}>
            <SupporterPane
              nonprofitId={0} supporterId={1}
              onSave={onCloseAction} LocalRootStore={localRootStore}
            />
            </Provider>
          )
  
          instance = modal.find('SupporterPane').instance() as any
          modal.update()
        })
        it('has addressPane on', () => {
          modal.update()
          expect(modal.find('AddressPane').exists()).toBeTruthy()
        })
      })

      it('changes on update address properly', () => {
        modal.update()
        modal.find('SelectableTableRow').filterWhere((e) => { return e.key() === '1' }).simulate('click')

       

        expect(editButtonClick).toBeCalledWith({id: 1, address: 'ehtowhetoweit'})
      })

      it('changes back on update address', async (done) => {
        modal.update()
        let buttons = modal.find('button')

        buttons.filterWhere((e) =>
          e.text() === 'Add Address'
        ).simulate('click')

        modal.update()

        await instance.handleAddressPaneClose({ type: 'none' })

        modal.update()

        expect(modal.find('AddressPane').exists()).toBeFalsy()
        done()

      })

    })
  })
})

  //   describe('handleDefaultAddressChange', () => {
  //     let modal: ReactWrapper
  //     let instance:any
  //     beforeAll(() => {
  //       modal = mountWithIntl(<Provider ApiManager={createMockApiManager(createMockApi(SupporterApi, () => { return {}}))()}><SupporterPane
  //         nonprofitId={0} supporterId={1}
  //         onSave={onCloseAction}
  //         SupporterAddressController={supporterController()}
  //       /></Provider>)
  //       instance = modal.find('SupporterPane').instance() as any
  //     })

  //     it('properly denotes the default', async (done) => {
  //       await instance.handleAddressPaneClose({type:'none'})

  //       modal.update()

  //       expect(modal.find('Star').exists()).toBeTruthy()
  //       done()
  //     })

  //   })
  // })
// })