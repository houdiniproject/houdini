import { FormikHandlers } from "formik";
import React = require("react");
import _ = require("lodash");
import CurrencyInput, { CurrencyInputProps } from "react-currency-input";

export class FormikCurrencyInput<T> extends React.Component<{field: {
    onChange: FormikHandlers['handleChange'],
    onBlur: FormikHandlers['handleBlur'],
    value: any,
    name: string;
}} & React.InputHTMLAttributes<HTMLInputElement> & CurrencyInputProps, {}>{
    render() {
        const onChangeEvent = (event: React.ChangeEvent<any>, maskedInput:string, floatInput:number) => {
          event.target.value = maskedInput
          this.props.field.onChange(event)
        }
        let props = _.omit(this.props, ['field','form', 'onChange'])
        return <CurrencyInput {...props} {...this.props.field} onChangeEvent={onChangeEvent}/>
    }
}

