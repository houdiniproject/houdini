// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {action, computed} from "mobx";
import {FieldDefinition} from "mobx-react-form";
import {HoudiniForm} from "../../lib/houdini_form";
import ProgressableButton from "../common/ProgressableButton";
import {centsToDollars, dollarsToCents, readableInterval, readableKind} from "../../lib/format";
import {NonprofitTimezonedDates} from '../../lib/date';
import {UpdateDonationModel, PutDonation} from "../../lib/api/put_donation";
import {ApiManager} from "../../lib/api_manager";
import * as CustomAPIS from "../../lib/apis";
import {CSRFInterceptor} from "../../lib/csrf_interceptor";
import {BasicField, CurrencyField, SelectField, TextareaField} from '../common/fields';
import {TwoColumnFields} from "../common/layout";
import {Validations} from "../../lib/vjf_rules";
import _ = require("lodash");
import {Dedication, parseDedication, serializeDedication} from '../../lib/dedication';
import blacklist = require("validator/lib/blacklist");
import {createFieldDefinition} from "../../lib/mobx_utils";
import Modal from "../common/Modal";
import ReactInput from "../common/form/ReactInput";


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

export interface EditPaymentPaneProps {
  data: PaymentData
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]

  nonprofitTimezone?: string
  preupdateDonationAction: () => void
  postUpdateSuccess: () => void

  //from ModalProps
  onClose: () => void
  modalActive: boolean
}

export interface FundraiserInfo {
  id: number
  name: string
}

class EditPaymentPaneForm extends HoudiniForm {

}


@observer
class EditPaymentPane extends React.Component<EditPaymentPaneProps & InjectedIntlProps, {}> {

  constructor(props: EditPaymentPaneProps & InjectedIntlProps) {
    super(props);
    this.putDonation = new ApiManager(CustomAPIS.APIS as Array<any>, CSRFInterceptor).get(PutDonation);

    this.loadFormFromData()

  }

  @computed
  get nonprofitTimezonedDates(): NonprofitTimezonedDates {
    return new NonprofitTimezonedDates(this.props.nonprofitTimezone)
  }

  @computed
  get dedication(): Dedication | null {
    return parseDedication(this.props.data && this.props.data.donation && this.props.data.donation.dedication)
  }

  putDonation: PutDonation;

  @action.bound
  async updateDonation() {
    if (this.props.preupdateDonationAction) {
      this.props.preupdateDonationAction()
    }


    let updateData: UpdateDonationModel = {
      id: Number(this.props.data.donation.id),
      donation: {
        designation: this.form.$('designation').value,
        comment: this.form.$('comment').value,
        campaign_id: this.form.$('campaign').value,
        event_id: this.form.$('event').value,
        gross_amount: dollarsToCents(this.form.$('gross_amount').get('value')),
        fee_total: dollarsToCents(this.form.$('fee_total').get('value')),

        date: this.form.$('date').get('value')
      }
    };

    if (this.form.$('dedication.type').get('value') != '') {
      const nameToValueForContact = ['full_address', 'phone', 'email'].map((i) => {
        return {
          name: i, value: this.form.$(`dedication.${i}`).get('value')
        }
      });
      const contact = _.some(nameToValueForContact, (i) => i.value && i.value != "") ?
        _.reduce(nameToValueForContact, (result: any, i) => {
          result[i.name] = i.value;
          return result;
        }, {}) : undefined;

      updateData.donation.dedication = serializeDedication({
        type: this.form.$('dedication.type').get('value'),
        supporter_id: this.form.$('dedication.supporter_id').get('value'),
        name: this.form.$('dedication.name').get('value'),
        contact: contact,
        note: this.form.$('dedication.note').get('value')
      });
    }
    else {
      updateData.donation.dedication = "";
    }

    if (this.form.has('check_number')) {
      updateData.donation.check_number = this.form.$('check_number').value
    }


    await this.putDonation.putDonation(updateData, this.props.data.nonprofit.id);


    if (this.props.postUpdateSuccess) {
      try {
        this.props.postUpdateSuccess()
      }
      catch {
      }
    }

    this.props.onClose()

  }


