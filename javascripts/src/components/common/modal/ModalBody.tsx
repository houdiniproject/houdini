// License: LGPL-3.0-or-later
import { observer } from 'mobx-react';
import * as React from 'react';
import { ModalContext } from './Modal';
import _ = require('lodash');

class ModalBody extends React.Component<{}> {

  render() {
    return <div className="modal-body">
      <div style={{ position: 'relative' }}>
        {this.props.children}
      </div>
    </div>
  }
}




export default observer(ModalBody)



