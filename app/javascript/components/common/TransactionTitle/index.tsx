// License: LGPL-3.0-or-later
// from app/views/nonprofits/_transaction_title.html.erb

import React from 'react';
import Nonprofit from '../../../legacy/app_data/Nonprofit';
import TransactionTabs from './TransactionTabs';


export interface TransactionTitleProps {
	active: 'payments'|'recurring'|'payouts';
	icon_class: string;
	nonprofit: Nonprofit;
	page_name: string;
}



export default function TransactionTitle(props: TransactionTitleProps): JSX.Element {

	return (<header className='header stripe--green'>
		<div className='container--wide u-textAlign--left'>
			<i className={`header-icon ${props.icon_class}`}></i>
			<h3 className='header-title'>Payments <small className='header-title-sub'>&#x2022; {props.page_name}</small></h3>
			<TransactionTabs nonprofit={props.nonprofit} active={props.active}></TransactionTabs>
		</div>
	</header>);
}
