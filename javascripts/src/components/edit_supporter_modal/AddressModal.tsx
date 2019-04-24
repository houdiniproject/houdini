// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import AddressPane, { AddressAction } from './AddressPane';
import { Address } from '../../../api/model/Address';
import { LocalRootStore } from './local_root_store';
import Modal from '../common/Modal';
import { observable, action } from 'mobx';
import Button from '../common/form/Button';

export interface AddressModalProps
{
  initialAddress: Address
  isDefault?: boolean
  titleText:string
  onClose: (action: AddressAction) => void
  modalActive: boolean
}

class AddressModal extends React.Component<AddressModalProps, {}> {

  @observable buttons:Button[] = null
  @action.bound
  setButtons(buttons:Button[]){
    this.buttons = buttons
  }

  render() {
     return <Modal titleText={this.props.titleText} childGenerator={() => {
       return <AddressPane initialAddress={this.props.initialAddress} isDefault={this.props.isDefault} onClose={this.props.onClose} setButtons={this.setButtons} />

     }}/>
  }
}

export default observer(AddressModal)



