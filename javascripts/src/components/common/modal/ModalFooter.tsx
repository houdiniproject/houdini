// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import AriaModal = require('react-aria-modal');
import { DefaultCloseButton } from '../DefaultCloseButton';
import BootstrapWrapper from '../BootstrapWrapper';
import { Row, Column } from '../layout';
import { Transition } from 'react-transition-group';
import ModalPrimitive from './ModalPrimitive';
import { observable, action, IObservableArray } from 'mobx';
import { ModalProvider } from './connect';
import _ = require('lodash');

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
}

export interface ModalContext {
  titleText:string
  cancel:() =>void
  setButtons(buttons:React.ReactElement<any>[]): void
  setTitleText(titleText:string):void
  setCanClose(canClose:() => Promise<boolean>| boolean):void
  setCancelAction(cancelAction:() =>void):void
}

class Modal extends React.Component<ModalProps, {buttons:React.ReactElement<any>[]}> {

  static defaultProps = {
    dialogStyle: { minWidth: '768px' },
    showCloseButton: true
  }

  @observable cancelAction: () => void
  @observable canClose: () => Promise<boolean>| boolean
  @observable titleText:string
  buttons:IObservableArray<React.ReactElement<any>> = observable.array<React.ReactElement<any>>()

  @action.bound
  async onCancel() {
    if(!this.canClose || await this.canClose())
    {
      if(this.cancelAction)
        this.cancelAction()

      if(this.props.onClose) {
        this.props.onClose()
      }
    }
  }
 

  @action.bound
  setCanClose(canClose:() => boolean):void {
    this.canClose = canClose
  }

  @action.bound
  setButtons(buttons:React.ReactElement<any>[]):void {
    this.buttons.replace(buttons)
  }

  @action.bound
  setTitleText(titleText:string):void {
    this.titleText = titleText
  }

  @action.bound
  setCancelAction(cancelAction:() =>void) {
    this.cancelAction = cancelAction
  }
  
  createModalContext():ModalContext {
    return {
      titleText: this.titleText,
      cancel: this.onCancel,
      setCanClose: this.setCanClose,
      setButtons: this.setButtons,
      setTitleText: this.setTitleText,
      setCancelAction:this.setCancelAction
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
    const buttons = this.buttons.peek()
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
                    <h3 className='modal-header-title' style={{ margin: 0 }}>{this.titleText}</h3>
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
                  <ModalProvider value={this.createModalContext()}>
                    {this.props.childGenerator()}
                  </ModalProvider>
                </div>
              </div>

              {buttons && buttons.length > 0 ? <footer className={'modal-footer'} style={{ textAlign: 'right' }}>
                {
                  buttons.map((e: React.ReactElement<any>, index: number, array) => {
                    const onLastItem = array.length - 1 == index;
                    const style = onLastItem ? {} : { marginRight: '10px' }
                    return <span style={style} key={e.key}>
                      {e}
                    </span>
                  })
                }
              </footer> : false}
            </BootstrapWrapper>
          </ModalPrimitive>
          
        }}
      </Transition>

    return modal
  }

}


export default observer(Modal)



