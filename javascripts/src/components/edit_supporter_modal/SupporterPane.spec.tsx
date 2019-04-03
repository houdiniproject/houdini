// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import SupporterPane from './SupporterPane'
import { ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../lib/tests/helpers';
import { Supporter } from '../../../api';
import { Provider } from 'mobx-react';
import { LocalRootStore } from './local_root_store';
import { SupporterAddressStore } from './supporter_address_store';
import { SupporterPaneStore } from './supporter_pane_store';
import _ = require('lodash');

describe('SupporterPane', () => {

  function generateRootStore(paneStore?: Partial<SupporterPaneStore>): LocalRootStore {
    let supporterPaneStore = {
      attemptInit: jest.fn(async () => { return }),
      loaded: true,
      form: SupporterPaneStore.initializeSupporterForm(updateSupporter, {}),
      get defaultAddressId() {
        return defaultAddressId
      },
      handleAddressAction: async () => {
        defaultAddressId = 1
      },
      isDefaultAddress: (i: any) => { return i === defaultAddressId },
      addAddress: addButtonClick,
      editAddress: editButtonClick
    }
    if (paneStore) {
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

  let onCloseAction: any

  let defaultSupporter: Supporter = { id: 1, name: 'fake name', email: 'ema2l@cc', phone: '93912345' }

  let defaultAddressId: number = null
  let updateSupporter: any
  let addButtonClick: any
  let editButtonClick: any


  beforeEach(() => {
    onCloseAction = jest.fn()
    updateSupporter = jest.fn();
    addButtonClick = jest.fn();
    editButtonClick = jest.fn();
  })

  it('handle loading error', () => {
    let supporter = jest.fn<LocalRootStore>(() => {
      return {
        supporterPaneStore: {
          loading: false,
          loadFailure: true,
          attemptInit: jest.fn(async () => { return })
        }

      }
    })()

    let modal: ReactWrapper = mountWithIntl(<SupporterPane nonprofitId={1} supporterId={2} onClose={null} LocalRootStore={supporter} />)

    expect(modal.find('FailedToLoad').exists()).toBeTruthy
  })



  describe('non-loading error', () => {
    describe('address selection', () => {
      let modal: ReactWrapper

      beforeEach(() => {
        let localRootStore = generateRootStore()
        modal = mountWithIntl(
          <SupporterPane
            nonprofitId={0} supporterId={1}
            onClose={onCloseAction} LocalRootStore={localRootStore}
          />
        )

      })

      it('runs add address properly', () => {

        let buttons = modal.find('button')

        buttons.filterWhere((e) =>
          e.text() === 'Add Address'
        ).simulate('click')

        expect(addButtonClick as jest.Mock<{}>).toBeCalled()

      })

      it('changes on update address properly', () => {
        modal.update()
        modal.find('SelectableTableRow').filterWhere((e) => { return e.key() === '1' }).simulate('click')
        expect(editButtonClick).toBeCalledWith({ id: 1, address: 'ehtowhetoweit' })
      })

    })
  })

  describe('addressPane is on', () => {
    let modal: any;
    beforeEach(() => {
      let localRootStore = generateRootStore({ addressToEdit: { supporter: { id: 1 } }, editingAddress: true })

      modal = mountWithIntl(
        <Provider LocalRootStore={localRootStore}>
          <SupporterPane
            nonprofitId={0} supporterId={1}
            onClose={onCloseAction} LocalRootStore={localRootStore}
          />
        </Provider>
      )
    })
    it('has addressPane on', () => {
      modal.update()
      expect(modal.find('AddressPane').exists()).toBeTruthy()
    })
  })

  describe('verify default address is properly selected', () => {
    let modal: ReactWrapper;
    beforeEach(() => {
      let localRootStore = generateRootStore()

      defaultAddressId = 1

      modal = mountWithIntl(
        <Provider LocalRootStore={localRootStore}>
          <SupporterPane
            nonprofitId={0} supporterId={1}
            onClose={onCloseAction} LocalRootStore={localRootStore}
          />
        </Provider>
      )

    })

    it('has the proper address selected', () => {
      let ourTableRow = modal.find('SelectableTableRow').filterWhere((i) => i.key() === "1")

      expect(ourTableRow.find('Star').exists()).toBeTruthy()

    })

    it('does not have invalid table row selected', () => {
      let ourTableRow = modal.find('SelectableTableRow').filterWhere((i) => i.key() !== "1")
      expect(ourTableRow.find('Star').exists()).toBeFalsy()
    })
  })
})