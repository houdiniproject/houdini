// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';

export interface FailedToLoadProps
{

}

class FailedToLoad extends React.Component<FailedToLoadProps, {}> {
  render() {
     return <div> Failure </div>;
  }
}

export default observer(FailedToLoad)



