// License: LGPL-3.0-or-later
// from: https://github.com/jsillitoe/react-currency-input/blob/master/src/index.js

import * as React from 'react'
import * as ReactDOM from 'react-dom'
import { boundMethod } from 'autobind-decorator';
import { NumberFormatHelper } from './number_format_helper';

interface CurrencyInputProps {
  value:string|number
  locale?: string
  currency?: string,
  currencyDisplay?: 'symbol' | 'code' | 'name',
  useGrouping?: boolean,
  selectAllOnFocus?:boolean
  allowEmpty?: boolean
}

interface CurrencyInputState {
  maskedValue:string,
  value:number,
  customProps:any
}

function firstNonnumericAfterNumberValue(value:string) {
  
  value.split('').forEach((char) => {
    if (char.match(/\d/)) {

    }
  })
}

class CurrencyInput extends React.Component<CurrencyInputProps, CurrencyInputState> {
  inputSelectionStart: number;
  inputSelectionEnd: number;
  
  constructor(props: CurrencyInputProps) {
    super(props);
    this.state = this.prepareProps(this.props);

    this.inputSelectionStart = 1;
    this.inputSelectionEnd = 1;
  }

  public static defaultProps: CurrencyInputProps = {
    value: '',
    locale: 'en-us',
    currency: 'USD',
    currencyDisplay: 'symbol',
    useGrouping: true
  }

  /**
   * Exposes the current masked value.
   *
   * @returns {String}
   */
  getMaskedValue(): string {
    return this.state.maskedValue;
  }

  theInput: HTMLInputElement


  createNumberFormatHelper(props:CurrencyInputProps): NumberFormatHelper {
    return NumberFormatHelper.initializeFromProps(props.locale, {
      style:"currency", 
      currency: props.currency,
      currencyDisplay: props.currencyDisplay,
      useGrouping: props.useGrouping
    })
  }

  /**
   * General function used to cleanup and define the final props used for rendering
   * @returns {{ maskedValue: {String}, value: {Number}, customProps: {Object} }}
   */
  @boundMethod
  prepareProps(props: CurrencyInputProps) : CurrencyInputState {
    let customProps = { ...props }; 

    console.error("REmove our props")

    let initialValue = props.value;
    if (initialValue === null) {
      initialValue = props.allowEmpty ? null : '';
    } else {

      // if (typeof initialValue == 'string') {
      //   // Some people, when confronted with a problem, think "I know, I'll use regular expressions."
      //   // Now they have two problems.

      //   // Strip out thousand separators, prefix, and suffix, etc.
      //   if (props.thousandSeparator === ".") {
      //     // special handle the . thousand separator
      //     initialValue = initialValue.replace(/\./g, '');
      //   }

      //   if (props.decimalSeparator != ".") {
      //     // fix the decimal separator
      //     initialValue = initialValue.replace(new RegExp(props.decimalSeparator, 'g'), '.');
      //   }

      //   //Strip out anything that is not a digit, -, or decimal separator
      //   initialValue = initialValue.replace(/[^0-9-.]/g, '');

      //   // now we can parse.
      //   initialValue = Number.parseFloat(initialValue);
      // }
      // initialValue = Number(initialValue).toLocaleString(undefined, {
      //   style: 'decimal',
      //   minimumFractionDigits: props.precision,
      //   maximumFractionDigits: props.precision
      // })

    }

    const { maskedValue, value } = this.createNumberFormatHelper(props).mask(initialValue);

    return { maskedValue, value, customProps };
  }


  /**
   * Component lifecycle function.
   * Invoked when a component is receiving new props. This method is not called for the initial render.
   *
   * @param nextProps
   * @see https://facebook.github.io/react/docs/component-specs.html#updating-componentwillreceiveprops
   */
  componentWillReceiveProps(nextProps: CurrencyInputProps) {
    this.setState(this.prepareProps(nextProps));
  }


  /**
   * Component lifecycle function.
   * @returns {XML}
   * @see https://facebook.github.io/react/docs/react-component.html#componentdidmount
   */
  componentDidMount() {
    let node = ReactDOM.findDOMNode(this.theInput) as HTMLInputElement;
    let selectionStart, selectionEnd;
    const suffix = this.createNumberFormatHelper(this.props).getSuffix()
    // if (this.props.autoFocus) {
    //   this.theInput.focus();
    //   selectionEnd = this.state.maskedValue.length - this.props.suffix.length;
    //   selectionStart = selectionEnd;
    // } else {
      selectionEnd = Math.min(node.selectionEnd, this.theInput.value.length - suffix.length);
      selectionStart = Math.min(node.selectionStart, selectionEnd);
    // }

    this.setSelectionRange(node, selectionStart, selectionEnd);
  }

  


