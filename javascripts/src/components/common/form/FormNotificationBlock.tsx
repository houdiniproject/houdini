// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';

class FormNotificationBlock extends React.Component<{}, {}> {
  render() {
     return <div className="help-block" role="alert">{this.props.children}</div>;
  }
}

export default observer(FormNotificationBlock)



