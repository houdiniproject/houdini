// License: LGPL-3.0-or-later
import * as React from 'react';
import RegistrationWizard from "./RegistrationWizard";

import {observer} from 'mobx-react';
import {InjectedIntlProps, injectIntl, InjectedIntl, FormattedMessage} from 'react-intl';


export interface RegistrationPageProps
{

}

class RegistrationPage extends React.Component<RegistrationPageProps & InjectedIntlProps, {}> {



  render() {
   return <div className="tw-bs"><div className="container"><h1><FormattedMessage id="registration.get_started.header"/></h1><p><FormattedMessage id="registration.get_started.description"/></p><RegistrationWizard/></div></div>

  }
}

export default injectIntl(observer(RegistrationPage))

