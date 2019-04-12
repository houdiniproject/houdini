import { FormikHandlers } from "formik";
import React = require("react");
import _ = require("lodash");

export class FormikCheckbox extends React.Component<{field: {
    onChange: FormikHandlers['handleChange'],
    onBlur: FormikHandlers['handleBlur'],
    value: any,
    name: string;
}} & React.InputHTMLAttributes<HTMLInputElement> & {label?:string}, {}>{
    render() {
        let props = _.omit(this.props, ['field','form', 'label'])

        return <fieldset className="form-group reactCheckbox">
        <label>
          <input type="checkbox" {...props} {...this.props.field} /><span className='cr'/>{this.props.label}
        </label>
      </fieldset>
    }
}