// License: LGPL-3.0-or-later
// from app/views/nonprofits/_transaction_tabs.html.erb

import React from 'react';
import Nonprofit from '../../../legacy/app_data/Nonprofit';
import {
	nonprofitsPayoutsPath,
	nonprofitsRecurringDonationsPath,
	nonprofitsPaymentsPath,

} from '../../../routes';

import classnames from 'classnames';
export interface TransactionTabsProps {
	active: 'payments' | 'recurring' | 'payouts';
	nonprofit: Nonprofit;
}

export default function TransactionTabs(props: TransactionTabsProps): JSX.Element {

	return (<div className='pageTabs'>
		<a href={nonprofitsPayoutsPath(props.nonprofit)}
			className={classnames('tour-payouts', {'is_active': props.active == 'payouts'})}>
			Payouts
		</a>
		<a href={nonprofitsRecurringDonationsPath(props.nonprofit)}
			className={classnames({'is-active': props.active == 'recurring'})}>
			Recurring
		</a>
		<a href={nonprofitsPaymentsPath(props.nonprofit)}
			className={classnames({'is-active': props.active == 'payments'})}>
			History
		</a >
	</div >);
}
