// License: LGPL-3.0-or-later
import React = require("react");
import { HoudiniFormikField, HoudiniFieldProps, HoudiniFieldAttributes } from "./HoudiniFormikField";
import { ObjectDiff } from "../../../lib/types";

type FieldCreatorProps<V, TComponentProps> = ObjectDiff<TComponentProps, HoudiniFieldProps<V>> & {component: React.ComponentType<TComponentProps>, name:string}

export class FieldCreator<V,TComponentProps> extends React.Component<FieldCreatorProps<V,TComponentProps>, {}>
{
  render() {
      return <HoudiniFormikField {...this.props}/>
  }
}