// License: LGPL-3.0-or-later
import { action, observable, reaction, computed, runInAction } from 'mobx';
import { disposeOnUnmount, observer } from 'mobx-react';
import * as React from 'react';
import { Transition } from 'react-transition-group';
import BootstrapWrapper from '../BootstrapWrapper';
import { DefaultCloseButton } from '../DefaultCloseButton';
import { Column, Row } from '../layout';
import { ModalProvider } from './connect';
import ModalPrimitive, { ModalPrimitiveProps } from './ModalPrimitive';
import _ = require('lodash');
import { connectModalManager, ModalManagerContextProps } from './connect_modal_manager';


export interface ModalProps {

  /**
   * The action to take when the modal is closed from an action
   * inside the modal
   * 
   * If you expect your modal to close, you need to set the modalActive prop to false
   * @memberof ModalProps
   */
  onClose?: () => void

  /**
   * Whether the modal is opened. Open if true, closed if false
   * @type boolean
   * @memberof ModalProps
   */
  modalActive?: boolean

  /**
   * The text in the header of the modal window. Can also be set via the the setTitleText funtion from the ModalContext object
   * @type string
   * @memberof ModalProps
   */
  titleText?: string


  /**
   * Can the dialog window itself be focusable.
   * @type boolean
   * @memberof ModalProps
   */
  focusDialog?: boolean


  /**
   * Set the style for the modal div itself. Default is {
   * minWidth: 768px}
   * @type React.CSSProperties
   * @memberof ModalProps
   */
  dialogStyle?: React.CSSProperties


  /**
   * Show the close button on the modal window
   * @type boolean
   * @memberof ModalProps
   */
  showCloseButton?: boolean


  /**
   * Whether the window is an alert window. In particular, what means
   * modal role=alertdialog instead of dialog
   * @type boolean
   * @memberof ModalProps
   */
  alert?: boolean

  /**
   * Does pressing the escape key attempt to exit the modal
   * @type boolean
   * @memberof ModalProps
   */
  escapeExits?: boolean

  /**
   * Does pressing the modal underlay attempt to exit the modal
   * @type boolean
   * @memberof ModalProps
   */
  underlayClickExits?: boolean

  handleExited?: () => void
}

/**
 * A context object for manipulating the modal from its children
 * @export
 * @class ModalContext
 */
export class ModalContext {
  @observable private innerTitleText: string
  /**
   * The title text of the modal
   * @readonly
   * @type string
   * @memberof ModalContext
   */
  @computed get titleText(): string {
    return this.innerTitleText;
  }

  /**
   * Change the title text. Can also be changed from the
   * modal property
   * @param  {string} titleText 
   * @return {void}
   * @memberof ModalContext
   */
  @action.bound
  setTitleText(titleText: string) {
    this.innerTitleText = titleText;
  }

  /**
   * Function to call to attempt to cancel/close the modal window
   * @memberof ModalContext
   */
  cancel: () => void

  @observable private innerCanClose: () => Promise<boolean> | boolean

  /**
   * A condition to check whether it is possible to close a modal.
   * This is used to prevent a modal from closing if, for example, data
   * has not been saved.
   * @readonly
   * @memberof ModalContext
   */
  @computed get canClose(): () => Promise<boolean> | boolean {
    return this.innerCanClose;
  }

  /**
   * Set the function checking whether closing a modal is allowed
   * @param  {(() => Promise<boolean> | boolean)} condition 
   * @return {void}
   * @memberof ModalContext
   */
  @action.bound
  setCanClose(condition: () => Promise<boolean> | boolean): void {
    this.innerCanClose = condition
  }

  @observable private innerHandleCancel: () => void

  /**
   * In some cases, the modal's children need to combine the onClose passed into the modal with their own logic. This overrides the normal onClose and likely use the onClose itself
   * @readonly
   * @memberof ModalContext
   */
  @computed get handleCancel(): () => void {
    return this.innerHandleCancel
  }

  @action.bound
  setHandleCancel(cancelAction: () => void) {
    this.innerHandleCancel = cancelAction;
  }
}

class Modal extends React.Component<ModalProps & ModalManagerContextProps> {
  key: string;

  constructor(props: ModalProps & ModalManagerContextProps) {
    super(props)
    this.modalState.cancel = () => this.onCancel()
    this.key = _.uniqueId()
  }
  

  static defaultProps = {
    dialogStyle: { minWidth: '768px' },
    showCloseButton: true
  }
  @observable modalState = new ModalContext()

  @disposeOnUnmount
  reactor = reaction(() => this.props.titleText, (text) => { this.modalState.setTitleText(text) }, { fireImmediately: true });

  componentDidMount() {
    runInAction(() => this.modalState.setTitleText(this.props.titleText))
  }

  @action.bound
  async onCancel() {
    if (!this.modalState.canClose || await this.modalState.canClose()) {
      if (this.modalState.handleCancel) {
        this.modalState.handleCancel()
        return;
      }

      if (this.props.onClose) {
        this.props.onClose()
      }
    }
  }

  @computed
    get isTopModal():boolean {
      return this.props.modalManager.top === this.key
    }

    @action.bound
    onEnter() {
      this.props.modalManager.push(this.key)
    }

    @action.bound
    onExit() {
      this.props.modalManager.remove(this.key)
      if (this.props.handleExited){
        this.props.handleExited()
      }
    }

    componentWillUnmount(){
      //it's possible we're unmounting but onClose wasn't run. In that case, we make sure the modalManager is the correct state.
      this.props.modalManager.remove(this.key)
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

    const transitionStyles: { [state: string]: any } = {
      entering: { opacity: 1 },
      entered: { opacity: 1 },
      exiting: { opacity: 0 },
      exited: { opacity: 0 },
    };

    

    const modal =
      <Transition in={this.props.modalActive} timeout={300} unmountOnExit={true} onEnter={this.onEnter} onExited={this.onExit} mountOnEnter={true} appear={true}>
        {(state) => {
          const additionalProps:ModalPrimitiveProps = {
            'aria-hidden': !this.isTopModal,
            escapeExits: this.isTopModal && this.props.escapeExits,
            underlayClickExits: this.isTopModal && this.props.underlayClickExits,
            scrollDisabled: this.isTopModal,
            dialogId: `react-aria-modal-dialog-${this.key}`,
            titleText: this.props.titleText,
            focusDialog: this.props.focusDialog, 
            alert:this.props.alert,
            onExit: this.onCancel,
            dialogStyle:{ ...this.props.dialogStyle },
            underlayStyle: { ...defaultStyle, ...transitionStyles[state] }
          }


          return <ModalPrimitive mounted={true} {...additionalProps} >
            <BootstrapWrapper>
              <header className='modal-header' style={{
                position: 'relative',
                padding: '12px 10px 12px 20px'
              }}>
                <Row>
                  {/* TODO: This only really works if the modal is above a certain size. We should use flex box here to be more reliable */}
                  <Column colSpan={10} breakSize={'xs'}>
                    <h3 className='modal-header-title' style={{ margin: 0 }}>{this.modalState.titleText}</h3>
                  </Column>
                  {this.props.showCloseButton ?
                    <Column colSpan={2} breakSize={'xs'}>
                      <div style={{ textAlign: 'right' }}>
                        <DefaultCloseButton onClick={() => this.onCancel()} />
                      </div>
                    </Column> : false
                  }
                </Row>
              </header>

              <ModalProvider value={this.modalState}>
                {this.props.children}
              </ModalProvider>

            </BootstrapWrapper>
          </ModalPrimitive>

        }}
      </Transition>

    return modal
  }

}


export default connectModalManager(observer(Modal))



