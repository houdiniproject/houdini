// License: LGPL-3.0-or-later
import { observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { Address } from '../../../api';
import { isFilled } from '../../lib/utils';
import Button from '../common/form/Button';
import { FieldCreator } from '../common/form/FieldCreator';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import FormikBasicField from '../common/FormikBasicField';
import FormikHiddenField from '../common/FormikHiddenField';
import { FormikHelpers, HoudiniFormikProps } from '../common/HoudiniFormik';
import Star from '../common/icons/Star';
import { TwoColumnFields } from '../common/layout';
import SelectableTableRow from '../common/selectable_table_row/SelectableTableRow';
import { NonprofitTimezonedDates } from '../../lib/date';
import { readableKind, readableInterval, centsToDollars } from '../../lib/format';
import { PaymentData, FundraiserInfo } from './types';
import FormikCurrencyField from '../common/FormikCurrencyField';

export interface EditPaymentFormProps {
  formik: HoudiniFormikProps<any>
  initialPaymentData:PaymentData
  dateFormatter:NonprofitTimezonedDates
  campaigns:FundraiserInfo[]
  event:FundraiserInfo[]
}

class EditPaymentForm extends React.Component<EditPaymentFormProps & InjectedIntlProps, {}> {

  render() {
    const formik = this.props.formik
    return <HoudiniFormikForm formik={formik}>
        <InitialTable data={this.props.initialPaymentData} 
        dateFormatter={this.props.dateFormatter}/>
          <ConditionalOffsitePayment initialPaymentData={this.props.initialPaymentData} formik={formik}/>
          {/* <SelectField field={this.form.$('campaign')}
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


          <TextareaField field={this.form.$('comment')} label={"Notes"} rows={3}/> */}
      </HoudiniFormikForm>
  }
}

const InitialTable: React.StatelessComponent<{
  data:PaymentData, 
  dateFormatter:NonprofitTimezonedDates,
}> = (props) => {

  const rd = props.data && props.data.donation && props.data.donation.recurring_donation;

  return <table className='table--small u-marginBottom--10'>

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
          {props.dateFormatter.readable_date(props.data.date)}
        </td>
      </tr>

      <tr>
        <td>Type</td>
        <td>
          {readableKind(props.data.kind)}

          {
            props.data.offsite_payment && props.data.offsite_payment && props.data.offsite_payment.kind ?

              <span>

                &nbsp; ({props.data.offsite_payment.kind})
              </span> : undefined

          }
        </td>
      </tr>

      {
        props.data.kind === 'RecurringDonation' ?
          <tr>
            <td>Recurring</td>
            <td>
              {rd ? readableInterval(rd.interval, rd.time_unit) : false}
              since
              {rd ? props.dateFormatter.readable_date(rd.created_at) : false}
            </td>
          </tr> : false
      }

      <tr className='test-grossAmount'>
        <td>Gross Amount</td>
        <td>
          ${centsToDollars(props.data.gross_amount)}
        </td>
      </tr>

      <tr>
        <td>Processing Fees</td>
        <td>
          ${centsToDollars(props.data.fee_total)}
        </td>
      </tr>

      {
        props.data.refund_total && props.data.refund_total > 0 ?
          <tr>

            <td>Total Refunds</td>
            <td>
              ${centsToDollars(props.data.fee_total)}
            </td>
          </tr> : false
      }
      <tr>
        <td>Net Amount</td>
        <td>
          ${centsToDollars(props.data.net_amount)}
        </td>
      </tr>

      {
        props.data.origin_url ?
          <tr>

            <td>Origin</td>
            <td>
              <a target='_blank' href={props.data.origin_url}>
                {props.data.origin_url}
              </a>
            </td>
          </tr> : false
      }

      {
        props.data.charge ?
          <tr>

            <td>Status</td>
            <td>{props.data.charge.status}</td>
          </tr> : false
      }

      {props.data.offsite_payment && props.data.offsite_payment.check_number ?
        <tr>

          <td>Check #</td>
          <td>
            {props.data.offsite_payment.check_number}
          </td>
        </tr> : false

      }

      <tr>
        <td>ID</td>
        <td>{props.data.id}</td>
      </tr>

      </tbody>
    </table>
}

const ConditionalOffsitePayment:React.StatelessComponent<{initialPaymentData:PaymentData, formik:HoudiniFormikProps<any>}> = (props) =>
{
  return props.initialPaymentData.kind === 'OffsitePayment' ? <OffsitePayment formik={props.formik}/> : <></>;
}

const OffsitePayment:React.StatelessComponent<{formik:HoudiniFormikProps<any>}> = (props) => {
  return <div>
    <TwoColumnFields>
        <FieldCreator component={FormikCurrencyField} name={'gross_amount'} label={"Gross Amount"} prefix={"%"} inputId={FormikHelpers.createId(props.formik, 'gross_amount')}/>
    </TwoColumnFields>
    <FieldCreator component={FormikBasicField} name={'date'} label={'Date'} inputId={FormikHelpers.createId(props.formik, 'date')} />
  </div>
}