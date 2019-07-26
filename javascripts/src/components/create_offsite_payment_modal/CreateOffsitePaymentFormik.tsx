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
import { PaymentDataWithMoney, PaymentData, FundraiserInfo, Address } from '../edit_payment_pane/types';
import { Money } from '../../lib/money';

import { MoneySchema } from '../../lib/yup/money_schema';

import { convertObject, isFilled } from '../../lib/utils';
import { ApiManager } from '../../lib/api_manager';
import { inject } from 'mobx-react';
import ControlledPropUpdates from '../common/ControlledPropUpdates';
import CreateOffsitePaymentForm from './CreateOffsitePaymentForm';
import { CreateOffsitePaymentModalController } from './CreateOffsitePaymentModalChildren';
import { CreateOffsiteDonation, CreateOffsiteDonationModel } from '../../lib/api/create_offsite_donation';

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
  createOffsiteDonation: CreateOffsiteDonation
  nonprofitTimezonedDates: NonprofitTimezonedDates
  nonprofitId: number
  supporterId: number
  onClose: () => void
  preupdateDonationAction?: () => void,
  postUpdateSuccess?: () => void,


}


export async function onSubmit(
  values: FormData,
  action: FormikActions<FormData>,
  { createOffsiteDonation, nonprofitTimezonedDates, nonprofitId, supporterId, onClose, preupdateDonationAction, postUpdateSuccess }: AdditionalSubmitInfo
) {

  let status: HoudiniFormikServerStatus<FormData> = {}
  if (preupdateDonationAction) {
    preupdateDonationAction();
  }
  if (preupdateDonationAction) {
    preupdateDonationAction()
  }


  let postData:Partial<CreateOffsiteDonationModel> = {
    nonprofit_id: nonprofitId,
    supporter_id: supporterId,
    amount: values.gross_amount.amountInCents,
    designation: values.designation,
    comment: values.comment,
    date: nonprofitTimezonedDates.readable_date_time_to_iso(values.date)
  }

  if (values.campaign) {
    postData = {...postData, campaign_id: values.campaign.toString()}
  }
  if (values.event) {
    postData = {...postData, event_id: values.event.toString()}
  }
  

  if (values.dedication && isFilled(values.dedication.type)) {
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

    postData.dedication = serializeDedication({
      type: values.dedication.type,
      supporter_id: values.dedication.supporter_id,
      name: values.dedication.name,
      contact: contact,
      note: values.dedication.note
    });
  }
  else {
    postData.dedication = "";
  }

  if (values.check_number) {
    postData.offsite_payment =  {check_number: values.check_number}
  }

  try {
    await createOffsiteDonation.postDonation(postData as CreateOffsiteDonationModel, nonprofitId)
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
        let createDonationModelErrors: FormikErrors<CreateOffsiteDonationModel> = FormikHelpers.convertServerValidationToFieldStatus(e)

        status.fields = convertObject(createDonationModelErrors, {
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

export interface CreateOffsitePaymentFormikProps {
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]
  nonprofitTimezone?: string
  supporterId: number
  nonprofitId: number
  preupdateDonationAction: () => void
  postUpdateSuccess: () => void
  createOffsitePaymentModalController: CreateOffsitePaymentModalController,
  onClose: () => void,
  ApiManager?: ApiManager,
}


class CreateOffsitePaymentFormik extends React.Component<CreateOffsitePaymentFormikProps & InjectedIntlProps, {}> {
  createOffsiteDonation : CreateOffsiteDonation
  constructor(props: CreateOffsitePaymentFormikProps & InjectedIntlProps) {
    super(props)

    this.createOffsiteDonation = this.props.ApiManager.get(CreateOffsiteDonation)
    
  }

  @boundMethod
  async onSubmit(values: any, action: FormikActions<any>, nonprofitTimezonedDates: NonprofitTimezonedDates) {
    await onSubmit(values, action, {
      nonprofitTimezonedDates,
      supporterId: this.props.supporterId,
      nonprofitId: this.props.nonprofitId,
      preupdateDonationAction: this.props.preupdateDonationAction,
      postUpdateSuccess: this.props.postUpdateSuccess,
      onClose: this.props.onClose,
      createOffsiteDonation : this.createOffsiteDonation
    })
  }

  loadFormFromData(props: CreateOffsitePaymentFormikProps, nonprofitTimezonedDates: NonprofitTimezonedDates): FormData | {} {
    let output:Partial<FormData> = {
          designation: "",
          comment: "",
          address: {
            address: "",
            city: "",
            state_code: "",
            zip_code: "",
            country: ""
          },
          dedication: {
            name: "",
            contact: {
              email: "",
              phone:"",
              address:""
            },
            note:""
          }
      
      }

      return {
        ...output,
        gross_amount: amountToMoney(0),
        date: nonprofitTimezonedDates.readable_date(new Date().toISOString())
      }
    }
  

  render() {

    const validationSchema = yup.object({
      gross_amount: new MoneySchema().required().label('Gross amount').min(1),
      date: yup.date().required().label('Date')
    })

    const timezoned = new NonprofitTimezonedDates(this.props.nonprofitTimezone)

    const initialValues = this.loadFormFromData(this.props, timezoned)
    return  <HoudiniFormik initialValues={initialValues} onSubmit={(values, actions) => this.onSubmit(values, actions, timezoned)} validationSchema={validationSchema} render={(props) => {
        return <CreateOffsitePaymentForm formik={props} dateFormatter={timezoned} events={this.props.events} campaigns={this.props.campaigns} createOffsitePaymentModalController={this.props.createOffsitePaymentModalController} />
      }} />;
  }

}

export default injectIntl(inject('ApiManager')(CreateOffsitePaymentFormik))



