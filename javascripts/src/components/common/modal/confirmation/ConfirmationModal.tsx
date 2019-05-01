// License: LGPL-3.0-or-later
import React = require("react");
import { action, observable } from "mobx";
import { observer } from "mobx-react";
import Button from "../../form/Button";
import Modal from "../Modal";
import ModalFooter from "../ModalFooter";
import { ConfirmationModalProps } from "./types";
import ModalBody from "../ModalBody";

@observer
export class ConfirmationModal extends React.Component<ConfirmationModalProps, {}> {

  @observable
  modalActive: boolean = true;

  @action.bound
  confirm() {
    this.modalActive = false;
    this.props.confirmation.resolver(true);
  }

  @action.bound
  abort() {
    this.modalActive = false;
    this.props.confirmation.resolver(false);
  }

  render() {

    return <Modal titleText={this.props.confirmation.titleText}
      showCloseButton={false} escapeExits={false} alert={true}
      underlayClickExits={false} modalActive={this.modalActive}
     
    >
     <><ModalBody>
        <div>{this.props.confirmation.confirmationText}</div>
      </ModalBody>

      <ModalFooter>
        <Button onClick={this.confirm}>
          {this.props.confirmation.confirmButtonText}
        </Button>
        <Button onClick={this.abort}>
          {this.props.confirmation.abortButtonText}
        </Button>
      </ModalFooter></>
    </Modal>;
  }
}
