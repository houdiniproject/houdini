// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { Address } from '../../../../api/model/Address';
import Modal, { ModalContext } from '../../common/modal/Modal';
import { observable, action, runInAction, computed} from 'mobx';
import Button from '../../common/form/Button';
import { connect } from '../../common/modal/connect';
import AddressModalForm, { AddressAction } from './AddressModalForm';
import ModalFooter from '../../common/modal/ModalFooter';
import ModalBody from '../../common/modal/ModalBody';
/**
 * 
 * @interface AddressModalChildrenProps
 */
interface AddressModalChildrenProps {
  initialAddress: Address
  isDefault?: boolean
  onClose: (action: AddressAction) => void
  addressModalState: AddressModalState
}

class InnerAddressModalChildren extends React.Component<AddressModalChildrenProps & { modal: ModalContext }>{
  componentDidMount(){
    runInAction(() => 
      this.props.modal.setHandleCancel(() => this.props.onClose({type:'none'}))
    )
  }
  render() {
    return <>
      <ModalBody>
        <AddressModalForm
          initialAddress={this.props.initialAddress}
          isDefault={this.props.isDefault}
          addressModalState={this.props.addressModalState}
          onClose={this.props.onClose}
        />
      </ModalBody>
      <ModalFooter>
        <Button type="button" onClick={() => { this.props.modal.cancel() }}>
          Close
        </Button>
        <Button type="submit"
          disabled={!this.props.addressModalState.disabledAddSave} onClick={this.props.addressModalState.saveAddAction}>Save
        </Button>
        {this.props.addressModalState.showDelete ?
          <Button type="submit" onClick={this.props.addressModalState.deleteAction}>Delete</Button>
          : undefined
        }
      </ModalFooter>
    </>
  }
}

const AddressModalChildren = connect(observer(InnerAddressModalChildren))


export class AddressModalState {

  @observable private innerDisabledAddSave: boolean
  @computed  get disabledAddSave() : boolean {
    return this.innerDisabledAddSave;
  }
  @action.bound
  setDisabledAddSave(disableAddSave:boolean)  {
    this.innerDisabledAddSave = disableAddSave;
  }
  @observable private innerShowDelete: boolean

  @computed get showDelete() : boolean {
    return this.innerShowDelete;
  }

  @action.bound
  setShowDelete(showDelete:boolean) {
    this.innerShowDelete = showDelete;
  }


  @observable private innerSaveAddAction: () => void

  @computed get saveAddAction(): () => void
  {
    return this.innerSaveAddAction;
  }

  @action.bound
  setSaveAddAction(action:() => void){
    this.innerSaveAddAction = action;
  }
  
  @observable private innerDeleteAction?: () => void

  @computed get deleteAction():()=> void {
    return this.innerDeleteAction;
  }

  @action.bound
  setDeleteAction(action:() => void) {
    this.innerDeleteAction = action;
  }
}

export interface AddressModalProps {
  initialAddress: Address
  isDefault?: boolean
  titleText: string
  onClose: (action: AddressAction) => void
  modalActive: boolean
}

class AddressModal extends React.Component<AddressModalProps, {}> {

  addressModalState = new AddressModalState()

  render() {

    return <Modal titleText={this.props.titleText} modalActive={this.props.modalActive}>
        <AddressModalChildren initialAddress={this.props.initialAddress} isDefault={this.props.isDefault} onClose={this.props.onClose} addressModalState={this.addressModalState} />
    </Modal>
  }
}

export default observer(AddressModal)



