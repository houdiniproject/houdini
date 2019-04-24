// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { action, observable } from 'mobx';
import AddressPane, { AddressAction } from './AddressPane';
import { HoudiniFormikProps } from '../common/HoudiniFormik';
import { Address, Supporter } from '../../../api';
import _ = require('lodash');
import { DefaultAddressStrategy } from './default_address_strategy';
import SupporterPane from './SupporterPane';
import AddressModal from './AddressModal';

export interface LoadedPaneProps {
  formik: HoudiniFormikProps<Supporter>
  supporterId: number
  addresses: Address[]
  onClose: () => void
}

class LoadedPane extends React.Component<LoadedPaneProps & InjectedIntlProps, {}> {
  
  @action.bound
  editAddress(address?: Address) {
    this.addressToEdit = address || { supporter: { id: this.props.supporterId } }
  }

  @action.bound
  addAddress() {
    this.editAddress();
  }

  @observable
  addressToEdit: Address

  @action.bound
  handleAddressAction(action: AddressAction,  formik:HoudiniFormikProps<Supporter>, addresses:Address[], addressId:number) {
    this.addressToEdit = null;
    
    const addressStrategy = new DefaultAddressStrategy(
      () => addresses,
      () => addressId,
      (addressId: number) => {
        formik.setFieldValue('default_address.id', addressId)
      });

    addressStrategy.handleAddressAction(action)
  }

  @action.bound
  isDefaultAddress(address: Address | number): boolean {
    if (!address )
    {
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
      const editAddress = this.addressToEdit
      return <>
        <SupporterPane formik={this.props.formik} addresses={this.props.addresses} addAddress={this.addAddress} editAddress={this.editAddress} isDefaultAddress={this.isDefaultAddress} onClose={this.props.onClose} /> 
        <AddressModal 
        titleText={"Edit Address"}
        modalActive={!!editAddress}
          onClose={(action:AddressAction) => { this.handleAddressAction(action, this.props.formik, this.props.addresses, _.get(this.props.formik.values, "default_address.id"))
          }}
          initialAddress={this.addressToEdit}
          isDefault={this.isDefaultAddress(this.addressToEdit)} />
      </>
  }
}

export default injectIntl(inject('LocalRootStore')(observer(LoadedPane)))



