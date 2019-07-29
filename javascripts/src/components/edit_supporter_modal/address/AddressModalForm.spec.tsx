// License: LGPL-3.0-or-later
import { ReactWrapper } from 'enzyme';
import 'jest';
import { Provider } from 'mobx-react';
import * as React from 'react';
import { mountWithIntl } from '../../../lib/tests/helpers';
import { simulateChange } from '../../../lib/tests/helpers/mounted';
import { ModalProvider } from '../../common/modal/connect';
import { ModalContext } from '../../common/modal/Modal';
import { ModalManager } from '../../common/modal/modal_manager';
import { SupporterEntity } from '../supporter_entity';
import { AddressModalState } from './AddressModal';
import AddressModalForm, { addressPaneFormSubmission, TIMEOUT_ERROR_MESSAGE } from './AddressModalForm';
import { InnerAddressPane } from './AddressPane';
import { supporterEntity, TIMEOUT_CAUSING_ID, TIMEOUT_CAUSING_STREET } from './supporter_entity_mock';
import _ = require('lodash');
import { Supporter } from '../../../../api';
import waitForExpect from 'wait-for-expect'

describe('AddressModalForm', () => {
  let onClose: jest.Mock<{}>
  let pane: ReactWrapper
  const serverErrorText = "some server error is errored"
  let setDisableAddSave: jest.Mock
  let setShowDelete: jest.Mock
  let setSaveAddAction: jest.Mock
  let setDeleteAction: jest.Mock
  let setDisableCloseButton: jest.Mock
  let setDisableDeleteButton: jest.Mock
  let setCanClose: jest.Mock
  let setFormId: jest.Mock

  function reinitStateFunctions() {
    setDisableAddSave = jest.fn()
    setShowDelete = jest.fn()
    setSaveAddAction = jest.fn()
    setDeleteAction = jest.fn()
    setDisableCloseButton = jest.fn()
    setDisableDeleteButton = jest.fn()
    setCanClose = jest.fn()
    setFormId = jest.fn()
  }

  function createModalState(): ModalContext {
    return {
      setCanClose: setCanClose
    } as any
  }

  function createAddressModalState(): AddressModalState {
    return {
      setDisableAddSave: setDisableAddSave,
      setShowDelete: setShowDelete,
      setSaveAddAction: setSaveAddAction,
      setDeleteAction: setDeleteAction,
      setDisableCloseButton: setDisableCloseButton,
      setDisableDeleteButton: setDisableDeleteButton,
      setFormId: setFormId,
    } as any
  }

  function toPromise(func: any): Promise<void> {
    return func as Promise<void>
  }


  beforeEach(() => {
    reinitStateFunctions()
    onClose = jest.fn()
  })


  describe('addressPaneFormSubmission', () => {

    let setFieldValue: jest.Mock<{}>

    let setStatus: jest.Mock<{}>
    let setSubmitting: jest.Mock
    let commonValues: any
    beforeEach(() => {
      setFieldValue = jest.fn()
      setStatus = jest.fn()
      setSubmitting = jest.fn()
      let store = supporterEntity()
      commonValues = {
        action: jest.fn(() => { return { setFieldValue, setStatus, setSubmitting} })(),
        supporterEntity: jest.fn(() => store)(),
        onClose: onClose
      }

    })

    describe('new address', () => {
      const values = { address: '' }
      describe('has succeeded', () => {
        it('has fired onClose with the new object', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'add', address: values })
          done()
        })

        it('has set status with correct id', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({})
          done()
        })
      })

      describe('timed out', () => {
        let values = { address: TIMEOUT_CAUSING_STREET }

        it('error is properly set', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ form: TIMEOUT_ERROR_MESSAGE })
          done()
        })
      })
    })

    describe('update address', () => {

      describe('has succeeded', () => {
        const values = { address: '', id: 1 }

        it('has fired onClose with the updated object', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'update', address: values })
          done()
        })

        it('has set status with correct id', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({})
          done()
        })
      })

      describe('timed out', () => {
        let values = { id: TIMEOUT_CAUSING_ID, address: TIMEOUT_CAUSING_STREET }

        it('error is properly set', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ id: undefined, form: TIMEOUT_ERROR_MESSAGE })
          done()
        })
      })
    })

    describe('delete address', () => {
      const values = { address: '', id: 1, shouldDelete: true }
      describe('has successed', () => {
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('has fired onClose', () => {

        })

        it('has fired onClose with the delete object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'delete', address: { id: 1 } })
          done()
        })

        it('has set status with correct id', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ id: undefined })
          done()
        })

        it('shouldDelete was properly reset', (done) => {
          expect(setFieldValue).toBeCalledWith('shouldDelete', false)
          done()
        })
      })

      describe('timed out', () => {
        let values = { id: TIMEOUT_CAUSING_ID, shouldDelete: true }

        it('shouldDelete was properly reset', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(setFieldValue).toBeCalledWith('shouldDelete', false)
          done()
        })

        it('error is properly set', async (done) => {
          await addressPaneFormSubmission({ values: values, ...commonValues })
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ id: undefined, form: TIMEOUT_ERROR_MESSAGE })
          done()
        })
      })
    })
  })

  describe('handles an add', () => {
    const initialAddress = {}
    let modalState: ModalContext;
    let addressModalState: AddressModalState
    let innerPane: InnerAddressPane
    beforeEach(() => {
      let entity = supporterEntity()
      modalState = createModalState()
      addressModalState = createAddressModalState()
      pane = mountWithIntl(<ModalProvider value={modalState}>
        <AddressModalForm initialAddress={initialAddress}
          onClose={onClose} supporterEntity={entity as SupporterEntity} addressModalState={addressModalState}
        /></ModalProvider>)
      innerPane = pane.find('InnerAddressPane').instance() as any


    })

    it("nothing has been incorrectly fired", () => {
      expect(addressModalState.setDisableAddSave).toBeCalledWith(true)
      expect(addressModalState.setDisableCloseButton).toBeCalledWith(false)
      expect(addressModalState.setShowDelete).toBeCalledWith(false)
    })

    it("modifying an input does make save button work", () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')

      expect(addressModalState.setDisableAddSave).toBeCalledWith(false)
    })

    it('is successful', async () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')

      pane.update()

      await innerPane.props.formik.submitForm()
      let values = { address: 'me' }

      await waitForExpect(() =>
        expect(onClose).toBeCalledWith({ type: 'add', address: values }))

    })

    it('with default added there is success', async () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')

      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'isDefault'), true)
      pane.update()

      await innerPane.props.formik.submitForm()
      //isDefault here for test purposes
      let values = { address: 'me', isDefault: true }

      await waitForExpect(() => expect(onClose).toBeCalledWith({ type: 'add', address: values, setToDefault: true }))
    })

    describe('timed out', () => {
      const initialAddress = {}
      let onClose: jest.Mock
      let modalState: ModalContext;
      let addressModalState: AddressModalState
      let innerAddressPane: InnerAddressPane

      beforeEach(() => {
        onClose = jest.fn()
        let entity = supporterEntity()
        modalState = createModalState()
        addressModalState = createAddressModalState()
        pane = mountWithIntl(<Provider ModalManager={new ModalManager()}
        ><ModalProvider value={modalState}>
            <AddressModalForm initialAddress={initialAddress}
              onClose={onClose} supporterEntity={entity as SupporterEntity} addressModalState={addressModalState}
            /></ModalProvider></Provider>)

        innerAddressPane = pane.find('InnerAddressPane').instance() as InnerAddressPane
        let address = pane.find('InnerAddressPane').find('input').filterWhere(i => i.prop('name') === 'address')
        simulateChange(address, TIMEOUT_CAUSING_STREET)
        pane.update()
      })

      it('shouldDelete was never set', async () => {
        await innerAddressPane.props.formik.submitForm()
        pane.update()
        await waitForExpect(() => {expect(innerAddressPane.props.formik.values.shouldDelete).toBeFalsy()})
      })

      it('error is properly set', async() => {
        await innerAddressPane.props.formik.submitForm()
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        pane.update()
        const block = pane.find('InnerAddressPane').find('FormNotificationBlock').instance() as React.Component<{}, {}>

        await waitForExpect(() =>expect(block.props.children).toBe(TIMEOUT_ERROR_MESSAGE))
      })

      it('form notification was removed onsuccessful call', async () => {
        await innerAddressPane.props.formik.submitForm()
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        pane.update()
        const block = () => pane.find('InnerAddressPane').find('FormNotificationBlock')

        expect(block().instance().props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        await innerAddressPane.props.formik.submitForm()
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        pane.update()

        expect(block().exists()).toBeFalsy()
      
      })
    })
  })

  describe('handles a modify', () => {
    const initialAddress = { id: 2 }
    let onClose: jest.Mock
    let modalState: ModalContext;
    let addressModalState: AddressModalState
    let innerPane: InnerAddressPane
    beforeEach(() => {
      onClose = jest.fn()
      let entity = supporterEntity()
      modalState = createModalState()
      addressModalState = createAddressModalState()
      pane = mountWithIntl(<Provider ModalManager={new ModalManager()}
      ><ModalProvider value={modalState}>
          <AddressModalForm initialAddress={initialAddress}
            onClose={onClose} supporterEntity={entity as SupporterEntity} addressModalState={addressModalState}
          /></ModalProvider></Provider>)

      innerPane = pane.find('InnerAddressPane').instance() as InnerAddressPane
    })

    it("nothing has been incorrectly fired", () => {
      expect(addressModalState.setDisableAddSave).toBeCalledWith(true)
      expect(addressModalState.setDisableCloseButton).toBeCalledWith(false)
      expect(addressModalState.setShowDelete).toBeCalledWith(true)
      expect(addressModalState.setDeleteAction).toBeCalledWith(innerPane.handleDelete)
    })

    it("modifying an input does make save button work", () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')
      pane.update()
      expect(addressModalState.setDisableAddSave).toBeCalledWith(false)
    })

    it('is successful', async () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')
      pane.update()

      await innerPane.props.formik.submitForm()

      let values = { address: 'me', id: 2, city:"", country:"", zip_code:"", state_code: "" }

      await waitForExpect(() =>
        expect(onClose).toBeCalledWith({ type: 'update', address: values }))
    })

    it('is successful with default added', async () => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')

      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'isDefault'), true)
      pane.update()

      await innerPane.props.formik.submitForm()
      //isDefault here for test purposes
      let values = { address: 'me', id: 2, city:"", country:"", zip_code:"", state_code: "", isDefault:true}
      await waitForExpect(() =>

      expect(onClose).toBeCalledWith({ type: 'update', address: values, setToDefault: true }));
    })



    describe('timed out', () => {
      const initialAddress = { id: TIMEOUT_CAUSING_ID }
      let onClose: jest.Mock
      let modalState: ModalContext;
      let addressModalState: AddressModalState
      let innerAddressPane: InnerAddressPane

      beforeEach(async () => {
        onClose = jest.fn()
        let entity = supporterEntity()
        modalState = createModalState()
        addressModalState = createAddressModalState()
        pane = mountWithIntl(<Provider ModalManager={new ModalManager()}
        ><ModalProvider value={modalState}>
            <AddressModalForm initialAddress={initialAddress}
              onClose={onClose} supporterEntity={entity as SupporterEntity} addressModalState={addressModalState}
            /></ModalProvider></Provider>)

        innerAddressPane = pane.find('InnerAddressPane').instance() as InnerAddressPane
        let address = pane.find('InnerAddressPane').find('input').filterWhere(i => i.prop('name') === 'address')
        simulateChange(address, TIMEOUT_CAUSING_STREET)
        pane.update()
        

      })

      it('shouldDelete was never set', async () => {
        await innerAddressPane.props.formik.submitForm()
        
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        const shouldDelete = innerAddressPane.props.formik.values.shouldDelete
        expect(shouldDelete).toBeFalsy()
      })

      it('error is properly set', async() => {
        await innerAddressPane.props.formik.submitForm()
        
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        pane.update()
        const block = pane.find('InnerAddressPane').find('FormNotificationBlock').instance() as React.Component<{}, {}>

        expect(block.props.children).toBe(TIMEOUT_ERROR_MESSAGE)
     
      })

      it('form notification was removed onsuccessful call', async () => {
        await innerAddressPane.props.formik.submitForm()
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        pane.update()
        const block = () => pane.find('InnerAddressPane').find('FormNotificationBlock')

        expect(block().instance().props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        await innerAddressPane.props.formik.submitForm()
    
        await waitForExpect(() => expect(innerAddressPane.props.formik.isSubmitting).toBeFalsy())
        pane.update()

        expect(block().exists()).toBeFalsy()

      })


    })



    describe('delete address', () => {


      describe('has succeeded', () => {

        it('has fired onClose with the delete object', async () => {
          await innerPane.handleDelete()
          expect(onClose).toBeCalledWith({ type: 'delete', address: { id: 2 } })
        })
      })

      describe('timed out', () => {
        const initialAddress = { id: TIMEOUT_CAUSING_ID }
        let onClose: jest.Mock
        let modalState: ModalContext;
        let addressModalState: AddressModalState
        let innerAddressPane: InnerAddressPane

        beforeEach(async () => {
          onClose = jest.fn()
          let entity = supporterEntity()
          modalState = createModalState()
          addressModalState = createAddressModalState()
          pane = mountWithIntl(<Provider ModalManager={new ModalManager()}
          ><ModalProvider value={modalState}>
              <AddressModalForm initialAddress={initialAddress}
                onClose={onClose} supporterEntity={entity as SupporterEntity} addressModalState={addressModalState}
              /></ModalProvider></Provider>)

          innerAddressPane = pane.find('InnerAddressPane').instance() as InnerAddressPane
         
        })

        it('shouldDelete was properly reset', async () => {
          await innerAddressPane.handleDelete()
          pane.update()
          const shouldDelete = innerAddressPane.props.formik.values.shouldDelete
          expect(shouldDelete).toBe(false)
        })

        it('error is properly set', async () => {
          await innerAddressPane.handleDelete()
          pane.update()
          const block = pane.find('InnerAddressPane').find('FormNotificationBlock').instance() as React.Component<{}, {}>

          expect(block.props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        })

        it('form notification was removed onsuccessful call', async () => {
          await innerAddressPane.handleDelete()
          pane.update()
          const block = () => pane.find('InnerAddressPane').find('FormNotificationBlock')

          expect(block().instance().props.children).toBe(TIMEOUT_ERROR_MESSAGE)
          await innerAddressPane.handleDelete()
          pane.update()

          expect(block().exists()).toBeFalsy()
        })
      })
    })

  })
})