// License: LGPL-3.0-or-later
// from app/views/nonprofits/_transaction_tabs.html.erb

import React from 'react';
import Nonprofit from '../../../legacy/app_data/Nonprofit';
import payments from '../../../routes/nonprofits/payments';
import recurring from '../../../routes/nonprofits/recurring_donations';
import payouts from '../../../routes/nonprofits/payouts';
import classnames from 'classnames';
export interface TransactionTabsProps {
	active: 'payments' | 'recurring' | 'payouts';
	nonprofit: Nonprofit;
}

export default function TransactionTabs(props: TransactionTabsProps): JSX.Element {

	return (<div className='pageTabs'>
		<a href={payouts.nonprofitsPayouts.path(props.nonprofit)}
			className={classnames('tour-payouts', {'is_active': props.active == 'payouts'})}>
			Payouts
		</a>
		<a href={recurring.nonprofitsRecurringDonations.path(props.nonprofit)}
			className={classnames({'is-active': props.active == 'recurring'})}>
			Recurring
		</a>
		<a href={payments.nonprofitsPayments.path(props.nonprofit)}
			className={classnames({'is-active': props.active == 'payments'})}>
			History
		</a >
	</div >);
}
