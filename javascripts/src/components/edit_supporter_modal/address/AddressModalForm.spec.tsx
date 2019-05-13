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

  beforeEach(() => {
    reinitStateFunctions()
    onClose = jest.fn()
  })


  describe('addressPaneFormSubmission', () => {

    let setFieldValue: jest.Mock<{}>

    let setStatus: jest.Mock<{}>
    let commonValues: any
    beforeEach(() => {
      setFieldValue = jest.fn()
      setStatus = jest.fn()
      let store = supporterEntity()
      commonValues = {
        action: jest.fn(() => { return { setFieldValue: setFieldValue, setStatus: setStatus } })(),
        supporterEntity: jest.fn(() => store)(),
        onClose: onClose
      }

    })

    describe('new address', () => {
      const values = { address: '' }
      describe('has succeeded', () => {
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('has fired onClose with the new object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'add', address: values })
          done()
        })

        it('has set status with correct id', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({})
          done()
        })
      })

      describe('timed out', () => {
        let values = { address: TIMEOUT_CAUSING_STREET }
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('error is properly set', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ form: TIMEOUT_ERROR_MESSAGE })
          done()
        })
      })
    })

    describe('update address', () => {

      describe('has succeeded', () => {
        const values = { address: '', id: 1 }
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('has fired onClose with the updated object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'update', address: values })
          done()
        })

        it('has set status with correct id', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({})
          done()
        })
      })
      describe('timed out', () => {
        let values = { id: TIMEOUT_CAUSING_ID, address: TIMEOUT_CAUSING_STREET }
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('error is properly set', (done) => {
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
        beforeEach(() => {
          addressPaneFormSubmission({ values: values, ...commonValues })
        })

        it('shouldDelete was properly reset', (done) => {
          expect(setFieldValue).toBeCalledWith('shouldDelete', false)
          done()
        })

        it('error is properly set', (done) => {
          expect(setStatus).toBeCalled()
          expect(setStatus).toBeCalledWith({ id: undefined, form: TIMEOUT_ERROR_MESSAGE })
          done()
        })
      })
    })
  })

  describe('handles an add', () => {
    const initialAddress = {}
    let onClose: jest.Mock
    let modalState: ModalContext;
    let addressModalState: AddressModalState
    let innerPane: InnerAddressPane
    beforeEach(() => {
      onClose = jest.fn()
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

    it('is successful', async (done) => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')
      pane.update()

      await innerPane.props.formik.submitForm()
      let values = { address: 'me' }

      expect(onClose).toBeCalled()
      expect(onClose).toBeCalledWith({ type: 'add', address: values })
      done()
    })

    it('is successful with default added', async (done) => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')

      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'isDefault'), true)
      pane.update()

      await innerPane.props.formik.submitForm()
      //isDefault here for test purposes
      let values = { address: 'me', isDefault: true }

      expect(onClose).toBeCalled()
      expect(onClose).toBeCalledWith({ type: 'add', address: values, setToDefault: true })
      done()
    })

    describe('timed out', () => {
      const initialAddress = {}
      let onClose: jest.Mock
      let modalState: ModalContext;
      let addressModalState: AddressModalState
      let innerAddressPane: InnerAddressPane

      beforeEach(async (done) => {
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
        await innerAddressPane.props.formik.submitForm()
        pane.update()
        done()
      })

      it('shouldDelete was never set', (done) => {
        const shouldDelete = innerAddressPane.props.formik.values.shouldDelete
        expect(shouldDelete).toBeFalsy()
        done()
      })

      it('error is properly set', (done) => {
        const block = pane.find('InnerAddressPane').find('FormNotificationBlock').instance() as React.Component<{}, {}>

        expect(block.props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        done()
      })

      it('form notification was removed onsuccessful call', async (done) => {
        pane.update()
        const block = () => pane.find('InnerAddressPane').find('FormNotificationBlock')

        expect(block().instance().props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        await innerAddressPane.props.formik.submitForm()
        pane.update()

        expect(block().exists()).toBeFalsy()
        done()
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

      expect(addressModalState.setDisableAddSave).toBeCalledWith(false)
    })

    it('is successful', async (done) => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')
      pane.update()

      await innerPane.props.formik.submitForm()
      let values = { address: 'me', id: 2, city:"", country:"", zip_code:"", state_code: "" }

      expect(onClose).toBeCalled()
      expect(onClose).toBeCalledWith({ type: 'update', address: values })
      done()
    })

    it('is successful with default added', async (done) => {
      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'address'), 'me')

      simulateChange(pane.find('input').filterWhere((w) => w.prop('name') === 'isDefault'), true)
      pane.update()

      await innerPane.props.formik.submitForm()
      //isDefault here for test purposes
      let values = { address: 'me', id: 2, city:"", country:"", zip_code:"", state_code: "", isDefault:true}

      expect(onClose).toBeCalled()
      expect(onClose).toBeCalledWith({ type: 'update', address: values, setToDefault: true })
      done()
    })
    


    describe('timed out', () => {
      const initialAddress = { id: TIMEOUT_CAUSING_ID }
      let onClose: jest.Mock
      let modalState: ModalContext;
      let addressModalState: AddressModalState
      let innerAddressPane: InnerAddressPane

      beforeEach(async (done) => {
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
        await innerAddressPane.props.formik.submitForm()
        pane.update()
        done()
      })

      it('shouldDelete was never set', (done) => {
        const shouldDelete = innerAddressPane.props.formik.values.shouldDelete
        expect(shouldDelete).toBeFalsy()
        done()
      })

      it('error is properly set', (done) => {
        const block = pane.find('InnerAddressPane').find('FormNotificationBlock').instance() as React.Component<{}, {}>

        expect(block.props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        done()
      })

      it('form notification was removed onsuccessful call', async (done) => {
        pane.update()
        const block = () => pane.find('InnerAddressPane').find('FormNotificationBlock')

        expect(block().instance().props.children).toBe(TIMEOUT_ERROR_MESSAGE)
        await innerAddressPane.props.formik.submitForm()
        pane.update()

        expect(block().exists()).toBeFalsy()
        done()
      })


    })



    describe('delete address', () => {


      describe('has successed', () => {
        beforeEach(async (done) => {
          await innerPane.handleDelete()
          done()
        })

        it('has fired onClose with the delete object', (done) => {
          expect(onClose).toBeCalled()
          expect(onClose).toBeCalledWith({ type: 'delete', address: { id: 2 } })
          done()
        })
      })

      describe('timed out', () => {
        const initialAddress = { id: TIMEOUT_CAUSING_ID }
        let onClose: jest.Mock
        let modalState: ModalContext;
        let addressModalState: AddressModalState
        let innerAddressPane: InnerAddressPane

        beforeEach(async (done) => {
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
          await innerAddressPane.handleDelete()
          pane.update()
          done()
        })

        it('shouldDelete was properly reset', (done) => {
          pane.update()
          const shouldDelete = innerAddressPane.props.formik.values.shouldDelete
          expect(shouldDelete).toBe(false)
          done()
        })

        it('error is properly set', (done) => {
          pane.update()
          const block = pane.find('InnerAddressPane').find('FormNotificationBlock').instance() as React.Component<{}, {}>

          expect(block.props.children).toBe(TIMEOUT_ERROR_MESSAGE)
          done()
        })

        it('form notification was removed onsuccessful call', async (done) => {
          pane.update()
          const block = () => pane.find('InnerAddressPane').find('FormNotificationBlock')

          expect(block().instance().props.children).toBe(TIMEOUT_ERROR_MESSAGE)
          await innerAddressPane.handleDelete()
          pane.update()

          expect(block().exists()).toBeFalsy()
          done()
        })
      })
    })

  })
})