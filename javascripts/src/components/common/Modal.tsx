// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import AriaModal = require('react-aria-modal');

export interface ModalProps
{
  onClose?: () => void // if you want your modal to close, this needs to set modalActive to false
  modalActive?: boolean
  titleText?: string
  focusDialog?:boolean
  dialogStyle?:any
  childGenerator:() => JSX.Element
}

class Modal extends React.Component<ModalProps, {}> {

  static defaultProps = {
    dialogStyle: {minWidth:'768px'}
  }

  render() {
   const modal = this.props.modalActive ?
      <AriaModal mounted={this.props.modalActive} titleText={this.props.titleText} focusDialog={this.props.focusDialog}
                 onExit={this.props.onClose} dialogStyle={this.props.dialogStyle}>
        <header className='modal-header'>
          <h4 className='modal-header-title'>{this.props.titleText}</h4>
        </header>
        <div className="modal-body">
          {this.props.childGenerator()}
        </div>
      </AriaModal> : false;

      return modal
  }
}

export default observer(Modal)



