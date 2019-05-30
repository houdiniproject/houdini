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
import { PaymentData } from './types';

export interface EditPaymentFormProps {
  formik: HoudiniFormikProps<any>
  initialPaymentData:PaymentData
  dateFormatter:NonprofitTimezonedDates
  editAddress: (address?: Address) => void
  isDefaultAddress: (addressId:number) => boolean
  addAddress: () => void
}

class SupporterPane extends React.Component<EditPaymentFormProps & InjectedIntlProps, {}> {

  render() {
    const formik = this.props.formik
    return <HoudiniFormikForm formik={formik}>
      <InitialTable data={this.props.initialPaymentData} 
        dateFormatter={this.props.dateFormatter}/>
        
      </HoudiniFormikForm>
  }
}

function InitialTable(props:{
  data:PaymentData, 
  dateFormatter:NonprofitTimezonedDates,
}) {

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