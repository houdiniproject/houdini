import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { FieldCreator } from '../common/form/FieldCreator';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { NonprofitTimezonedDates } from '../../lib/date';
import { FundraiserInfo } from '../edit_payment_pane/types';
import DedicationPanel from '../edit_payment_pane/DedicationPanel';
import FormikSelectField from '../common/FormikSelectField';
import FormikTextareaField from '../common/FormikTextareaField';
import { boundMethod } from 'autobind-decorator';
import { connectConfirmationManager, ConfirmationManagerContextProps } from '../common/modal/confirmation/connect';
import { TwoColumnFields } from '../common/layout';
import AddressSection from '../edit_payment_pane/AddressSection';
import OffsitePayment from '../edit_payment_pane/OffsitePayment';
import { CreateOffsitePaymentModalController } from './CreateOffsitePaymentModalChildren';

export interface CreateOffsitePaymentFormProps {
  formik: HoudiniFormikProps<any>
  dateFormatter: NonprofitTimezonedDates
  campaigns: FundraiserInfo[]
  events: FundraiserInfo[]
  createOffsitePaymentModalController: CreateOffsitePaymentModalController
}

class CreateOffsitePaymentForm extends React.Component<CreateOffsitePaymentFormProps & InjectedIntlProps & ConfirmationManagerContextProps, {}> {

  componentDidMount() {
    this.updateModalStateValues()
  }

  componentDidUpdate() {
    this.updateModalStateValues()
  }

  updateModalStateValues() {
    const disableSave = this.props.formik.isSubmitting || !this.props.formik.dirty
    if (this.props.createOffsitePaymentModalController.disableSave != disableSave) {
      this.props.createOffsitePaymentModalController.setDisableSave(disableSave)
    }
    const disableClose = this.props.formik.isSubmitting

    if (this.props.createOffsitePaymentModalController.disableClose != disableClose) {
      this.props.createOffsitePaymentModalController.setDisableClose(disableClose)
    }

    const formId = FormikHelpers.createFormId(this.props.formik)
    if (this.props.createOffsitePaymentModalController.formId !== formId) {
      this.props.createOffsitePaymentModalController.setFormId(formId)
    }

    if (this.props.createOffsitePaymentModalController.closeAction != this.canClose) {
      this.props.createOffsitePaymentModalController.setCanClose(this.canClose)
    }
  }

  @boundMethod
  async canClose() {
    const confirmButtonText: string = this.props.intl.formatMessage({ id: "edit_payment_modal.confirmation.yes_discard_changes" })
    const abortButtonText: string = this.props.intl.formatMessage({ id: "edit_payment_modal.confirmation.no_keep_editing" })
    const titleText = this.props.intl.formatMessage({ id: "edit_payment_modal.confirmation.discard_changes" })

    var confirmationText: string = this.props.intl.formatMessage({ id: "edit_payment_modal.confirmation.confirmation_text" })

    return !this.props.formik.dirty || await this.props.confirmation.confirm({ titleText: titleText, confirmationText: confirmationText, confirmButtonText: confirmButtonText, abortButtonText: abortButtonText })
  }


  render() {
    const formik = this.props.formik
    const campaigns = this.props.campaigns.map(i => { return { value: i.id, label: i.name } })

    const events = this.props.events.map(i => { return { value: i.id, label: i.name } })
    return <HoudiniFormikForm formik={formik}>
      <OffsitePayment formik={formik} />
      <TwoColumnFields>
        <FieldCreator component={FormikSelectField} name={'campaignId'} label={"Campaign"} options={campaigns} inputId={FormikHelpers.createId(this.props.formik, 'campaign')} />

        <FieldCreator component={FormikSelectField} name={'eventId'} label={"Event"} options={events} inputId={FormikHelpers.createId(this.props.formik, 'event')} />
      </TwoColumnFields>
      <FieldCreator component={FormikTextareaField} name={'designation'} label={'Designation'} rows={3} inputId={FormikHelpers.createId(this.props.formik, 'designation')} />

      <DedicationPanel formik={formik} />
      <FieldCreator component={FormikTextareaField} name={'comment'} label={'Notes'} rows={3} />

      <AddressSection formik={formik} />

    </HoudiniFormikForm>
  }
}

export default injectIntl(connectConfirmationManager(CreateOffsitePaymentForm))