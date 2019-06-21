import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { FieldCreator } from '../common/form/FieldCreator';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { NonprofitTimezonedDates } from '../../lib/date';
import { PaymentDataWithMoney } from './types';
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

interface FundraisingInfoStringed {
  id: string,
  name: string
}

export interface EditPaymentFormProps {
  formik: HoudiniFormikProps<any>
  initialPaymentData: PaymentDataWithMoney
  dateFormatter: NonprofitTimezonedDates
  campaigns: FundraisingInfoStringed[]
  events: FundraisingInfoStringed[]
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
    this.props.editPaymentModalController.setDisableSave(this.props.formik.isSubmitting || !this.props.formik.dirty)
    this.props.editPaymentModalController.setDisableClose(this.props.formik.isSubmitting)
    this.props.editPaymentModalController.setFormId(FormikHelpers.createFormId(this.props.formik))

    this.props.editPaymentModalController.setCanClose(this.canClose)
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

    return <HoudiniFormikForm formik={formik}>
      <InitialTable data={this.props.initialPaymentData}
        dateFormatter={this.props.dateFormatter} />
      <ConditionalOffsitePayment initialPaymentData={this.props.initialPaymentData} formik={formik} />
      <TwoColumnFields>
        <FieldCreator component={FormikSelectField} name={'campaign'} label={"Campaign"} options={this.props.campaigns} inputId={FormikHelpers.createId(this.props.formik, 'campaign')}/>

        <FieldCreator component={FormikSelectField} name={'event'} label={"Event"} options={this.props.events} inputId={FormikHelpers.createId(this.props.formik, 'event')}/>
      </TwoColumnFields>
      <FieldCreator component={FormikTextareaField} name={'designation'} label={'designation'} rows={3} inputId={FormikHelpers.createId(this.props.formik, 'designation')}/>

      <DedicationPanel formik={formik} />
      <FieldCreator component={FormikTextareaField} name={'comment'} label={'Notes'} rows={3} />

      <AddressSection formik={formik}/>

    </HoudiniFormikForm>
  }
}

export default injectIntl(connectConfirmationManager(EditPaymentForm))