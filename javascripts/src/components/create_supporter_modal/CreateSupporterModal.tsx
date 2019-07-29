// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, disposeOnUnmount, inject } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import { boundMethod } from 'autobind-decorator';
import { runInAction, action, observable, computed } from 'mobx';
import ModalBody from '../common/modal/ModalBody';
import ModalFooter from '../common/modal/ModalFooter';
import Button from '../common/form/Button';
import { connectModal, ModalContextProps } from '../common/modal/connect';
import Modal, { ModalContext } from '../common/modal/Modal';
import { OnCloseType } from '../edit_supporter_modal/SupporterModalBase';
import CreateSupporterFormik from './CreateSupporterFormik';
import { RootStore } from '../../lib/stores/root_store';
import { ApiManager } from '../../lib/api_manager';


export class SupporterModalState {

  @observable
  private innerDisableSave: boolean

  @computed get disableSave(): boolean {
    return this.innerDisableSave;
  }

  @action.bound
  setDisableSave(disableSave: boolean) {
    this.innerDisableSave = disableSave;
  }

  @observable
  private innerDisableCloseButton: boolean

  @computed get disableCloseButton(): boolean {
    return this.innerDisableCloseButton;
  }

  @action.bound
  setDisableClose(disableClose: boolean) {
    this.innerDisableCloseButton = disableClose;
  }

  @observable
  private innerShowSaveButton: boolean

  @computed get showSaveButton(): boolean {
    return this.innerShowSaveButton;
  }

  @action.bound
  setShowSaveButton(showSaveButton: boolean) {
    this.innerShowSaveButton = showSaveButton;
  }

  @observable
  private innerCloseAction: () => void

  @computed get closeAction(): () => void {
    return this.innerCloseAction;
  }

  @action.bound
  setCloseAction(closeAction: () => void) {
    this.innerCloseAction = closeAction;
  }

  @observable
  private innerFormId: string

  @computed get formId(): string {
    return this.innerFormId;
  }

  @action.bound
  setFormId(formId: string) {
    this.innerFormId = formId;
  }
}

export interface EditSupporterModalChildrenProps {
  //from ModalProps
  nonprofitId: number
  supporterModalState: SupporterModalState
  onClose: OnCloseType
  ApiManager?:ApiManager
}

class InnerCreateSupporterModalChildren extends React.Component<EditSupporterModalChildrenProps & ModalContextProps>{

  constructor(props: EditSupporterModalChildrenProps & ModalContextProps){
    super(props)
    this.rootStore = new RootStore(this.props.ApiManager)
  }
  private rootStore:RootStore

  @boundMethod
  cancel() {
    this.props.modal.cancel()
  }

  render() {
    return <>
      <ModalBody>
        <CreateSupporterFormik nonprofitId={this.props.nonprofitId}
          onClose={this.props.onClose} supporterModalState={this.props.supporterModalState} modal={this.props.modal} rootStore={this.rootStore}/>
      </ModalBody>
      <ModalFooter>
        <Button type="button" onClick={this.cancel} disabled={this.props.supporterModalState.disableCloseButton}>
          Close
        </Button>
        <Button type="submit"
          disabled={this.props.supporterModalState.disableSave} form={this.props.supporterModalState.formId}>Save
        </Button>
      </ModalFooter>
    </>
  }
}

const CreateSupporterModalChildren = connectModal(inject('ApiManager')(observer(InnerCreateSupporterModalChildren)))


export interface CreateSupporterModalProps
{
  nonprofitId:number
  modalActive: boolean
  onClose: OnCloseType
}

class CreateSupporterModal extends React.Component<CreateSupporterModalProps & InjectedIntlProps, {}> {
  supporterModalState = new SupporterModalState()
  render() {

    return <Modal
      modalActive={this.props.modalActive}
      titleText={`Create Supporter`}
      onClose={this.props.onClose}
      dialogStyle={{ width: '600px', position: 'relative' }}
    >
    
      <CreateSupporterModalChildren onClose={this.props.onClose} nonprofitId={this.props.nonprofitId} supporterModalState={this.supporterModalState} />
    </Modal>
  }
}

export default injectIntl(observer(CreateSupporterModal))



