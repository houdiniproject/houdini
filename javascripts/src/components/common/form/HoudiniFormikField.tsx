import { FieldProps, FormikHandlers, Field, GenericFieldHTMLAttributes } from "formik";
import React = require("react");
import _ = require("lodash");
import { HoudiniFormikProps } from "../HoudiniFormik";

export interface HoudiniFieldProps<V = any> {
    field: {
        onChange: FormikHandlers['handleChange'];
        onBlur: FormikHandlers['handleBlur'];
        value: any;
        name: string;
    };
    form: HoudiniFormikProps<V>;
}
export interface HoudiniFieldConfig {
    component?: string | React.ComponentType<HoudiniFieldProps<any>> | React.ComponentType<void>;
    render?: ((props: HoudiniFieldProps<any>) => React.ReactNode);
    children?: ((props: HoudiniFieldProps<any>) => React.ReactNode) | React.ReactNode;
    validate?: ((value: any) => string | Promise<void> | undefined);
    name: string;
    type?: string;
    value?: any;
    innerRef?: (instance: any) => void;
}

export declare type HoudiniFieldAttributes<T> = GenericFieldHTMLAttributes & HoudiniFieldConfig & T;

/**
 * This should be more specific but I can't figure out how to make it more specific
 * @export
 * @class HoudiniFormikField
 * @extends React.Component<any, {}>
 */
export class HoudiniFormikField extends React.Component<any, {}>{
    render() {
        return <Field {...this.props}/>
    }
}

