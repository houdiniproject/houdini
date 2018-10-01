// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl, InjectedIntl, FormattedMessage} from 'react-intl';
import SessionLoginForm from "./SessionLoginForm";

export interface SessionLoginPageProps
{

}

class SessionLoginPage extends React.Component<SessionLoginPageProps & InjectedIntlProps, {}> {
  render() {
     return <div className="tw-bs"><div className="container"><div className="row"><div className={'col-sm-6'}>
       <h1><FormattedMessage id="login.header"/></h1>
       <SessionLoginForm buttonText="login.login" buttonTextOnProgress="login.logging_in"/>
     </div></div>
     </div></div>;
  }
}

export default injectIntl(observer(SessionLoginPage))



