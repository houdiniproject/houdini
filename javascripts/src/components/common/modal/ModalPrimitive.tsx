// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import AriaModal = require('react-aria-modal');
import _ = require('lodash');

export interface ModalPrimitiveProps extends AriaModal.ModalProps
{
}

@observer
class ModalPrimitive extends React.Component<ModalPrimitiveProps, {}> {


  render() {

    return <AriaModal {...this.props} />;
  }
}

export default ModalPrimitive



