// License: LGPL-3.0-or-later
import { action, observable, reaction } from 'mobx';
import { disposeOnUnmount, observer } from 'mobx-react';
import * as React from 'react';
import { Transition } from 'react-transition-group';
import BootstrapWrapper from '../BootstrapWrapper';
import { DefaultCloseButton } from '../DefaultCloseButton';
import { Column, Row } from '../layout';
import { ModalProvider } from './connect';
import ModalPrimitive from './ModalPrimitive';
import _ = require('lodash');

export interface ModalChildren {
  body:React.ReactElement<any>,
  footer?:React.ReactElement<any>
}

export interface ModalProps {
  onClose?: () => void // if you want your modal to close, this needs to set modalActive to false
  modalActive?: boolean
  titleText?: string
  focusDialog?: boolean
  dialogStyle?: any
  showCloseButton?: boolean
  
  buttons?: React.ReactElement<any>[]
  alert?: boolean
  escapeExits?: boolean
  underlayClickExits?: boolean
  children:ModalChildren
}

export class ModalContext  {
  @observable titleText:string
  cancel:() =>void
  @observable canClose:() => Promise<boolean>| boolean
  @observable handleCancel: () => void
}

class Modal extends React.Component<ModalProps> {

  constructor(props:ModalProps){
    super(props)
    this.modalState.cancel = () => this.onCancel()
  }

  static defaultProps = {
    dialogStyle: { minWidth: '768px' },
    showCloseButton: true
  }

  @disposeOnUnmount
  reactor = reaction(() => this.props.titleText, (text) => {this.modalState.titleText = text});
  
  @observable modalState = new ModalContext()
  

  @action.bound
  async onCancel() {
    if(!this.modalState.canClose || await this.modalState.canClose())
    {
      if(this.modalState.handleCancel)
        this.modalState.handleCancel()

      if(this.props.onClose) {
        this.props.onClose()
      }
    }
  }

  render() {

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
      <Transition in={this.props.modalActive} timeout={300} unmountOnExit={true}>
        {(state) => {
          return <ModalPrimitive mounted={true} titleText={this.props.titleText} focusDialog={this.props.focusDialog} alert={this.props.alert} escapeExits={this.props.escapeExits} underlayClickExits={this.props.underlayClickExits}
            onExit={this.onCancel} dialogStyle={{...this.props.dialogStyle }} underlayStyle={{...defaultStyle, ...transitionStyles[state]}}>
            <BootstrapWrapper>
              <header className='modal-header' style={{
                position: 'relative',
                padding: '12px 10px 12px 20px'
              }}>
                <Row>
                  <Column colSpan={11} breakSize={'xs'}>
                    <h3 className='modal-header-title' style={{ margin: 0 }}>{this.modalState.titleText}</h3>
                  </Column>
                  {this.props.showCloseButton ?
                    <Column colSpan={1} breakSize={'xs'}>
                      <div style={{ textAlign: 'right' }}>
                        <DefaultCloseButton onClick={() => this.onCancel()} />
                      </div>
                    </Column> : false
                  }
                </Row>
              </header>
              <div className="modal-body">
                <div style={{ position: 'relative' }}>
                  <ModalProvider value={this.modalState}>
                    {this.props.children.body}
                  </ModalProvider>
                </div>
              </div>

              {this.props.children.footer ? this.props.children.footer : false}
            </BootstrapWrapper>
          </ModalPrimitive>
          
        }}
      </Transition>

    return modal
  }

}


export default observer(Modal)



