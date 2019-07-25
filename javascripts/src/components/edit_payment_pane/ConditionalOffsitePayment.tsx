// License: LGPL-3.0-or-later
import * as React from 'react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import { PaymentDataWithMoney } from './types';
import OffsitePayment, { FormikProps } from './OffsitePayment';

export interface ConditionalOffsitePaymentProps extends FormikProps
{
  initialPaymentData:PaymentDataWithMoney
}

class ConditionalOffsitePayment extends React.Component<ConditionalOffsitePaymentProps & InjectedIntlProps, {}> {
  render() {
     return this.props.initialPaymentData.kind === 'OffsitePayment' ? <OffsitePayment formik={this.props.formik} /> : null
  }
}

export default injectIntl(ConditionalOffsitePayment)



