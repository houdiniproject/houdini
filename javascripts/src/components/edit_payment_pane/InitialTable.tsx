// License: LGPL-3.0-or-later
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { PaymentDataWithMoney } from './types';
import { NonprofitTimezonedDates } from '../../lib/date';
import { readableKind, readableInterval, centsToDollars } from '../../lib/format';
import moneyToString from '../../lib/format/money_to_string';
import MoneyToString from '../common/MoneyToString';
import { Money } from '../../lib/money';

export interface InitialTableProps {
  data: PaymentDataWithMoney,
  dateFormatter: NonprofitTimezonedDates
}

class InitialTable extends React.Component<InitialTableProps & InjectedIntlProps> {
  render() {
    const rd = this.props.data && this.props.data.donation && this.props.data.donation.recurring_donation;

    return <table className='table--small u-marginBottom--10'>

      <thead>
        <tr>
          <th>Payment Info</th>
          <th />
        </tr>
      </thead>

      <tbody>
        <tr>
          <td>Date</td>
          <td>
            {this.props.dateFormatter.readable_date(this.props.data.date)}
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
                  {rd ? this.props.dateFormatter.readable_date(rd.created_at) : false}
              </td>
            </tr> : false
        }

        <tr>
          <td>Gross Amount</td>
          <td>
            <MoneyToString value={this.props.data.gross_amount} />
          </td>
        </tr>

        <tr>
          <td>Processing Fees</td>
          <td>
            <MoneyToString value={this.props.data.fee_total} />
          </td>
        </tr>
        {
          this.props.data.refund_total && this.props.data.refund_total.greaterThan(Money.fromCents(0, this.props.data.refund_total.currency)) ?
            <tr>

              <td>Total Refunds</td>
              <td>
                <MoneyToString value={this.props.data.refund_total} />
              </td>
            </tr> : false
        }
        <tr>
          <td>Net Amount</td>
          <td>
            <MoneyToString value={this.props.data.net_amount} />
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
    </table>
  }
}

export default injectIntl(InitialTable)



