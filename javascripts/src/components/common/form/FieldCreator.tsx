import { Field, FieldProps } from "formik";
import React = require("react");

type Diff<T, U> = T extends U ? never : T;

/* 
Given a type T, create a new type which is T with all the properties of type U removed

For example. If type T is {name:string, value:number} and U is {name:string},
then ObjectDiff<T,U> would be {value:number}
*/
type ObjectDiff<T, U> = Pick<T, Diff<keyof T, keyof U>>;

type FieldCreatorProps<V, TComponentProps> = ObjectDiff<TComponentProps, FieldProps<V>> & {component: React.ComponentType<TComponentProps>, name:string}


export class FieldCreator<V,TComponentProps> extends React.Component<FieldCreatorProps<V,TComponentProps>, {}>
{
  render() {
      return <Field {...this.props}/>
  }
}