// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import AriaModal = require('react-aria-modal');
import _ = require('lodash');
import { action, computed } from 'mobx';
import { ModalManagerInterface } from './modal_manager';

export interface ModalPrimitiveProps extends AriaModal.ModalProps
{
  ModalManager?:ModalManagerInterface
}

@inject('ModalManager')
@observer
class ModalPrimitive extends React.Component<ModalPrimitiveProps, {}> {
  constructor(props:ModalPrimitiveProps) {
    super(props)
    this.key = _.uniqueId()
  }

  static defaultProps = {
    underlayProps: {},
    underlayClickExits: true,
    escapeExits: true,
    underlayColor: 'rgba(0,0,0,0.5)',
    includeDefaultStyles: true,
    focusTrapPaused: false,
    scrollDisabled: true
  };
  
  key:string
  
  get dialogId(): string {
    return this.props.dialogId || `react-aria-modal-dialog-${this.key}`
  }

  @computed
  get isTopModal():boolean {
    return this.props.ModalManager.top === this.key
  }
  
  @action.bound
  onEnter() {
    this.props.ModalManager.push(this.key)
    if (this.props.onEnter) {
      this.props.onEnter()
    }
  }

  @action.bound
  onExit() {
    this.props.ModalManager.remove(this.key)
    if (this.props.onExit) {
      this.props.onExit()
    }
  }

  render() {
    const additionalProps:AriaModal.ModalProps = {
      onEnter: this.onEnter,
      onExit: this.onExit,
      'aria-hidden': !this.isTopModal,
      escapeExits: this.isTopModal && this.props.escapeExits,
      underlayClickExits: this.isTopModal && this.props.underlayClickExits,
      scrollDisabled: this.isTopModal && this.props.scrollDisabled,
      dialogId: this.dialogId
    }

    const mostProps = { ...this.props, ...{modalManager: undefined}}

    return <AriaModal {...mostProps} {...additionalProps}/>;
  }
}

export default ModalPrimitive



