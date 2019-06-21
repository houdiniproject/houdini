// License: LGPL-3.0-or-later
import * as React from 'react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import { PaymentDataWithMoney } from './types';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { TwoColumnFields } from '../common/layout';
import { FieldCreator } from '../common/form/FieldCreator';
import FormikCurrencyField from '../common/FormikCurrencyField';
import FormikBasicField from '../common/FormikBasicField';

export interface ConditionalOffsitePaymentProps extends FormikProps
{
  initialPaymentData:PaymentDataWithMoney
}

interface FormikProps {
  formik:HoudiniFormikProps<any>
}

class ConditionalOffsitePayment extends React.Component<ConditionalOffsitePaymentProps & InjectedIntlProps, {}> {
  render() {
     return this.props.initialPaymentData.kind === 'OffsitePayment' ? <OffsitePayment formik={this.props.formik} intl={this.props.intl}/> : null
  }
}

class OffsitePayment extends React.Component<FormikProps & InjectedIntlProps> {
  render() {
   return <div>
    <TwoColumnFields>
        <FieldCreator component={FormikCurrencyField} name={'gross_amount'} label={"Gross Amount"} prefix={"%"} inputId={FormikHelpers.createId(this.props.formik, 'gross_amount')}/>
    </TwoColumnFields>
    <FieldCreator component={FormikBasicField} name={'date'} label={'Date'} inputId={FormikHelpers.createId(this.props.formik, 'date')} />
    </div>
  }
}

export default injectIntl(ConditionalOffsitePayment)



