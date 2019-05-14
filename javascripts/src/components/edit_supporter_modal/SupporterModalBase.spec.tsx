// License: LGPL-3.0-or-later
import { FormikActions } from 'formik';
import 'jest';
import * as React from 'react';
import { Supporter, TimeoutError } from '../../../api';
import { shallowWithIntl, mountWithIntl } from '../../lib/tests/helpers';
import { LocalRootStore } from './local_root_store';
import SupporterModalBase, { onSubmit } from './SupporterModalBase';
import _ = require('lodash');


jest.mock('./LoadedPaneFormik')
describe('SupporterModalBase', () => {
  let onClose: jest.Mock<{}>
  let supporterModalState:any = {}
  function mountComponent(store: LocalRootStore) {
    return mountWithIntl(<SupporterModalBase nonprofitId={1} supporterId={1} onClose={onClose} LocalRootStore={store} supporterModalState={supporterModalState}/>)
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
        expect(props.onSubmit).toEqual((supporterModalBase.instance() as any).innerOnSubmit)
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
})