// License: LGPL-3.0-or-later
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { TwoColumnFields } from '../common/layout';
import { FieldCreator } from '../common/form/FieldCreator';
import FormikBasicField from '../common/FormikBasicField';
import { FormikHelpers, HoudiniFormikProps } from '../common/HoudiniFormik';
import Panel from '../common/bootstrap/Panel';

export interface AddressSectionProps {
  formik: HoudiniFormikProps<any>
}

class AddressSection extends React.Component<AddressSectionProps & InjectedIntlProps, {}> {
  render() {
    return <Panel headerRender={() => <label>Payment Address</label>}
      render={() => <>
        <TwoColumnFields>
          <FieldCreator component={FormikBasicField} name={'address.address'} label={'Address'} inputId={FormikHelpers.createId(this.props.formik, 'address.address')} />
          <FieldCreator component={FormikBasicField} name={'address.city'} label={'City'} inputId={FormikHelpers.createId(this.props.formik, 'address.city')} />
        </TwoColumnFields>
        <TwoColumnFields>
          <FieldCreator component={FormikBasicField} name={'address.state_code'} label={'State/Region Code'} inputId={FormikHelpers.createId(this.props.formik, 'address.state_code')} />
          <FieldCreator component={FormikBasicField} name={'address.zip_code'} label={'Postal/Zip Code'} inputId={FormikHelpers.createId(this.props.formik, 'address.zip_code')} />

        </TwoColumnFields>
        <TwoColumnFields>
          <FieldCreator component={FormikBasicField} name={'address.country'} label={'Country'} inputId={FormikHelpers.createId(this.props.formik, 'address.country')} />
        </TwoColumnFields>
      </>
      }/>
  }
}

export default injectIntl(AddressSection)



