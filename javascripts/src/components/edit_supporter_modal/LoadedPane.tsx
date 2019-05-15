// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject, disposeOnUnmount } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { action, observable, reaction } from 'mobx';
import { HoudiniFormikProps } from '../common/HoudiniFormik';
import { Address, Supporter } from '../../../api';
import _ = require('lodash');
import { DefaultAddressStrategy } from './address/default_address_strategy';
import SupporterPane from './SupporterPane';
import AddressModal from './address/AddressModal';
import { AddressAction } from './address/AddressModalForm';
import { LocalRootStore } from './local_root_store';
import { SupporterModalState } from './EditSupporterModal';
import { FormikHelpers } from '../common/HoudiniFormik';
import { connectModal, ModalContextProps } from '../common/modal/connect';
import { connectConfirmationManager, ConfirmationManagerContextProps } from '../common/modal/confirmation/connect';
import { boundMethod } from 'autobind-decorator';

export interface LoadedPaneProps {
  formik: HoudiniFormikProps<Supporter>
  supporterId: number
  addresses: Address[]
  onClose: () => void
  LocalRootStore?: LocalRootStore
  supporterModalState:SupporterModalState
}

class LoadedPane extends React.Component<LoadedPaneProps & InjectedIntlProps & ModalContextProps & ConfirmationManagerContextProps, {}> {
  
  @disposeOnUnmount
  reactOnSubmit = reaction(() => this.props.formik.isSubmitting, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})

  @disposeOnUnmount
  reactOnDirty = reaction(() => this.props.formik.dirty, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})

  @disposeOnUnmount
  reactOnId = reaction(() => this.props.formik.status && this.props.formik.status.id, () => this.updateSupporterModalStoreValues(), {fireImmediately:true})
  
  updateSupporterModalStoreValues(){
    this.props.supporterModalState.setDisableSave(this.props.formik.isSubmitting || !this.props.formik.dirty)

    this.props.supporterModalState.setDisableClose(this.props.formik.isSubmitting)
    
    this.props.supporterModalState.setFormId(FormikHelpers.createFormId(this.props.formik))

    this.props.modal.setCanClose(this.canClose)
  }

  @boundMethod
  async canClose(){
    const confirmButtonText:string = this.props.intl.formatMessage({id: "edit_supporter_modal.confirmation.yes_discard_changes"})
    const abortButtonText:string = this.props.intl.formatMessage({id: "edit_supporter_modal.confirmation.no_keep_editing"})
    const titleText = this.props.intl.formatMessage({id: "edit_supporter_modal.confirmation.discard_changes"})

    var confirmationText:string = this.props.intl.formatMessage({id:"edit_supporter_modal.confirmation.confirmation_text"})

    return !this.props.formik.dirty || await this.props.confirmation.confirm({titleText:titleText, confirmationText: confirmationText, confirmButtonText:confirmButtonText, abortButtonText: abortButtonText})
  }

  @action.bound
  editAddress(address?: Address) {
    
    this.addressToEdit = address || { supporter: { id: this.props.supporterId } }
    this.isDefault = this.isDefaultAddress(this.addressToEdit)
    this.modalOpen = true;
  }

  @action.bound
  addAddress() {
    this.editAddress();
  }

  @observable modalOpen: boolean;

  @observable
  addressToEdit: Address
  
  @observable isDefault:boolean

  @action.bound
  handleAddressAction(action: AddressAction, formik: HoudiniFormikProps<Supporter>, addresses: Address[], addressId: number) {
    this.modalOpen = false

    const addressStrategy = new DefaultAddressStrategy(
      () => addresses,
      () => addressId,
      (addressId: number) => {
        formik.setFieldValue('default_address.id', addressId)
      });
    
    addressStrategy.handleAddressAction(action)

    if (action.type !== 'none')
    {
      formik.setFieldValue('address_has_changed', true)
    }
  }

  @action.bound
  isDefaultAddress(address: Address | number): boolean {
    if (!address) {
      return false;
    }
    let addressId = address
    if (typeof address !== 'number') {
      addressId = address.id
    }
    const defaultAddressId = _.get(this.props.formik.values, "default_address.id")

    return defaultAddressId && addressId && addressId === defaultAddressId;
  }

  render() {
    
    return <>
      <SupporterPane formik={this.props.formik} addresses={this.props.addresses} addAddress={this.addAddress} editAddress={this.editAddress} isDefaultAddress={this.isDefaultAddress}/>
      <AddressModal
        titleText={"Edit Address"}
        modalActive={this.modalOpen}
        onClose={(action: AddressAction) => {
          this.handleAddressAction(action, this.props.formik, this.props.addresses, _.get(this.props.formik.values, "default_address.id"))
        }}
        initialAddress={this.addressToEdit}
        isDefault={this.isDefault} supporterEntity={this.props.LocalRootStore.supporterEntity} />
    </>
  }
}

export default injectIntl(connectConfirmationManager(connectModal(inject('LocalRootStore')(observer(LoadedPane)))))



