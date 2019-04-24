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
import { Transition } from 'react-transition-group';

export interface ModalProps {
  onClose?: () => void // if you want your modal to close, this needs to set modalActive to false
  modalActive?: boolean
  titleText?: string
  focusDialog?: boolean
  dialogStyle?: any
  showCloseButton?: boolean
  childGenerator: () => any
  buttons?: React.ReactElement<any>[]
  alert?: boolean
  escapeExits?: boolean
  underlayClickExits?: boolean
  onExited?: () => void
}

class Modal extends React.Component<ModalProps, {}> {

  static defaultProps = {
    dialogStyle: { minWidth: '768px' },
    showCloseButton: true
  }

  render() {
    const innerModal = this.props.modalActive ? <AriaModal mounted={this.props.modalActive} titleText={this.props.titleText} focusDialog={this.props.focusDialog} alert={this.props.alert} escapeExits={this.props.escapeExits} underlayClickExits={this.props.underlayClickExits}
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

        {this.props.buttons && this.props.buttons.length > 0 ? <footer className={'modal-footer'} style={{ textAlign: 'right' }}>
          {
            this.props.buttons.map((e: React.ReactElement<any>, index: number, array) => {
              const onLastItem = array.length - 1 == index;
              const style = onLastItem ? {} : { marginRight: '10px' }
              return <span style={style}>
                {e}
              </span>
            })
          }
        </footer> : false}
      </BootstrapWrapper>
    </AriaModal> : false

    const defaultStyle = {
      position: 'fixed',
      top: '0px',
      left: '0px',
      zIndex: '5000',
      transition: `opacity 300ms ease-in-out`,
      opacity: 0,
    }

    const transitionStyles: {[state: string]: any}  = {
      entering: { opacity: 1 },
      entered:  { opacity: 1 },
      exiting:  { opacity: 0 },
      exited:  { opacity: 0 },
    };

    const modal =
      <Transition in={this.props.modalActive} timeout={300} onExited={this.props.onClose} unmountOnExit={true}>
        {(state) => {
          return <div style={{...defaultStyle, ...transitionStyles[state]}}>

       
          <AriaModal mounted={true} titleText={this.props.titleText} focusDialog={this.props.focusDialog} alert={this.props.alert} escapeExits={this.props.escapeExits} underlayClickExits={this.props.underlayClickExits}
            onExit={this.props.onClose} dialogStyle={{...this.props.dialogStyle }}>
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

              {this.props.buttons && this.props.buttons.length > 0 ? <footer className={'modal-footer'} style={{ textAlign: 'right' }}>
                {
                  this.props.buttons.map((e: React.ReactElement<any>, index: number, array) => {
                    const onLastItem = array.length - 1 == index;
                    const style = onLastItem ? {} : { marginRight: '10px' }
                    return <span style={style}>
                      {e}
                    </span>
                  })
                }
              </footer> : false}
            </BootstrapWrapper>
          </AriaModal>
          </div>
        }}
      </Transition>

    return modal
  }

}

export default observer(Modal)



