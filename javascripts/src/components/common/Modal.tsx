// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import AriaModal = require('react-aria-modal');

export interface ModalProps
{
  onClose?: () => void
  modalActive?: boolean
  titleText?: string
  focusDialog?:boolean
  dialogStyle?:any
  childGenerator:() => JSX.Element
}

class Modal extends React.Component<ModalProps & InjectedIntlProps, {}> {
  render() {
   const modal = this.props.modalActive ?
      <AriaModal mounted={this.props.modalActive} titleText={this.props.titleText} focusDialog={this.props.focusDialog}
                 onExit={this.props.onClose} dialogStyle={this.props.dialogStyle || {minWidth:'768px'}}>
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

export default injectIntl(observer(Modal))



