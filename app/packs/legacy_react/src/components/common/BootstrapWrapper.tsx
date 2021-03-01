// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';

class BootstrapWrapper extends React.Component<{}, {}> {
  render() {
    return <div className={"tw-bs"}>
      {this.props.children}
    </div>;
  }
}

export default observer(BootstrapWrapper)



