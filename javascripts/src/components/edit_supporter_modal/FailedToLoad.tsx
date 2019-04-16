// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
class FailedToLoad extends React.Component<{}, {}> {
  render() {
     return <div> Failure </div>;
  }
}

export default observer(FailedToLoad)