// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import CreateSupporterPaneStateManager from './CreateSupporterPaneStateManager'
import { ConfirmationManager } from '../common/modal/confirmation/confirmation_manager';
import { SupporterModalState } from './CreateSupporterModal';
import { ModalContext } from '../common/modal/Modal';
import { OnCloseType } from '../edit_supporter_modal/SupporterModalBase';
import { CreateSupporterFormikState, SubmitPhase } from './CreateSupporterFormik';
import { ReactWrapper } from 'enzyme';
import { ConfirmationManagerProvider } from '../common/modal/confirmation/connect';
import HoudiniFormik from '../common/HoudiniFormik';
import { mountWithIntl } from '../../lib/tests/helpers';

describe('CreateSupporterModalStateManager', () => {
  let pane:ReactWrapper
  let confirmManager: ConfirmationManager
  let supporterModalState: SupporterModalState
  let modalContext: ModalContext
  let onClose: OnCloseType
  let createSupporterFormikState:CreateSupporterFormikState
  let onSubmit: any

  function confirmationManagerSuccess () : ConfirmationManager{
    return {
      confirm: jest.fn(async() => await true)
    } as any
  }

  function confirmationManagerFailure () : ConfirmationManager{
    return {
      confirm: jest.fn(async() => await false)
    } as any
  }

  describe('phases', () => {
    describe('SubmitPhase.HAVE_NOTHING', () => {
      
      describe('canClose', () => {
        function buildClose(success:boolean=false) {
          onClose = jest.fn()
          if (success)
            confirmManager = confirmationManagerSuccess()
          else
            confirmManager = confirmationManagerFailure()
          pane = mountWithIntl(<ConfirmationManagerProvider value={confirmManager}>
          <HoudiniFormik initialValues={{}} onSubmit={onSubmit} render={(props) => 
            <CreateSupporterPaneStateManager formik={props} modal={modalContext} onClose={onClose} createSupporterFormikState={createSupporterFormikState} supporterModalState={supporterModalState} />
          }/>
          </ConfirmationManagerProvider>)
        }
        describe('success', () => {
          let result:boolean
          beforeEach(async (done ) => {
            supporterModalState = new SupporterModalState()
            createSupporterFormikState = new CreateSupporterFormikState()
            
            buildClose(true)

            const stateMgr = (pane.find('CreateSupporterPaneStateManager').instance() as any)
            result = await stateMgr.canClose();
            done()
          })

          it('result is true', () => {
            expect(result).toBeTruthy()
          })

          it('passed in correct data', () => {
            expect(confirmManager.confirm).toBeCalledWith({
              titleText:"create_supporter_modal.confirmation.discard_changes",
              abortButtonText: "create_supporter_modal.confirmation.no_keep_editing",
              confirmButtonText: "create_supporter_modal.confirmation.yes_discard_changes",
              confirmationText: "create_supporter_modal.confirmation.confirmation_text"
            })
          })


        })

        describe('failure', () => {
          let result:boolean
          beforeEach(async (done ) => {
            supporterModalState = new SupporterModalState()
            createSupporterFormikState = new CreateSupporterFormikState()
            
            buildClose(false)

            const stateMgr = (pane.find('CreateSupporterPaneStateManager').instance() as any)
            result = await stateMgr.canClose();
            done()
          })

          it('result is false', () => {
            expect(result).toBeFalsy()
          })

          it('passed in correct data', () => {
            expect(confirmManager.confirm).toBeCalledWith({
              titleText:"create_supporter_modal.confirmation.discard_changes",
              abortButtonText: "create_supporter_modal.confirmation.no_keep_editing",
              confirmButtonText: "create_supporter_modal.confirmation.yes_discard_changes",
              confirmationText: "create_supporter_modal.confirmation.confirmation_text"
            })
          })


        })
      })
    })
    describe('SubmitPhase.HAVE_SUPPORTER', () => {
      
      describe('canClose', () => {
        function buildClose(success:boolean=false) {
          onClose = jest.fn()
          if (success)
            confirmManager = confirmationManagerSuccess()
          else
            confirmManager = confirmationManagerFailure()
          pane = mountWithIntl(<ConfirmationManagerProvider value={confirmManager}>
          <HoudiniFormik initialValues={{}} onSubmit={onSubmit} render={(props) => 
            <CreateSupporterPaneStateManager formik={props} modal={modalContext} onClose={onClose} createSupporterFormikState={createSupporterFormikState} supporterModalState={supporterModalState} />
          }/>
          </ConfirmationManagerProvider>)
        }
        describe('success', () => {
          let result:boolean
          beforeEach(async (done ) => {
            supporterModalState = new SupporterModalState()
            createSupporterFormikState = new CreateSupporterFormikState()
            createSupporterFormikState.setPhase(SubmitPhase.HAVE_SUPPORTER)
            buildClose(true)

            const stateMgr = (pane.find('CreateSupporterPaneStateManager').instance() as any)
            result = await stateMgr.canClose();
            done()
          })

          it('result is true', () => {
            expect(result).toBeTruthy()
          })

          it('passed in correct data', () => {
            expect(confirmManager.confirm).toBeCalledWith({
              titleText:"create_supporter_modal.confirmation.discard_changes",
              abortButtonText: "create_supporter_modal.confirmation.no_keep_editing",
              confirmButtonText: "create_supporter_modal.confirmation.yes_discard_changes",
              confirmationText: "create_supporter_modal.confirmation.confirmation_text_after_supporter_saved"
            })
          })
        })

        describe('failure', () => {
          let result:boolean
          beforeEach(async (done ) => {
            supporterModalState = new SupporterModalState()
            createSupporterFormikState = new CreateSupporterFormikState()
            createSupporterFormikState.setPhase(SubmitPhase.HAVE_SUPPORTER)
            buildClose(false)

            const stateMgr = (pane.find('CreateSupporterPaneStateManager').instance() as any)
            result = await stateMgr.canClose();
            done()
          })

          it('result is false', () => {
            expect(result).toBeFalsy()
          })

          it('passed in correct data', () => {
            expect(confirmManager.confirm).toBeCalledWith({
              titleText:"create_supporter_modal.confirmation.discard_changes",
              abortButtonText: "create_supporter_modal.confirmation.no_keep_editing",
              confirmButtonText: "create_supporter_modal.confirmation.yes_discard_changes",
              confirmationText: "create_supporter_modal.confirmation.confirmation_text_after_supporter_saved"
            })
          })


        })
      })
    })
  })
})