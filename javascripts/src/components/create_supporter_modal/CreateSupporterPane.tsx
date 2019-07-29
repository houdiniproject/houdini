// License: LGPL-3.0-or-later
import { observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { FieldCreator } from '../common/form/FieldCreator';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import FormikBasicField from '../common/FormikBasicField';
import { FormikHelpers, HoudiniFormikProps } from '../common/HoudiniFormik';
import { TwoColumnFields } from '../common/layout';
import { SubmitPhase } from './CreateSupporterFormik';

export interface CreateSupporterPaneProps {
  formik: HoudiniFormikProps<any>
  // supporterModalState: SupporterModalState
  // modal:ModalContext
  submitPhase: SubmitPhase
  //createSupporterFormikState:CreateSupporterFormikState
  // onClose:OnCloseType
}

class CreateSupporterPane extends React.Component<CreateSupporterPaneProps & InjectedIntlProps, {}> {

  render() {
    const formik = this.props.formik
    const disableSupporterFields = this.props.submitPhase > SubmitPhase.HAVE_NOTHING
    return <HoudiniFormikForm formik={formik}>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'name'} label={'Name'} inputId={FormikHelpers.createId(formik, 'name')} disabled={disableSupporterFields}/>
        <FieldCreator component={FormikBasicField} name={'email'} label={'Email'} inputId={FormikHelpers.createId(formik, 'email')} disabled={disableSupporterFields}/>
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'phone'} label={'Phone'} inputId={FormikHelpers.createId(formik, 'phone')} disabled={disableSupporterFields}/>
        <FieldCreator component={FormikBasicField} name={'organization'} label={'Organization'} inputId={FormikHelpers.createId(formik, 'organization')} disabled={disableSupporterFields}/>
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'address'} label={'Address'} inputId={FormikHelpers.createId(this.props.formik, 'address')} />
        <FieldCreator component={FormikBasicField} name={'city'} label={'City'} inputId={FormikHelpers.createId(this.props.formik, 'city')} />
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'state_code'} label={'State/Region Code'} inputId={FormikHelpers.createId(this.props.formik, 'state_code')} />
        <FieldCreator component={FormikBasicField} name={'zip_code'} label={'Postal/Zip Code'} inputId={FormikHelpers.createId(this.props.formik, 'zip_code')} />
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'country'} label={'Country'} inputId={FormikHelpers.createId(this.props.formik, 'country')} />
      </TwoColumnFields>
    </HoudiniFormikForm>
  }
}

export default injectIntl(observer(CreateSupporterPane))



