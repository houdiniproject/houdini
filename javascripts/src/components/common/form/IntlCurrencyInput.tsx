// License: LGPL-3.0-or-later
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import I18nCurrencyInput from '@houdiniproject/react-i18n-currency-input'
import _ = require('lodash');
import { boundMethod } from 'autobind-decorator';
import { Money } from '../../../lib/money';

export interface IntlCurrencyInputProps {
  /**
     * The value you want to be formatted. If you want this to be a
     * controlled component, you'll need to use onChange to get the value on each
     * change and then pass in the value. If you want to an uncontrolled
     * component, this should just be the initial value
     * @type (string|number|null)
     * @memberof CurrencyInputProps
     */
  value: Money;

  /**
   * How you want your currency to be displayed. Options are:
   *  - symbol: the currency symbol, like $ or €
   *  - code: the currency code, like USD or EUR
   *  - name: the localized name of the currency, like dollar in the locale en-us or dólares estadounidenses in es-mx locale
   * @default 'symbol'
   * @type ('symbol' | 'code' | 'name')
   * @memberof CurrencyInputProps
   */
  currencyDisplay?: 'symbol' | 'code' | 'name';

  /**
   * whether you want grouping in the integer portion. As an example, in the US, grouping is done by every three digits, i.e. $1,000 and $1,000,000.
   * if you don't want grouping, set this to false.
   * @default true
   * @type boolean
   * @memberof CurrencyInputProps
   */
  useGrouping?: boolean;
  /**
   * Do you want to have null or 0 as the empty value? True for null, false for 0
   * @default false
   * @type boolean
   * @memberof CurrencyInputProps
   */
  allowEmpty?: boolean;
  /**
   * the type of field. In some rare occurs, you may want to set this to something other than 'text'
   * @default 'text
   * @type string
   * @memberof CurrencyInputProps
   */
  inputType?: string;
  /**
   * A callback after the input has changed and has been processed. The arguments for the onChange are as follows:
   * - event: the React.ChangeEvent representing the value change
   * - maskedValue: the value after going through the masking process. In the case of "1" (a string) and default properties, you'll end up with "$0.01"
   * - value: the numerical value of the input value after the masking process. Use this when you need to do math using the input value. In the case of In the case of "1" (a string) and default properties, you'll end up with 0.01.
   * @default (no-op function)
   * @memberof CurrencyInputProps
   */
  onChange?: (instance: I18nCurrencyInput, value: Money) => void;
  /**
   * A callback on the blur event
   * @default (no-op function)
   * @memberof CurrencyInputProps
   */
  onBlur?: (instance: I18nCurrencyInput, value: Money) => void;
  [customProps: string]: any;
}

declare type NumberFormatHelperOptions = {
  /**
   * Do we want to allow negative numbers? If false, we strip negative signs.
   * @default true
   * @type boolean
   */
  allowNegative: boolean;
} | {
  /**
   * Should numbers always be negative (other than 0)? If so, we make all non-zero numbers negative.
   * @type boolean
   */
  requireNegative: boolean;
};

class IntlCurrencyInput extends React.Component<IntlCurrencyInputProps & Partial<NumberFormatHelperOptions> & InjectedIntlProps, {}> {

  constructor(props: IntlCurrencyInputProps & InjectedIntlProps) {
    super(props)
    this.i18nRef = React.createRef();
  }

  static defaultProps = {
    value: Money.fromDecimal(0, 'USD')
  }

  i18nRef: React.RefObject<I18nCurrencyInput>

  @boundMethod
  onBlur(instance: I18nCurrencyInput) {
    this.props.onBlur && this.props.onBlur(instance, Money.fromCents(this.i18nRef.current.state.valueInCents, this.props.value.currency))
  }

  @boundMethod
  onChange(instance: I18nCurrencyInput, _maskedValue: string, _value: number, valueInCents:number) {
    this.props.onChange && this.props.onChange(instance, Money.fromCents(valueInCents, this.props.value.currency))
  }

  render() {
    const props = _.omit(this.props, 'intl')
    return <I18nCurrencyInput ref={this.i18nRef} {...props} value={this.props.value.amountInCents.toString()} currency={this.props.value.currency} onBlur={this.onBlur} onChange={this.onChange} locale={this.props.intl.locale} />
  }
}

export default injectIntl(IntlCurrencyInput)



