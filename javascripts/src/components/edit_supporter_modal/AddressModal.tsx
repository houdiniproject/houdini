// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { Address } from '../../../api/model/Address';
import Modal, { ModalContext } from '../common/modal/Modal';
import { observable, action } from 'mobx';
import Button from '../common/form/Button';
import { connect } from '../common/modal/connect';
import AddressModalForm, { AddressAction } from './AddressModalForm';

export interface AddressModalProps
{
  initialAddress: Address
  isDefault?: boolean
  titleText:string
  onClose: (action: AddressAction) => void
  modalActive: boolean
}

export class AddressModalState {
  
  @observable disabledAddSave:boolean
  @observable showDelete:boolean
  @observable saveAddAction:() => void
  @observable deleteAction?:() => void
}

class InnerAddressModalButtons extends React.Component<AddressModalState & {modal: ModalContext}>
{
  render(){
    const array =  [<Button type="button" onClick={() => {this.props.modal.cancel()}}>Close</Button>,
    <Button type="submit" disabled={!this.props.disabledAddSave} onClick={this.props.saveAddAction}>Save</Button>]
    if (this.props.showDelete) {
      array.push(<Button type="submit" onClick={this.props.deleteAction}>Delete</Button>)
    }

    return array;
            
  }
}



const AddressModalButtons = connect(observer(InnerAddressModalButtons))

class AddressModal extends React.Component<AddressModalProps, {}> {

  addressModalState = new AddressModalState()
 
  render() {

     return <Modal titleText={this.props.titleText} modalActive={this.props.modalActive}>
        {{
        body:<AddressModalForm initialAddress={this.props.initialAddress} isDefault={this.props.isDefault} onClose={this.props.onClose} addressModalState={this.addressModalState}/>,
        footer: <AddressModalButtons {...this.addressModalState} />
        }
      }
     </Modal>
  }
}

export default observer(AddressModal)



