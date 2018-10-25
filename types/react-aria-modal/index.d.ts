// License: LGPL-3.0-or-later

import {Component} from "react";

interface ModalProps {
  underlayProps?: any
  dialogId?:string
  underlayClickExits?: boolean
  escapeExits?:boolean
  onEnter?:() => void
  titleText?:string
  titleId?:string

  applicationNode?:Node
  getApplicationNode?:() => Node
  onExit?:() => void
  alert?: boolean
  includeDefaultStyles?:boolean
  dialogClass?:string
  dialogStyle?:any
  focusDialog?:boolean
  initialFocus?:string
  mounted?:boolean
  underlayStyle?:any
  underlayClass?:any
  underlayClickExits?:boolean
  underlayColor?:string|false
  verticallyCenter?:boolean
  focusTrapPaused?:boolean
  focusTrapOptions?:any
  scrollDisabled?:boolean
}

class Modal extends Component<ModalProps, {}>{}

export = Modal