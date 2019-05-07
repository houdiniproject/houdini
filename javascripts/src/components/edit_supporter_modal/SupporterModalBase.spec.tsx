// License: LGPL-3.0-or-later
import { FormikActions } from 'formik';
import 'jest';
import * as React from 'react';
import { Supporter, TimeoutError } from '../../../api';
import { mountWithIntl } from '../../lib/tests/helpers';
import { LocalRootStore } from './local_root_store';
import SupporterModalBase, { onSubmit } from './SupporterModalBase';
import _ = require('lodash');

jest.mock('./LoadedPaneFormik')
describe('SupporterModalBase', () => {
  let onClose: jest.Mock<{}>
  function mountComponent(store: LocalRootStore) {
    return mountWithIntl(<SupporterModalBase nonprofitId={1} supporterId={1} onClose={onClose} LocalRootStore={store} />)
  }

  beforeEach(() => {
    onClose = jest.fn()
  })

  describe('onSubmit', () => {
    let wrapper: any
    let instance: any
    let setStatus: jest.Mock<{}>
    beforeEach(() => {
      setStatus = jest.fn()
    })

    it('properly saves', async (done) => {
      await onSubmit({ id: 1 }, jest.fn<FormikActions<Supporter>>(() => { return { setStatus: setStatus } })(), async () => { return {} as any }, onClose)

      expect(setStatus).toBeCalledWith({})
      expect(onClose).toBeCalled()
      done()
    })

    it('timed out', async (done) => {
      await onSubmit({ id: 1 }, jest.fn<FormikActions<Supporter>>(() => { return { setStatus: setStatus } })(), async () => { throw new TimeoutError() }, onClose)
      expect(onClose).not.toBeCalled()
      expect(setStatus).toBeCalledWith({ form: "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds." })
      done()
    })
  })

  describe('render', () => {
    const addresses = []
    const supporer = {}


    describe('LoadFailure', () => {
      function createRootStore() {
        return {
          supporterPaneStore: {
            loadFailure: true,
            loading: true,
            attemptInit: async () => { }
          }
        } as LocalRootStore
      }

      it('shows failed to load', () => {
        const value = mountComponent(createRootStore())
        expect(value.find('FailedToLoad').exists()).toBeTruthy()
      })
    })

    describe('Loaded', () => {
      function createRootStore() {
        return {
          supporterPaneStore: {
            loadFailure: false,
            loading: false,
            attemptInit: async () => { }
          },
          supporterEntity: {
            supporter: { id: 1 },
            addresses: [{ id: 11 }]
          }
        } as LocalRootStore
      }

      it('has a loaded pane formik', () => {
        const wrapper = mountComponent(createRootStore())
        const supporterModalBase = wrapper.find('SupporterModalBase')
        const loadedPaneFormik = wrapper.find('LoadedPaneFormik')

        expect(loadedPaneFormik.exists()).toBeTruthy()
        
        const props = loadedPaneFormik.instance().props as any
        expect(props.supporterId).toBe(1)
        expect(props.onSubmit).toBe((supporterModalBase.instance() as any).onSubmit)
        expect(props.initialValues).toEqual({ id: 1 })

        expect(props.addresses).toEqual([{ id: 11 }])

        expect(props.onClose).toBe(onClose)


      })
    })

    describe('Loading', () => {
      function createRootStore() {
        return {
          supporterPaneStore: {
            loading: true,
            attemptInit: async () => { }
          }
        } as LocalRootStore
      }

      it('shows loading', () => {
        const value = mountComponent(createRootStore())
        expect(value.find('Spinner').exists()).toBeTruthy()
      })
    })
  })
  // function generateRootStore(paneStore?: Partial<SupporterPaneStore>): LocalRootStore {
  //   let supporterPaneStore = {
  //     attemptInit: jest.fn(async () => { return }),
  //     loaded: true,
  //     form: SupporterPaneStore.initializeSupporterForm(updateSupporter, {}),
  //     get defaultAddressId() {
  //       return defaultAddressId
  //     },
  //     handleAddressAction: async () => {
  //       defaultAddressId = 1
  //     },
  //     isDefaultAddress: (i: any) => { return i === defaultAddressId },
  //     addAddress: addButtonClick,
  //     editAddress: editButtonClick
  //   }
  //   if (paneStore) {
  //     _.merge(supporterPaneStore, paneStore)
  //   }

  //   return jest.fn<LocalRootStore>(() => {
  //     return {
  //       supporterPaneStore: supporterPaneStore,
  //       supporterAddressStore: {
  //         supporter: defaultSupporter,
  //         addresses: [{ id: 1, address: 'ehtowhetoweit' }]
  //       } as SupporterEntity
  //     }

  //   })()
  // }

  // let onCloseAction: any

  // let defaultSupporter: Supporter = { id: 1, name: 'fake name', email: 'ema2l@cc', phone: '93912345' }

  // let defaultAddressId: number = null
  // let updateSupporter: any
  // let addButtonClick: any
  // let editButtonClick: any


  // beforeEach(() => {
  //   onCloseAction = jest.fn()
  //   updateSupporter = jest.fn();
  //   addButtonClick = jest.fn();
  //   editButtonClick = jest.fn();
  // })

  // it('handle loading error', () => {
  //   let supporter = jest.fn<LocalRootStore>(() => {
  //     return {
  //       supporterPaneStore: {
  //         loading: false,
  //         loadFailure: true,
  //         attemptInit: jest.fn(async () => { return })
  //       }

  //     }
  //   })()

  //   let modal: ReactWrapper = mountWithIntl(<SupporterPane nonprofitId={1} supporterId={2} onClose={null} LocalRootStore={supporter} />)

  //   expect(modal.find('FailedToLoad').exists()).toBeTruthy
  // })



  // describe('non-loading error', () => {
  //   describe('address selection', () => {
  //     let modal: ReactWrapper

  //     beforeEach(() => {
  //       let localRootStore = generateRootStore()
  //       modal = mountWithIntl(
  //         <SupporterPane
  //           nonprofitId={0} supporterId={1}
  //           onClose={onCloseAction} LocalRootStore={localRootStore}
  //         />
  //       )

  //     })

  //     it('runs add address properly', () => {

  //       let buttons = modal.find('button')

  //       buttons.filterWhere((e) =>
  //         e.text() === 'Add Address'
  //       ).simulate('click')

  //       expect(addButtonClick as jest.Mock<{}>).toBeCalled()

  //     })

  //     it('changes on update address properly', () => {
  //       modal.update()
  //       modal.find('SelectableTableRow').filterWhere((e) => { return e.key() === '1' }).simulate('click')
  //       expect(editButtonClick).toBeCalledWith({ id: 1, address: 'ehtowhetoweit' })
  //     })

  //   })
  // })

  // describe('addressPane is on', () => {
  //   let modal: any;
  //   beforeEach(() => {
  //     let localRootStore = generateRootStore({ addressToEdit: { supporter: { id: 1 } }, editingAddress: true })

  //     modal = mountWithIntl(
  //       <Provider LocalRootStore={localRootStore}>
  //         <SupporterPane
  //           nonprofitId={0} supporterId={1}
  //           onClose={onCloseAction} LocalRootStore={localRootStore}
  //         />
  //       </Provider>
  //     )
  //   })
  //   it('has addressPane on', () => {
  //     modal.update()
  //     expect(modal.find('AddressPane').exists()).toBeTruthy()
  //   })
  // })

  // describe('verify default address is properly selected', () => {
  //   let modal: ReactWrapper;
  //   beforeEach(() => {
  //     let localRootStore = generateRootStore()

  //     defaultAddressId = 1

  //     modal = mountWithIntl(
  //       <Provider LocalRootStore={localRootStore}>
  //         <SupporterPane
  //           nonprofitId={0} supporterId={1}
  //           onClose={onCloseAction} LocalRootStore={localRootStore}
  //         />
  //       </Provider>
  //     )

  //   })

  //   it('has the proper address selected', () => {
  //     let ourTableRow = modal.find('SelectableTableRow').filterWhere((i) => i.key() === "1")

  //     expect(ourTableRow.find('Star').exists()).toBeTruthy()

  //   })

  //   it('does not have invalid table row selected', () => {
  //     let ourTableRow = modal.find('SelectableTableRow').filterWhere((i) => i.key() !== "1")
  //     expect(ourTableRow.find('Star').exists()).toBeFalsy()
  //   })
  // })
})