  @action.bound
  loadFormFromData() {
    const eventId = this.props.data.donation.event && this.props.data.donation.event.id;
    const campaignId = this.props.data.donation.campaign && this.props.data.donation.campaign.id;
    let params: { [name: string]: FieldDefinition } = {
      'event': {name: 'event', label: 'Event', value: eventId},
      'campaign': {name: 'campaign', label: 'Campaign', value: campaignId},
      'gross_amount': createFieldDefinition({
        name: 'gross_amount', label: 'Gross Amount', value: this.props.data.gross_amount,
        input: (amount: number) => centsToDollars(amount),
        output: (dollarString: string) => parseFloat(blacklist(dollarString, '$,'))
      }),
      'fee_total': createFieldDefinition({
        name: 'fee_total', label: 'Fees', value: this.props.data.fee_total,
        input: (amount: number) => centsToDollars(amount),
        output: (dollarString: string) => parseFloat(blacklist(dollarString, '$,'))
      }),
      'date': createFieldDefinition({
        name: 'date', label: 'Date',
        value: this.props.data.date,
        input: (isoTime: string) => this.nonprofitTimezonedDates.readable_date(isoTime),
        output: (date: string) => this.nonprofitTimezonedDates.readable_date_time_to_iso(date)
      }),
      'dedication': {
        name: 'dedication', label: 'Dedication', fields: [
          createFieldDefinition({name: 'type', label: 'Dedication Type', value: this.dedication && this.dedication.type}),
          createFieldDefinition({name: 'supporter_id', type: 'hidden', value: this.dedication && this.dedication.supporter_id}),
          createFieldDefinition({name: 'name', label: 'Person dedicated for', value: this.dedication && this.dedication.name}),
          createFieldDefinition({name: 'full_address', label: 'Full address', value: this.dedication && this.dedication.contact && this.dedication.contact.address}),
          createFieldDefinition({name: 'phone', label: 'Phone', value: this.dedication && this.dedication.contact && this.dedication.contact.phone}),
          createFieldDefinition({name: 'email', label: 'email', value: this.dedication && this.dedication.contact && this.dedication.contact.email}),
          createFieldDefinition({name: 'note', value: this.dedication && this.dedication.note})
        ]
      },
      'designation': {name: 'designation', label: 'Designation', value: this.props.data.donation.designation},
      'comment': {name: 'comment', label: 'Note', value: this.props.data.donation.comment}
    };




    if (this.props.data.kind == 'OffsitePayment') {
      params.check_number = {
        name: 'check_number',
        label: 'Check Number',
        value: this.props.data.offsite_payment.check_number
      };

      params.date.validators = [Validations.isDate('MM/DD/YYYY')];

      params.gross_amount.validators = [Validations.isGreaterThanOrEqualTo(0.01)];
      params.fee_total.validators = [Validations.optional(Validations.isLessThanOrEqualTo(0))];

    }

    return new EditPaymentPaneForm({fields: _.values(params)}, {
      hooks: {
        onSuccess: async () => {
          await this.updateDonation()
        }
      }
    })
  }

  @computed get form(): EditPaymentPaneForm {
    //add this.props because we need to reload on prop change
    return this.props && this.loadFormFromData()
  }

  @computed get dateFormatter(): NonprofitTimezonedDates {
    return new NonprofitTimezonedDates(this.props.nonprofitTimezone)
  }