  /**
   * Component lifecycle function
   * @returns {XML}
   * @see https://facebook.github.io/react/docs/react-component.html#componentwillupdate
   */
  componentWillUpdate() {
    let node = ReactDOM.findDOMNode(this.theInput) as HTMLInputElement;
    this.inputSelectionStart = node.selectionStart;
    this.inputSelectionEnd = node.selectionEnd;
  }


  /**
   * Component lifecycle function.
   * @returns {XML}
   * @see https://facebook.github.io/react/docs/react-component.html#componentdidupdate
   */
  componentDidUpdate(prevProps: CurrencyInputProps, prevState: CurrencyInputState) {
    const formatHelper = this.createNumberFormatHelper(this.props)
    const groupSeparator = formatHelper.getGroupSeparator();
    const decimalSeparator = formatHelper.getDecimalSeparator();
    const prefix = formatHelper.getPrefix()
    const suffix = formatHelper.getSuffix()

    let node = ReactDOM.findDOMNode(this.theInput) as HTMLInputElement;
    let isNegative = (this.theInput.value.match(/-/g) || []).length % 2 === 1;
    let minPos = prefix.length + (isNegative ? 1 : 0);
    let selectionEnd = Math.max(minPos, Math.min(this.inputSelectionEnd, this.theInput.value.length - suffix.length));
    let selectionStart = Math.max(minPos, Math.min(this.inputSelectionEnd, selectionEnd));

    let regexEscapeRegex = /[-[\]{}()*+?.,\\^$|#\s]/g;
    let separatorsRegex = new RegExp(decimalSeparator.replace(regexEscapeRegex, '\\$&') + '|' + groupSeparator.replace(regexEscapeRegex, '\\$&'), 'g');
    let currSeparatorCount = (this.state.maskedValue.match(separatorsRegex) || []).length;
    let prevSeparatorCount = (prevState.maskedValue.match(separatorsRegex) || []).length;
    let adjustment = Math.max(currSeparatorCount - prevSeparatorCount, 0);

    selectionEnd = selectionEnd + adjustment;
    selectionStart = selectionStart + adjustment;

    const precision = formatHelper.numberFormat.resolvedOptions().minimumFractionDigits

    let baselength = suffix.length
      + prefix.length
      + (precision > 0 ? decimalSeparator.length : 0) // if precision is 0 there will be no decimal part
      + precision
      + 1; // This is to account for the default '0' value that comes before the decimal separator

    if (this.state.maskedValue.length == baselength) {
      // if we are already at base length, position the cursor at the end.
      selectionEnd = this.theInput.value.length - suffix.length;
      selectionStart = selectionEnd;
    }

    this.setSelectionRange(node, selectionStart, selectionEnd);
    this.inputSelectionStart = selectionStart;
    this.inputSelectionEnd = selectionEnd;
  }

  /**
   * Set selection range only if input is in focused state
   * @param node DOMElement
   * @param start number
   * @param end number
   */
  @boundMethod
  setSelectionRange(node: HTMLInputElement, start: number, end: number) {
    if (document.activeElement === node) {
      node.setSelectionRange(start, end);
    }
  }


  /**
   * onChange Event Handler
   * @param event
   */
  @boundMethod
  handleChange(event: React.ChangeEvent<any>) {
    event.preventDefault();
    let { maskedValue, value } = this.createNumberFormatHelper(this.props).mask(event.target.value)

    event.persist();  // fixes issue #23

    this.setState({ maskedValue, value }, () => {
      this.props.onChange(maskedValue, value, event);
      this.props.onChangeEvent(event, maskedValue, value);
    });
  }


  /**
   * onFocus Event Handler
   * @param event
   */
  @boundMethod
  handleFocus(event: FocusEvent) {
    if (!this.theInput) return;
    const formatHelper = this.createNumberFormatHelper(this.props)
    const prefix = formatHelper.getPrefix()
    const suffix = formatHelper.getSuffix()
    //Whenever we receive focus check to see if the position is before the suffix, if not, move it.
    let selectionEnd = this.theInput.value.length - suffix.length;
    let isNegative = (this.theInput.value.match(/-/g) || []).length % 2 === 1;
    let selectionStart = prefix.length + (isNegative ? 1 : 0);
    this.props.selectAllOnFocus && (event.target as any).setSelectionRange(selectionStart, selectionEnd);
    this.inputSelectionStart = selectionStart;
    this.inputSelectionEnd = selectionEnd;
  }


  handleBlur(event: FocusEvent) {
    this.inputSelectionStart = 0;
    this.inputSelectionEnd = 0;
  }


  /**
   * Component lifecycle function.
   * @returns {XML}
   * @see https://facebook.github.io/react/docs/component-specs.html#render
   */
  render() {
    return (
      <input
        ref={(input) => { this.theInput = input; }}
        type={this.props.inputType}
        value={this.state.maskedValue}
        onChange={this.handleChange}
        onFocus={this.handleFocus}
        onMouseUp={this.handleFocus}
        {...this.state.customProps}
      />
    )
  }
}

export default CurrencyInput
