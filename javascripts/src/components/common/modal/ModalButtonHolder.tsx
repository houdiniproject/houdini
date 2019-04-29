import { ModalContext } from "./Modal";
import React = require("react");
import { observer } from "mobx-react";
import { connect } from "./connect";

//@observer
// class InnerModalButtonHolder extends React.Component<{children:React.ReactElement<any>[]} &  {modal:ModalContext}, {}> {
//     componentDidUpdate(){
//         this.props.modal.setButtons(this.props.children)
//     }
//     render():any {
//         const children = this.props.children
//         const modal = this.props.modal
//         return null;
//     }
// }

// export default connect(InnerModalButtonHolder)