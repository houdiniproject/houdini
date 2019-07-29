// License: LGPL-3.0-or-later
import * as React from 'react';

class FormNotificationBlock extends React.Component<{}, {}> {
  render() {
     return <div className="help-block" role="alert">{this.props.children}</div>;
  }
}

export default FormNotificationBlock



