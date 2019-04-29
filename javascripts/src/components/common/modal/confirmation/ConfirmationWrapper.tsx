// License: LGPL-3.0-or-later
import React = require("react");
import { observer } from "mobx-react";
import { ConfirmationWrapperProps } from "./types";
import { ConfirmationModal } from "./ConfirmationModal";

@observer
export class ConfirmationWrapper extends React.Component<ConfirmationWrapperProps, {}> {
  render() {
    return this.props.confirmationAccessor.confirmations.map((i) => {
      return <ConfirmationModal confirmation={i} key={i.key} />;
    });
  }
}
