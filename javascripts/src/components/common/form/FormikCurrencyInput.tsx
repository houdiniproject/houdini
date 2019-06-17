import { FormikHandlers } from "formik";
import React = require("react");
import _ = require("lodash");
import IntlCurrencyInput, { IntlCurrencyInputProps } from "./IntlCurrencyInput";
import { HoudiniFormikProps } from "../HoudiniFormik";
import { HoudiniFormikField } from "./HoudiniFormikField";
import { boundMethod } from "autobind-decorator";
import I18nCurrencyInput from "@houdiniproject/react-i18n-currency-input";
import { Money } from "../../../lib/money";


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


export class FormikCurrencyInput<T> extends React.Component<React.InputHTMLAttributes<HTMLInputElement> & Partial<IntlCurrencyInputProps> & Partial<NumberFormatHelperOptions> & { name: string }>{
  render() {

    const maskedValueField = `${this.props.name}`

    return <HoudiniFormikField {...this.props} name={maskedValueField} component={InnerMaskedValueFormikCurrencyInput} />
  }
}

class InnerMaskedValueFormikCurrencyInput extends React.Component<React.InputHTMLAttributes<HTMLInputElement> & IntlCurrencyInputProps & Partial<NumberFormatHelperOptions> & {
  field: {
    onChange: FormikHandlers['handleChange'],
    onBlur: FormikHandlers['handleBlur'],
    value: any,
    name: string
  }
} & { form: HoudiniFormikProps<any> }> {


  @boundMethod
  onChangeEvent(instance: I18nCurrencyInput, value:Money){
    //if we're in an initial mount and there was a change, this change wouldn't be recognized
    // from: https://github.com/jaredpalmer/formik/issues/930#issuecomment-479461676
    setTimeout(() => {
      this.props.form.setFieldValue(this.props.field.name, value)
    },0)
  }

  @boundMethod
  onBlurEvent(instance: I18nCurrencyInput, value:Money){
    this.props.form.handleBlur(this.props.field.name)
    
  }

  render() {
    let props = _.omit(this.props, ['field', 'form'])

    return <IntlCurrencyInput {...props} {...this.props.field} onChange={this.onChangeEvent} onBlur={this.onBlurEvent}/>
  }
}

