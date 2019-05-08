// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, disposeOnUnmount } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { SupporterModalState } from './CreateSupporterModal';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import { TwoColumnFields } from '../common/layout';
import FormikBasicField from '../common/FormikBasicField';
import { FieldCreator } from '../common/form/FieldCreator';
import { reaction } from 'mobx';
import { ModalContext } from '../common/modal/Modal';
import { CreateSupporterFormikState, SubmitPhase } from './CreateSupporterFormik';
import { connectConfirmationManager, ConfirmationManagerContextProps } from '../common/modal/confirmation/connect';
import { boundMethod } from 'autobind-decorator';
import { OnCloseType } from '../edit_supporter_modal/SupporterModalBase';


export interface CreateSupporterPaneProps {
  formik: HoudiniFormikProps<any>
  supporterModalState: SupporterModalState
  modal:ModalContext
  createSupporterFormikState:CreateSupporterFormikState
  onClose:OnCloseType
}

class CreateSupporterPane extends React.Component<CreateSupporterPaneProps & InjectedIntlProps & ConfirmationManagerContextProps, {}> {
  
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
    var confirmButtonText:string = "Yes, discard changes"
    var abortButtonText:string = "No, keep editing"
    switch(this.props.createSupporterFormikState.phase)
    {
      
      case SubmitPhase.HAVE_NOTHING:
        var confirmationText:string = "You have unsaved changes. Are you sure you'd like to discard them?"     
        break;
      case SubmitPhase.HAVE_SUPPORTER:
        var confirmationText:string = "Your supporter has been created but we haven't been able to create the address. Would you like to discard the address?"
        break;
    }

    return await this.props.confirmation.confirm({titleText:"Discard changes?", confirmationText: confirmationText, confirmButtonText:confirmButtonText, abortButtonText: abortButtonText})
  }

  render() {
    const formik = this.props.formik
    const disableSupporterFields = this.props.createSupporterFormikState.phase > SubmitPhase.HAVE_NOTHING
    return <HoudiniFormikForm formik={formik}>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'name'} label={'Name'} inputId={FormikHelpers.createId(formik, 'name')} disabled={disableSupporterFields}/>
        <FieldCreator component={FormikBasicField} name={'email'} label={'Email'} inputId={FormikHelpers.createId(formik, 'email')} disabled={disableSupporterFields}/>
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'phone'} label={'Phone'} inputId={FormikHelpers.createId(formik, 'phone')} disabled={disableSupporterFields}/>
        <FieldCreator component={FormikBasicField} name={'organization'} label={'Organization'} inputId={FormikHelpers.createId(formik, 'organization')} disabled={disableSupporterFields}/>
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'address'} label={'Address'} inputId={FormikHelpers.createId(this.props.formik, 'address')} />
        <FieldCreator component={FormikBasicField} name={'city'} label={'City'} inputId={FormikHelpers.createId(this.props.formik, 'city')} />
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'state_code'} label={'State/Region Code'} inputId={FormikHelpers.createId(this.props.formik, 'state_code')} />
        <FieldCreator component={FormikBasicField} name={'zip_code'} label={'Postal/Zip Code'} inputId={FormikHelpers.createId(this.props.formik, 'zip_code')} />
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'country'} label={'Country'} inputId={FormikHelpers.createId(this.props.formik, 'country')} />
      </TwoColumnFields>
    </HoudiniFormikForm>
  }
}

export default connectConfirmationManager(injectIntl(observer(CreateSupporterPane)))