  @action.bound
  innerRender() {
    let rd = this.props.data && this.props.data.donation && this.props.data.donation.recurring_donation;
    let initialTable = <table className='table--small u-marginBottom--10'>

      <thead>
      <tr>
        <th>Payment Info</th>
        <th/>
      </tr>
      </thead>

      <tbody>
      <tr>
        <td>Date</td>
        <td>
          {this.dateFormatter.readable_date(this.props.data.date)}
        </td>
      </tr>

      <tr>
        <td>Type</td>
        <td>
          {readableKind(this.props.data.kind)}

          {
            this.props.data.offsite_payment && this.props.data.offsite_payment && this.props.data.offsite_payment.kind ?

              <span>

                &nbsp; ({this.props.data.offsite_payment.kind})
              </span> : undefined

          }
        </td>
      </tr>

      {
        this.props.data.kind === 'RecurringDonation' ?
          <tr>
            <td>Recurring</td>
            <td>
              {rd ? readableInterval(rd.interval, rd.time_unit) : false}
              since
              {rd ? this.dateFormatter.readable_date(rd.created_at) : false}
            </td>
          </tr> : false
      }

      <tr className='test-grossAmount'>
        <td>Gross Amount</td>
        <td>
          ${centsToDollars(this.props.data.gross_amount)}
        </td>
      </tr>

      <tr>
        <td>Processing Fees</td>
        <td>
          ${centsToDollars(this.props.data.fee_total)}
        </td>
      </tr>

      {
        this.props.data.refund_total && this.props.data.refund_total > 0 ?
          <tr>

            <td>Total Refunds</td>
            <td>
              ${centsToDollars(this.props.data.fee_total)}
            </td>
          </tr> : false
      }
      <tr>
        <td>Net Amount</td>
        <td>
          ${centsToDollars(this.props.data.net_amount)}
        </td>
      </tr>

      {
        this.props.data.origin_url ?
          <tr>

            <td>Origin</td>
            <td>
              <a target='_blank' href={this.props.data.origin_url}>
                {this.props.data.origin_url}
              </a>
            </td>
          </tr> : false
      }

      {
        this.props.data.charge ?
          <tr>

            <td>Status</td>
            <td>{this.props.data.charge.status}</td>
          </tr> : false
      }

      {this.props.data.offsite_payment && this.props.data.offsite_payment.check_number ?
        <tr>

          <td>Check #</td>
          <td>
            {this.props.data.offsite_payment.check_number}
          </td>
        </tr> : false

      }

      <tr>
        <td>ID</td>
        <td>{this.props.data.id}</td>
      </tr>

      </tbody>
    </table>;


    let checkNumber = this.props.data.offsite_payment ?
      <BasicField field={this.form.$('check_number')} label={"Check or Payment Number/ID"}/> : false;

    let offsitePayment = this.props.data.kind === "OffsitePayment" ? (<div>

      <TwoColumnFields>
        <CurrencyField field={this.form.$('gross_amount')} label={"Gross Amount"} currencySymbol={"$"}/>
        <CurrencyField field={this.form.$('fee_total')} label={"Processing Fees"} mustBeNegative={true}/>

      </TwoColumnFields>

      <BasicField field={this.form.$('date')} label={"Date"}/>


      {checkNumber}
    </div>) : undefined;
    return <div className={"tw-bs"}>
      <div>
        {initialTable}

        <form className='u-marginTop--20'>

          {offsitePayment}


          <SelectField field={this.form.$('campaign')}
                       label={"Campaign"}
                       options={this.props.campaigns}/>


          <SelectField field={this.form.$('event')}
                       label={"Event"}
                       options={this.props.events}/>


          <TextareaField field={this.form.$('designation')} label={"Designation"} rows={3}/>

          <div className="panel panel-default">
            <div className="panel-heading"><label>Dedication</label></div>
            <div className="panel-body">
              <SelectField field={this.form.$('dedication.type')} label={"Dedication Type"}
                           options={[{id: null, name: ''}, {id: 'honor', name: 'In honor of'}, {
                             id: 'memory',
                             name: 'In memory of'
                           }]}/>

              {this.form.$('dedication.type').get('value') != '' ? <div>
                  <div className={"panel panel-default"}>
                    <div className="panel-heading"><label>Dedicated to:</label></div>
                    <div className={'panel-body'}>
                      <table className='table--small u-marginBottom--10'>
                        <tbody>
                        <tr>
                          <th>Name</th>
                          <td><ReactInput field={this.form.$('dedication.name')} label={'Name'} className={"form-control"}/></td>
                        </tr>
                        <tr>
                          <th> Supporter
                            ID
                          </th>
                          <td>{this.dedication.supporter_id}<input {...this.form.$('dedication.supporter_id').bind()}/>
                          </td>
                        </tr>

                        <tr>
                          <th>Full Address
                          </th>
                          <td><ReactInput field={this.form.$('dedication.full_address')}  className={"form-control"}/>
                          </td>
                        </tr>
                        <tr>
                          <th>Phone Number
                          </th>
                          <td><ReactInput field={this.form.$('dedication.phone')} className={"form-control"}/>
                          </td>
                        </tr>
                        <tr>
                          <th>Email Address
                          </th>
                          <td><ReactInput field={this.form.$('dedication.email')}  className={"form-control"}/>
                          </td>
                        </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                  <TextareaField rows={3} placeholder={"Dedication"} field={this.form.$('dedication.note')}
                                 label={"Dedication Note"}/></div>
                : undefined}
            </div>
          </div>


          <TextareaField field={this.form.$('comment')} label={"Notes"} rows={3}/>


          <ProgressableButton buttonText={'Save'}
                              buttonTextOnProgress={'Updating...'} className={'button'}
                              inProgress={this.form.submitting}
                              disabled={!this.form.isValid}
                              disableOnProgress={true} onClick={this.form.onSubmit}/>


        </form>
      </div>
    </div>
  }

  render() {

    //force it to check the form values so this updates
    this.form.values()

    const modal =
      <Modal modalActive={this.props.modalActive} titleText={'Edit Donation'} focusDialog={true}
             onClose={this.props.onClose} dialogStyle={{minWidth: '768px'}} childGenerator={() => this.innerRender()}/>

    return modal;
  }
}

export default injectIntl(observer(EditPaymentPane))
