// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';

export interface PaneProps
{

}

class Pane extends React.Component<PaneProps & InjectedIntlProps, {}> {
  render() {
     return <div></div>;
  }
}

export default injectIntl(observer(Pane))



