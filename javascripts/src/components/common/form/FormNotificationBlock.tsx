// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';

export interface FormNotificationBlockProps
{
 message:string
}

class FormNotificationBlock extends React.Component<FormNotificationBlockProps, {}> {
  render() {
     return <div className="help-block" role="alert">{this.props.message}</div>;
  }
}

export default observer(FormNotificationBlock)



