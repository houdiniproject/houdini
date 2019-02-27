// License: LGPL-3.0-or-later

import { Component } from "react";

interface ModalProps {
  
  /**
   * Choose your own id attribute for the dialog element.
   * Default is `react-aria-modal-dialog`
   * @type string
   * @memberof ModalProps
   */
  dialogId?: string

  /**
   * By default, the Escape key exits the modal. Pass false, and it won't.
   * @type boolean
   * @memberof ModalProps
   */
  escapeExits?: boolean

  /**
   * This function is called in the modal's componentDidMount() lifecycle method. You can use it to do whatever diverse and sundry things you feel like doing after the modal activates.
   * @memberof ModalProps
   */
  onEnter?: () => void

  /**
   * A string to use as the modal's accessible title. This value is passed to the modal's `aria-label` attribute.

You must use either `titleId` or `titleText`, but not both.
   * @type string
   * @memberof ModalProps
   */
  titleText?: string

  /**
   * The id of the element that should be used as the modal's accessible title. This value is passed to the modal's `aria-labelledby` attribute.

You must use either `titleId` or `titleText`, but not both.
   * @type string
   * @memberof ModalProps
   */
  titleId?: string

  /**
   * Provide your main application node here (which the modal should render outside of), and when the modal is open this application node will receive the attribute `aria-hidden="true"`. This can help screen readers understand what's going on.

This module can't guess your application node, so you have to provide this prop to get the full accessibility benefit.
   * @type Node
   * @memberof ModalProps
   */
  applicationNode?: Node
  /**
   * Same as `applicationNode`, but a function that returns the node instead of the node itself. This can be useful or necessary in a variety of situations, one of which is server-side React rendering. The function will not be called until after the component mounts, so it is safe to use browser globals and refer to DOM nodes within it (e.g. document.getElementById(..)), without ruining your server-side rendering.
   * @memberof ModalProps
   */
  getApplicationNode?: () => Node
  /**
   * This function handles the state change of exiting (or deactivating) the modal. It will be invoked when the user clicks outside the modal (if `underlayClickExits={true}`, as is the default) or hits Escape (if `escapeExits={true}`, as is the default), and it receives the event that triggered it as its only argument.

Maybe it's just a wrapper around setState(); or maybe you use some more involved Flux-inspired state management — whatever the case, this module leaves the state management up to you instead of making assumptions. That also makes it easier to create your own "close modal" buttons; because you have the function that closes the modal right there, written by you, at your disposal.

You may omit this prop if you don't want clicks outside the modal or Escape to close it, so don't want to provide a function.
   * @memberof ModalProps
   */
  onExit?: () => void
  /**
   * If `true`, the modal will receive a role of `alertdialog`, instead of its default dialog. The alertdialog role should only be used when an alert, error, or warning occurs
   * @type boolean
   * @memberof ModalProps
   */
  alert?: boolean
  /**
   * By default, styles are applied inline to the dialog and underlay portions of the component. However, you can disable all inline styles by setting includeDefaultStyles to false. If set, you must specify all styles externally, including positioning. This is helpful if your project uses external CSS assets.

Note: underlayStyle and dialogStyle can still be set inline, but these will be the only styles applied.
   * @type boolean
   * @memberof ModalProps
   */
  includeDefaultStyles?: boolean

  /**
   * Apply a class to the dialog in order to custom-style it.

Be aware that, by default, this module does apply various inline styles to the dialog element in order position it. To disable all inline styles, see includeDefaultStyles.
   * @type string
   * @memberof ModalProps
   */
  dialogClass?: string
  /**
   * Customize properties of the style prop that is passed to the dialog.
   * @type *
   * @memberof ModalProps
   */
  dialogStyle?: any
  /**
   * By default, when the modal activates its first focusable child will receive focus. However, if focusDialog is true, the dialog itself will receive initial focus — and that focus will be hidden. (This is essentially what Bootstrap does with their modal.)
   * @type boolean
   * @memberof ModalProps
   */
  focusDialog?: boolean
  /**
   * By default, when the modal activates its first focusable child will receive focus. If, instead, you want to identify a specific element that should receive initial focus, pass a selector string to this prop. (That selector is passed to document.querySelector() to find the DOM node.)
   * @type string
   * @memberof ModalProps
   */
  initialFocus?: string
  /**
   * By default, the modal is active when mounted, deactivated when unmounted. However, you can also control its active/inactive state by changing its mounted property instead.
   * @type boolean
   * @memberof ModalProps
   */
  mounted?: boolean
  /**
   * Customize properties of the style prop that is passed to the underlay.

The best way to add some vertical displacement to the dialog is to add top & bottom padding to the underlay. This is illustrated in the demo examples.
   * @type *
   * @memberof ModalProps
   */
  underlayStyle?: any
  /**
   * Apply a class to the underlay in order to custom-style it.

This module does apply various inline styles, though, so be aware that overriding some styles might be difficult. If, for example, you want to change the underlay's color, you should probably use the underlayColor prop instead of a class. If you would rather control all CSS, see includeDefaultStyles.
   * @type *
   * @memberof ModalProps
   */
  underlayClass?: any
  /**
   * By default, a click on the underlay will exit the modal. Pass false, and clicking on the underlay will do nothing.
   * @type boolean
   * @memberof ModalProps
   */
  underlayClickExits?: boolean
  /**
   * If you want to change the underlay's color, you can do that with this prop.

If false, no background color will be applied with inline styles. Presumably you will apply then yourself via an underlayClass.
   * @type (string|false)
   * @memberof ModalProps
   */
  underlayColor?: string | false
  /**
   * If true, the modal's contents will be vertically (as well as horizontally) centered.
   * @type boolean
   * @memberof ModalProps
   */
  verticallyCenter?: boolean
  /**
   * If true, the modal dialog's focus trap will be paused. You'll want to use this prop if you have another nested focus trap inside the modal.
   * @type boolean
   * @memberof ModalProps
   */
  focusTrapPaused?: boolean
  /**
   * Customize properties of the focusTrapOptions prop that is passed to the modal dialog's focus trap. For example, you can use this prop if you need better control of where focus is returned.
   * @type *
   * @memberof ModalProps
   */
  focusTrapOptions?: any
  /**
   * If true, the modal dialog will prevent any scrolling behind the modal window. Default is true
   * @type boolean
   * @memberof ModalProps
   */
  scrollDisabled?: boolean
}

class Modal extends Component<ModalProps, {}>{ }

export = Modal