// License: LGPL-3.0-or-later
import { observer, disposeOnUnmount } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal, { ModalContext } from '../common/modal/Modal';
import EditSupporterModalStateHolder from './EditSupporterModalStateHolder';
import { OnCloseType } from './SupporterModalBase';
import ModalBody from '../common/modal/ModalBody';
import { observable, computed, action, runInAction, reaction } from 'mobx';
import ModalFooter from '../common/modal/ModalFooter';
import { boundMethod } from 'autobind-decorator';
import Button from '../common/form/Button';
import { connectModal, ModalContextProps } from '../common/modal/connect';


export interface EditSupporterModalProps {
  //from ModalProps
  onClose: OnCloseType
  modalActive: boolean
  nonprofitId: number
  supporterId: number
}
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
  onClose: OnCloseType
  nonprofitId: number
  supporterId: number
  supporterModalState: SupporterModalState
}

class InnerEditSupporterModalChildren extends React.Component<EditSupporterModalChildrenProps & ModalContextProps>{

  @disposeOnUnmount
  reactOnClose = reaction(() => this.props.onClose, () => this.props.modal.setHandleCancel(() => this.props.onClose()), {fireImmediately:true})

  @boundMethod
  cancel() {
    this.props.modal.cancel()
  }

  render() {
    return <>
      <ModalBody>
        <EditSupporterModalStateHolder nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId}
          onClose={this.props.onClose} supporterModalState={this.props.supporterModalState} />
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

const EditSupporterModalChildren = connectModal(observer(InnerEditSupporterModalChildren))

class EditSupporterModal extends React.Component<EditSupporterModalProps & InjectedIntlProps, {}> {
  supporterModalState = new SupporterModalState()
  render() {

    return <Modal
      modalActive={this.props.modalActive}
      titleText={`Edit Supporter #${this.props.supporterId}`}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ width: '600px', position: 'relative' }}
    >
    
      <EditSupporterModalChildren onClose={this.props.onClose} nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId} supporterModalState={this.supporterModalState} />
    </Modal>
  }
}

export default injectIntl(observer(EditSupporterModal))



