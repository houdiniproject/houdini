// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, disposeOnUnmount } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { SupporterModalState } from './CreateSupporterModal';
import { ModalContext } from '../common/modal/Modal';
import { CreateSupporterFormikState, SubmitPhase } from './CreateSupporterFormik';
import { OnCloseType } from '../edit_supporter_modal/SupporterModalBase';
import { reaction } from 'mobx';
import { boundMethod } from 'autobind-decorator';
import { connectConfirmationManager, ConfirmationManagerContextProps } from '../common/modal/confirmation/connect';
import CreateSupporterPane from './CreateSupporterPane';

export interface CreateSupporterPaneStateManagerProps
{
  formik: HoudiniFormikProps<any>
  supporterModalState: SupporterModalState
  modal:ModalContext
  createSupporterFormikState:CreateSupporterFormikState
  onClose:OnCloseType
}

class CreateSupporterPaneStateManager extends React.Component<CreateSupporterPaneStateManagerProps & InjectedIntlProps & ConfirmationManagerContextProps, {}> {
  @disposeOnUnmount
  reactOnSubmit = reaction(() => this.props.formik.isSubmitting, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})

  @disposeOnUnmount
  reactOnDirty = reaction(() => this.props.formik.dirty, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})

  @disposeOnUnmount
  reactOnId = reaction(() => this.props.formik.status && this.props.formik.status.id, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})

  @disposeOnUnmount
  reactOnPhase = reaction(() => this.props.createSupporterFormikState.phase, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})
  
  @boundMethod
  updateSupporterModalStoreValues(){
    this.props.supporterModalState.setDisableSave(this.props.formik.isSubmitting || !this.props.formik.dirty)

    this.props.supporterModalState.setDisableClose(this.props.formik.isSubmitting)
    
    this.props.supporterModalState.setFormId(FormikHelpers.createFormId(this.props.formik))

    this.props.modal.setCanClose(this.canClose)

    switch(this.props.createSupporterFormikState.phase){
      case SubmitPhase.HAVE_NOTHING: {
        this.props.modal.setHandleCancel(() => this.props.onClose());
        break;
      }
      default: {
        this.props.modal.setHandleCancel(() => this.props.onClose(this.props.createSupporterFormikState.supporter.id))
        break;
      }
    }
    
  }

  @boundMethod
  async canClose(){
    const confirmButtonText:string = this.props.intl.formatMessage({id: "create_supporter_modal.confirmation.yes_discard_changes"})
    const abortButtonText:string = this.props.intl.formatMessage({id: "create_supporter_modal.confirmation.no_keep_editing"})
    const titleText = this.props.intl.formatMessage({id: "create_supporter_modal.confirmation.discard_changes"})
    switch(this.props.createSupporterFormikState.phase)
    {
      
      case SubmitPhase.HAVE_NOTHING:
        var confirmationText:string = this.props.intl.formatMessage({id:"create_supporter_modal.confirmation.confirmation_text"})
        break;
      case SubmitPhase.HAVE_SUPPORTER:
        var confirmationText:string = this.props.intl.formatMessage({id:"create_supporter_modal.confirmation.confirmation_text_after_supporter_saved"})
        break;
    }

    return await this.props.confirmation.confirm({titleText:titleText, confirmationText: confirmationText, confirmButtonText:confirmButtonText, abortButtonText: abortButtonText})
  }

  render() {
     return <CreateSupporterPane formik={this.props.formik} submitPhase={this.props.createSupporterFormikState.phase}/>;
  }
}

export default connectConfirmationManager(injectIntl(observer(CreateSupporterPaneStateManager)))



