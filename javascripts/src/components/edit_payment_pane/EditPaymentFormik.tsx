// License: LGPL-3.0-or-later
import * as React from 'react';
import * as yup from 'yup'
import * as _ from 'lodash'

import { InjectedIntlProps, injectIntl } from 'react-intl';
import HoudiniFormik, { FormikHelpers, HoudiniFormikServerStatus } from '../common/HoudiniFormik';
import { ValidationErrorsException, TimeoutError } from '../../../api';
import { boundMethod } from 'autobind-decorator';
import { FormikActions, FormikErrors } from 'formik';
import { NonprofitTimezonedDates } from '../../lib/date';
import { parseDedication, Dedication, serializeDedication } from '../../lib/dedication';
import { UpdateDonationModel, PutDonation } from "../../lib/api/put_donation";
import { PaymentDataWithMoney, PaymentData, FundraiserInfo, Address } from './types';
import { Money } from '../../lib/money';

import EditPaymentForm from './EditPaymentForm';
import { MoneySchema } from '../../lib/yup/money_schema';
import { EditPaymentModalController } from './EditPaymentModalChildren';
import { convertObject } from '../../lib/utils';
import { ApiManager } from '../../lib/api_manager';
import { inject } from 'mobx-react';
import ControlledPropUpdates from '../common/ControlledPropUpdates';

function convertToPaymentDataWithMoney(data: PaymentData): PaymentDataWithMoney {
  return {
    ...data,
    net_amount: amountToMoney(data.net_amount),
    refund_total: amountToMoney(data.refund_total),
    gross_amount: amountToMoney(data.gross_amount),
    fee_total: amountToMoney(data.fee_total)
  }
}

interface AdditionalSubmitInfo {
  putDonation: (donation: UpdateDonationModel, nonprofitId: number) => Promise<any>,
  nonprofitTimezonedDates: NonprofitTimezonedDates
  nonprofitId: number,
  paymentId: number,
  onClose: () => void
  preupdateDonationAction?: () => void,
  postUpdateSuccess?: () => void,


}


export async function onSubmit(
  values: FormData,
  action: FormikActions<FormData>,
  { putDonation, nonprofitTimezonedDates, nonprofitId, paymentId, onClose, preupdateDonationAction, postUpdateSuccess }: AdditionalSubmitInfo
) {

  let status: HoudiniFormikServerStatus<FormData> = {}
  if (preupdateDonationAction) {
    preupdateDonationAction();
  }

  let updateData: UpdateDonationModel = {
    id: paymentId,
    donation: {
      designation: values.designation,
      comment: values.comment,
      gross_amount: values.gross_amount.amountInCents,
      fee_total: values.fee_total.amountInCents,
      date: nonprofitTimezonedDates.readable_date_time_to_iso(values.date),
      address: values.address
    }
  };

  if (values.campaign) {
    updateData.donation.campaign_id = values.campaign.toString()
  }
  if (values.event) {
    updateData.donation.event_id = values.event.toString()
  }

  if (values.dedication && values.dedication.type) {
    const nameToValueForContact = ['full_address', 'phone', 'email'].map((i) => {
      return {
        name: i, value: _.get(values.dedication, i)
      }
    });
    const contact = _.some(nameToValueForContact, (i) => i.value && i.value != "") ?
      _.reduce(nameToValueForContact, (result: any, i) => {
        result[i.name] = i.value;
        return result;
      }, {}) : undefined;

    updateData.donation.dedication = serializeDedication({
      type: values.dedication.type,
      supporter_id: values.dedication.supporter_id,
      name: values.dedication.name,
      contact: contact,
      note: values.dedication.note
    });
  }
  else {
    updateData.donation.dedication = "";
  }

  if (values.check_number) {
    updateData.donation.check_number = values.check_number
  }

  try {
    await putDonation(updateData, nonprofitId);
    if (postUpdateSuccess) {
      try {
        postUpdateSuccess()
      }
      catch {
      }
    }

    onClose()
  }
  catch (e) {
    if (e instanceof TimeoutError) {
      status.form = "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds."
    }
    else {
      if (e instanceof ValidationErrorsException) {
        let updateDonationModelErrors: FormikErrors<UpdateDonationModel> = FormikHelpers.convertServerValidationToFieldStatus(e)

        status.fields = convertObject(updateDonationModelErrors, {
          'donation.campaign_id': 'campaign',
          'donation.event_id': 'event',
          'donation.gross_amount': 'gross_amount',
          'donation.fee_total': 'fee_total',
          'donation.designation': 'designation',
          'donation.comment': 'comment',
          'donation.check_number': 'check_number',
          'donation.date': 'date',
          'donation.address': "address"
        })
      }

      status.form = e['error']
    }

    action.setStatus(status)
  }
  finally {
    action.setSubmitting(false)
  }
}


