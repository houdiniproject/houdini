// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import AriaModal = require('react-aria-modal');
import { VelocityTransitionGroup } from 'velocity-react';
import 'velocity-animate';
import 'velocity-animate/velocity.ui';
import { DefaultCloseButton } from './DefaultCloseButton';
import BootstrapWrapper from './BootstrapWrapper';
import { Row, Column } from './layout';

export interface ModalProps {
  onClose?: () => void // if you want your modal to close, this needs to set modalActive to false
  modalActive?: boolean
  titleText?: string
  focusDialog?: boolean
  dialogStyle?: any
  showCloseButton?: boolean
  childGenerator: () => any
}

class Modal extends React.Component<ModalProps, {}> {

  static defaultProps = {
    dialogStyle: { minWidth: '768px' },
    showCloseButton: true
  }

  render() {
    const innerModal = this.props.modalActive ? <AriaModal mounted={this.props.modalActive} titleText={this.props.titleText} focusDialog={this.props.focusDialog}
      onExit={this.props.onClose} dialogStyle={this.props.dialogStyle}>
      <BootstrapWrapper>
        <header className='modal-header' style={{
          position: 'relative',
          padding: '12px 10px 12px 20px'
        }}>
          <Row>
            <Column colSpan={11} breakSize={'xs'}>
              <h3 className='modal-header-title' style={{ margin: 0 }}>{this.props.titleText}</h3>
            </Column>
            {this.props.showCloseButton ?
              <Column colSpan={1} breakSize={'xs'}>
                <div style={{ textAlign: 'right' }}>
                  <DefaultCloseButton onClick={() => this.props.onClose()} />
                </div>
              </Column> : false
            }
          </Row>
        </header>
        <div className="modal-body">
          <div style={{ position: 'relative' }}>
            {this.props.childGenerator()}
          </div>
        </div>
      </BootstrapWrapper>
    </AriaModal> : false

    const modal =
      <VelocityTransitionGroup
        enter={
          {
            animation: 'fadeIn',
            /* These styles are needed because, for some reason, we're 
            not able to cover the sidebar otherwise. Why? *shrug*
            */
            style: {
              position: 'fixed',
              top: '0px',
              left: '0px',
              zIndex: '5000'
            }
          }
        }

        leave={
          {
            animation: 'fadeOut',
            style: {
              position: 'fixed',
              top: '0px',
              left: '0px',
              zIndex: '5000'
            }
          }
        }

        runOnMount={true}>
        {innerModal}
      </VelocityTransitionGroup>;

    return modal
  }

}

export default observer(Modal)



