// License: LGPL-3.0-or-later
import { action, computed, reaction } from 'mobx';
import { disposeOnUnmount, inject, observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { FieldCreator } from '../common/form/FieldCreator';
import { FormikCheckbox } from '../common/form/FormikCheckbox';
import FormNotificationBlock from '../common/form/FormNotificationBlock';
import FormikBasicField from '../common/FormikBasicField';
import { FormikHelpers, HoudiniFormikProps } from '../common/HoudiniFormik';
import { TwoColumnFields } from '../common/layout';
import { Confirmer } from '../common/modal/confirmation/types';
import { connect as connectModal } from '../common/modal/connect';
import { ModalContext } from '../common/modal/Modal';
import { AddressModalState } from './AddressModal';
import { AddressAction, AddressPaneFormikInputProps } from './AddressModalForm';
import { LocalRootStore } from './local_root_store';

export interface AddressPaneProps {
  onClose: (action: AddressAction) => void
  LocalRootStore?: LocalRootStore
  ConfirmationManager?: Confirmer
  formik:HoudiniFormikProps<AddressPaneFormikInputProps>
  addressModalState: AddressModalState
}

class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps &{modal:ModalContext}, {}> {

  @disposeOnUnmount
  reactOnChanges = reaction(() => 
  this.props.formik.dirty || 
  this.props.onClose ||
  this.modifiedEnoughToSubmit ||
  this.isAdd, () => {
    this.props.modal.canClose = async () => {return await this.canClose(this.props.formik.dirty)}
    this.props.modal.handleCancel = () => this.props.onClose({type:'none'})
    this.props.addressModalState.disabledAddSave = this.modifiedEnoughToSubmit
    this.props.addressModalState.showDelete = this.isAdd
    this.props.addressModalState.deleteAction = () => {this.props.formik.setFieldValue('shouldDelete', true); this.props.formik.submitForm(); }
    this.props.addressModalState.saveAddAction = () => this.props.formik.submitForm()
  })

 

  @computed
  get modifiedEnoughToSubmit():boolean {
    return this.props.formik.dirty && !(
      FormikHelpers.isEmpty(this.props.formik.values.address)
      && FormikHelpers.isEmpty(this.props.formik.values.city)
      && FormikHelpers.isEmpty(this.props.formik.values.state_code)
      && FormikHelpers.isEmpty(this.props.formik.values.zip_code)
      && FormikHelpers.isEmpty(this.props.formik.values.country)
    )
  }

  @computed
  get isAdd() {
    return !this.props.formik.values.id
  }

  @action.bound
  async canClose(dirty: boolean) : Promise<boolean> {
    return !dirty || await this.props.ConfirmationManager.confirm({
      titleText: 'Unsaved changes',
      confirmationText: "You have unsaved changes. Are you sure you'd like to discard it?",
      confirmButtonText: "Yes, discard changes",
      abortButtonText: "No, keep editing"
    })
  }

  render() {
        return (
          
          <form onSubmit={this.props.formik.handleSubmit} onReset={this.props.formik.handleReset}>
            <div>
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
              <FieldCreator component={FormikCheckbox} name={'isDefault'} label={"Set as Default Address"} id={FormikHelpers.createId(this.props.formik, 'isDefault')} />

              {
                (this.props.formik.status && this.props.formik.status.form) ? <FormNotificationBlock>{this.props.formik.status.form}</FormNotificationBlock> : ""
              }


            </div>
          </form>
          
        )
 
  }
}

export default connectModal(injectIntl(inject('LocalRootStore')(inject('ConfirmationManager')(observer(AddressPane)))))