function amountToMoney(value: number, nonprofit?: any): Money {
  const currency = (nonprofit && nonprofit.currency) || 'usd'
  return Money.fromCents(value, currency)
}

export interface FormData {
  event?: number,
  campaign?: number,
  gross_amount: Money,
  fee_total: Money
  date: string
  dedication?: Dedication,
  designation?: string,
  comment?: string,
  check_number?: string
  address?: Address
}

export interface EditPaymentFormikProps {
  data: PaymentData
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]
  nonprofitTimezone?: string
  preupdateDonationAction: () => void
  postUpdateSuccess: () => void
  editPaymentModalController: EditPaymentModalController,
  onClose: () => void,
  ApiManager?: ApiManager,
}


class EditPaymentFormik extends React.Component<EditPaymentFormikProps & InjectedIntlProps, {}> {
  readonly putDonation: (donation: UpdateDonationModel, nonprofitId: number, extraJQueryAjaxSettings?: JQueryAjaxSettings) => Promise<any>

  constructor(props: EditPaymentFormikProps & InjectedIntlProps) {
    super(props)

    const putDonationManager = this.props.ApiManager.get(PutDonation)
    this.putDonation = putDonationManager.putDonation.bind(putDonationManager)
  }

  @boundMethod
  async onSubmit(values: any, action: FormikActions<any>, nonprofitTimezonedDates: NonprofitTimezonedDates) {
    await onSubmit(values, action, {
      nonprofitTimezonedDates,
      putDonation: this.putDonation,
      nonprofitId: this.props.data.nonprofit.id,
      paymentId: parseInt(this.props.data.id),
      preupdateDonationAction: this.props.preupdateDonationAction,
      postUpdateSuccess: this.props.postUpdateSuccess,
      onClose: this.props.onClose
    })
  }

  loadFormFromData(props: EditPaymentFormikProps, nonprofitTimezonedDates: NonprofitTimezonedDates): FormData | {} {
    let output = {}
    if (props.data) {
      if (props.data.donation) {
        output = {
          ...output,
          eventId: props.data.donation.event && props.data.donation.event.id,
          campaignId: props.data.donation.campaign && props.data.donation.campaign.id,
          designation: props.data.donation.designation,
          comment: props.data.donation.comment,
          address: props.data.donation.address,
          dedication: parseDedication(props.data.donation.dedication)
        }
      }

      return {
        ...output,
        gross_amount: amountToMoney(props.data.gross_amount),
        fee_total: amountToMoney(props.data.fee_total),
        date: nonprofitTimezonedDates.readable_date(props.data.date)
      }
    }
    return {}
  }

  render() {

    const validationSchema = yup.object({
      gross_amount: new MoneySchema().required().label('Gross amount').min(1),
      fee_total: new MoneySchema().required().label('Fee total').max(0)
    })

    const timezoned = new NonprofitTimezonedDates(this.props.nonprofitTimezone)

    const initialValues = this.loadFormFromData(this.props, timezoned)
    const paymentData = this.props.data && convertToPaymentDataWithMoney(this.props.data)
    return <ControlledPropUpdates initialValues={paymentData} render={(paymentData) => {
      return <HoudiniFormik initialValues={initialValues} onSubmit={(values, actions) => this.onSubmit(values, actions, timezoned)} validationSchema={validationSchema} render={(props) => {
        return <EditPaymentForm formik={props} initialPaymentData={paymentData} dateFormatter={timezoned} events={this.props.events} campaigns={this.props.campaigns} editPaymentModalController={this.props.editPaymentModalController} />
      }} />;
    }} />
  }

}

export default injectIntl(inject('ApiManager')(EditPaymentFormik))



