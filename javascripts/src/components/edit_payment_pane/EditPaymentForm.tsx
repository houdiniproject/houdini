import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { FieldCreator } from '../common/form/FieldCreator';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { NonprofitTimezonedDates } from '../../lib/date';
import { PaymentDataWithMoney, FundraiserInfo } from './types';
import DedicationPanel from './DedicationPanel';
import FormikSelectField from '../common/FormikSelectField';
import FormikTextareaField from '../common/FormikTextareaField';
import ConditionalOffsitePayment from './ConditionalOffsitePayment';
import InitialTable from './InitialTable';
import { boundMethod } from 'autobind-decorator';
import { EditPaymentModalController } from './EditPaymentModalChildren';
import { connectConfirmationManager, ConfirmationManagerContextProps } from '../common/modal/confirmation/connect';
import { TwoColumnFields } from '../common/layout';
import AddressSection from './AddressSection';

export interface EditPaymentFormProps {
  formik: HoudiniFormikProps<any>
  initialPaymentData: PaymentDataWithMoney
  dateFormatter: NonprofitTimezonedDates
  campaigns: FundraiserInfo[]
  events: FundraiserInfo[]
  editPaymentModalController: EditPaymentModalController
}

class EditPaymentForm extends React.Component<EditPaymentFormProps & InjectedIntlProps & ConfirmationManagerContextProps, {}> {

  componentDidMount(){
    this.updateModalStateValues()
  }

  componentDidUpdate() {
    this.updateModalStateValues()
  }

  updateModalStateValues(){
    const disableSave = this.props.formik.isSubmitting || !this.props.formik.dirty
    if (this.props.editPaymentModalController.disableSave != disableSave){
      this.props.editPaymentModalController.setDisableSave(disableSave)
    }
    const disableClose = this.props.formik.isSubmitting

    if (this.props.editPaymentModalController.disableClose != disableClose)
    {
      this.props.editPaymentModalController.setDisableClose(disableClose)
    }

    const formId = FormikHelpers.createFormId(this.props.formik)
    if (this.props.editPaymentModalController.formId !== formId)
    {
      this.props.editPaymentModalController.setFormId(formId)
    }
   
    if (this.props.editPaymentModalController.closeAction != this.canClose){
      this.props.editPaymentModalController.setCanClose(this.canClose)
    }
  }
  
  @boundMethod
  async canClose(){
    const confirmButtonText:string = this.props.intl.formatMessage({id: "edit_payment_modal.confirmation.yes_discard_changes"})
    const abortButtonText:string = this.props.intl.formatMessage({id: "edit_payment_modal.confirmation.no_keep_editing"})
    const titleText = this.props.intl.formatMessage({id: "edit_payment_modal.confirmation.discard_changes"})

    var confirmationText:string = this.props.intl.formatMessage({id:"edit_payment_modal.confirmation.confirmation_text"})

    return !this.props.formik.dirty || await this.props.confirmation.confirm({titleText:titleText, confirmationText: confirmationText, confirmButtonText:confirmButtonText, abortButtonText: abortButtonText})
  }


  render() {
    const formik = this.props.formik
    const campaigns = this.props.campaigns.map(i => {return { value: i.id, label:i.name}})

    const events = this.props.events.map(i => {return { value: i.id, label:i.name}})
    return <HoudiniFormikForm formik={formik}>
      <InitialTable data={this.props.initialPaymentData}
        dateFormatter={this.props.dateFormatter} />
      <ConditionalOffsitePayment initialPaymentData={this.props.initialPaymentData} formik={formik} />
      <TwoColumnFields>
        <FieldCreator component={FormikSelectField} name={'campaign'} label={"Campaign"} options={campaigns} inputId={FormikHelpers.createId(this.props.formik, 'campaign')}/>

        <FieldCreator component={FormikSelectField} name={'event'} label={"Event"} options={events} inputId={FormikHelpers.createId(this.props.formik, 'event')}/>
      </TwoColumnFields>
      <FieldCreator component={FormikTextareaField} name={'designation'} label={'designation'} rows={3} inputId={FormikHelpers.createId(this.props.formik, 'designation')}/>

      <DedicationPanel formik={formik} />
      <FieldCreator component={FormikTextareaField} name={'comment'} label={'Notes'} rows={3} />

      <AddressSection formik={formik}/>

    </HoudiniFormikForm>
  }
}

export default injectIntl(connectConfirmationManager(EditPaymentForm))