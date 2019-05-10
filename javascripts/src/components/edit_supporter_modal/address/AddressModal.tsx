// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { Address } from '../../../../api/model/Address';
import Modal, { ModalContext } from '../../common/modal/Modal';
import { observable, action, runInAction, computed} from 'mobx';
import Button from '../../common/form/Button';
import { connectModal, ModalContextProps } from '../../common/modal/connect';
import AddressModalForm, { AddressAction } from './AddressModalForm';
import ModalFooter from '../../common/modal/ModalFooter';
import ModalBody from '../../common/modal/ModalBody';
import { SupporterEntity } from '../supporter_entity';
import { boundMethod } from 'autobind-decorator';
/**
 * 
 * @interface AddressModalChildrenProps
 */
interface AddressModalChildrenProps {
  initialAddress: Address
  isDefault?: boolean
  onClose: (action: AddressAction) => void
  addressModalState: AddressModalState
  supporterEntity:SupporterEntity
}

class InnerAddressModalChildren extends React.Component<AddressModalChildrenProps & ModalContextProps>{
  componentDidMount(){
    runInAction(() => 
      this.props.modal.setHandleCancel(() => this.props.onClose({type:'none'}))
    )
  }

  @boundMethod
  cancel() {
    this.props.modal.cancel()
  }
  
  render() {
    return <>
      <ModalBody>
        <AddressModalForm
          initialAddress={this.props.initialAddress}
          isDefault={this.props.isDefault}
          addressModalState={this.props.addressModalState}
          onClose={this.props.onClose}
          supporterEntity={this.props.supporterEntity}
        />
      </ModalBody>
      <ModalFooter>
        <Button type="button" onClick={this.cancel} disabled={this.props.addressModalState.disableCloseButton}>
          Close
        </Button>   
        {this.props.addressModalState.showDelete ?
          <Button type="button" onClick={this.props.addressModalState.deleteAction} disabled={this.props.addressModalState.disableDeletebutton}>Delete</Button>
          : undefined
        }
         <Button type="submit"
          disabled={this.props.addressModalState.disableAddSave} form={this.props.addressModalState.formId}>Save
        </Button>
      </ModalFooter>
    </>
  }
}

const AddressModalChildren = connectModal(observer(InnerAddressModalChildren))


export class AddressModalState {

  @observable private innerDisableAddSave: boolean
  
  @computed  get disableAddSave() : boolean {
    return this.innerDisableAddSave;
  }
  @action.bound
  setDisableAddSave(disableAddSave:boolean)  {
    this.innerDisableAddSave = disableAddSave;
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

  @observable private innerDisableCloseButton:boolean = false

  @computed get disableCloseButton(): boolean {
    return this.innerDisableCloseButton
  }

  @action.bound
  setDisableCloseButton(disabled:boolean) {
    this.innerDisableCloseButton = disabled;
  }

  @observable private innerDisableDeleteButton:boolean = false

  @computed get disableDeletebutton():boolean {
    return this.innerDisableDeleteButton;
  }

  @action.bound
  setDisableDeleteButton(disable:boolean) {
    this.innerDisableDeleteButton = disable;
  }

  @observable
  private innerFormId: string
  
  @computed get formId() : string {
    return this.innerFormId;
  }
  
  @action.bound
  setFormId(formId:string) {
    this.innerFormId = formId;
  }
  
  
}

export interface AddressModalProps {
  initialAddress: Address
  isDefault?: boolean
  titleText: string
  onClose: (action: AddressAction) => void
  modalActive: boolean,
  supporterEntity:SupporterEntity
}

class AddressModal extends React.Component<AddressModalProps, {}> {

  addressModalState = new AddressModalState()

  render() {

    return <Modal titleText={this.props.titleText} modalActive={this.props.modalActive} dialogStyle={{ minWidth: '600px', position: 'relative', width:'600px' }}>
        <AddressModalChildren initialAddress={this.props.initialAddress} isDefault={this.props.isDefault} onClose={this.props.onClose} addressModalState={this.addressModalState} supporterEntity={this.props.supporterEntity}/>
    </Modal>
  }
}

export default observer(AddressModal)



