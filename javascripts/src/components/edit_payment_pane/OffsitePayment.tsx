import { InjectedIntlProps, injectIntl } from 'react-intl';
import { FormikHelpers, HoudiniFormikProps } from '../common/HoudiniFormik';
import { TwoColumnFields } from '../common/layout';
import { FieldCreator } from '../common/form/FieldCreator';
import FormikCurrencyField from '../common/FormikCurrencyField';
import FormikBasicField from '../common/FormikBasicField';
import React = require('react');


export interface FormikProps {
  formik:HoudiniFormikProps<any>
}


export class OffsitePayment extends React.Component<FormikProps & InjectedIntlProps> {
  render() {
    return <div>
      <TwoColumnFields>
        <FieldCreator component={FormikCurrencyField} name={'gross_amount'} label={"Gross Amount"} inputId={FormikHelpers.createId(this.props.formik, 'gross_amount')} />
      </TwoColumnFields>
      <FieldCreator component={FormikBasicField} name={'date'} label={'Date'} inputId={FormikHelpers.createId(this.props.formik, 'date')} />
    </div>;
  }
}

export default injectIntl(OffsitePayment)