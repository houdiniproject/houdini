import { FormikHandlers } from "formik";
import React = require("react");
import _ = require("lodash");

export class FormikInput<T> extends React.Component<{field: {
    onChange: FormikHandlers['handleChange'],
    onBlur: FormikHandlers['handleBlur'],
    value: any,
    name: string;
}} & React.InputHTMLAttributes<HTMLInputElement>, {}>{
    render() {
        let props = _.omit(this.props, ['field','form'])
        return <input {...props} {...this.props.field} />
    }
}

