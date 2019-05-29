// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import HoudiniFormik, { FormikHelpers } from '../common/HoudiniFormik';
import { ValidationErrorsException, TimeoutError } from '../../../api';
import { boundMethod } from 'autobind-decorator';
import { FormikActions } from 'formik';
import { centsToDollars } from '../../lib/format';
import { NonprofitTimezonedDates } from '../../lib/date';
import { parseDedication } from '../../lib/dedication';
import {UpdateDonationModel, PutDonation} from "../../lib/api/put_donation";

export interface EditPaymentFormikProps {
  data: PaymentData
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]
  nonprofitTimezone?: string
  preupdateDonationAction: () => void
  postUpdateSuccess: () => void
}



export interface FundraiserInfo {
  id: number
  name: string
}


interface Charge {
  status: string
}

interface RecurringDonation {
  interval?: number
  time_unit?: string
  created_at: string
}

interface Donation {
  designation?: string
  comment?: string
  event?: { id: number }
  campaign?: { id: number }
  dedication?: string
  recurring_donation?: RecurringDonation
  id: number
}

interface PaymentData {
  gross_amount: number
  fee_total: number
  date: string
  offsite_payment: OffsitePayment
  donation: Donation
  kind: string
  id: string
  refund_total: number
  net_amount: number
  origin_url?: string
  charge?: Charge,
  nonprofit: { id: number }
}

interface OffsitePayment {
  check_number: string
  kind: string
}


export async function onSubmit(
  values: any,
  action: FormikActions<any>,
  preupdateDonationAction: () => void,
  putDonation: (donation: UpdateDonationModel, nonprofitId:number) => Promise<any>,
  createSupporterFormikState: CreateSupporterFormikState,
  onClose: OnCloseType
) {
  if (preupdateDonationAction) {
    preupdateDonationAction()
  }

  let status: HoudiniFormikServerStatus<Supporter> = {}
  try {
    if (createSupporterFormikState.phase === SubmitPhase.HAVE_NOTHING) {
      //we create our supporter
      const supporter = await createSupporter(filterToSupporterValues(values))
      createSupporterFormikState.setSupporter(supporter)
      createSupporterFormikState.setPhase(SubmitPhase.HAVE_SUPPORTER)
    }
    if (createSupporterFormikState.phase === SubmitPhase.HAVE_SUPPORTER) {
      const supporter = createSupporterFormikState.supporter
      //supporter is set
      const addressValues = filterToAddressValues(values)
      if (areAnyOfAddressFilled(addressValues)) {
        const address = await addAddress(supporter.id, addressValues)
      }
      action.setStatus({})
      createSupporterFormikState.setPhase(SubmitPhase.HAVE_SUPPORTER_AND_ADDRESS)
      //we can close(s.id)
      onClose(supporter.id)
    }
  }
  catch (e) {
    if (createSupporterFormikState.phase == SubmitPhase.HAVE_NOTHING){
      if (e instanceof TimeoutError) {
        status.form = "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds."
      }
      else {
        if (e instanceof ValidationErrorsException) {
          status.fields = FormikHelpers.convertServerValidationToFieldStatus(e)
        }
  
        status.form = e['error']
      }
  
      action.setStatus(status)    
    }
    else if (createSupporterFormikState.phase == SubmitPhase.HAVE_SUPPORTER){
      if (e instanceof TimeoutError) {
        status.form = <>We've already saved your supporter but weren't able to save your address<br/><br/>The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.</>
      }
      else {
        if (e instanceof ValidationErrorsException) {
          status.fields = FormikHelpers.convertServerValidationToFieldStatus(e)
        }
  
        status.form = e['error']
      }
    }
    
    action.setStatus(status) 
  }
}


class EditPaymentFormik extends React.Component<EditPaymentFormikProps & InjectedIntlProps, {}> {



  @boundMethod
  async onSubmit(values: any, action: FormikActions<any>){
    await onSubmit(values, action, this.createSupporter, this.addAddress, this.createSupporterFormikState, this.props.onClose)
  }

  loadFormFromData(props:EditPaymentFormikProps) {
    const eventId = props.data.donation.event && props.data.donation.event.id;
    const campaignId = props.data.donation.campaign && props.data.donation.campaign.id;
    const nonprofitTimezonedDates = new NonprofitTimezonedDates(this.props.nonprofitTimezone)
    const dedication = parseDedication(props.data && props.data.donation && props.data.donation.dedication)
    
    return {
      event: eventId,
      campaign: campaignId,
      gross_amount: centsToDollars(props.data.gross_amount),
      fee_total: centsToDollars(props.data.fee_total),
      date: nonprofitTimezonedDates.readable_date(props.data.date),
      dedication: dedication,
      designation: props.data.donation.designation,
      comment: this.props.data.donation.comment
    }
  
  }

  render() {
    
    const initialValues = this.loadFormFromData(this.props)
    return <HoudiniFormik initialValues={initialValues} onSubmit={this.onSubmit} validationSchema={validationSchema} render={(props) => {
      return <CreateSupporterPaneStateManager formik={props} supporterModalState={this.props.supporterModalState} modal={this.props.modal} createSupporterFormikState={this.createSupporterFormikState} onClose={this.props.onClose} />
    }} />;
  }

}

export default injectIntl(observer(EditPaymentFormik))



