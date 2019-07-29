// License: LGPL-3.0-or-later
import * as React from 'react';

import {InjectedIntlProps, injectIntl} from 'react-intl';
import moneyToString from '../../lib/format/money_to_string';
import { Money } from '../../lib/money';

export interface MoneyToStringProps
{
  value:Money|undefined
}

class MoneyToString extends React.Component<MoneyToStringProps & InjectedIntlProps, {}> {
  render() {
     return moneyToString(this.props.intl.locale, this.props.value)
  }
}

export default injectIntl(MoneyToString)



