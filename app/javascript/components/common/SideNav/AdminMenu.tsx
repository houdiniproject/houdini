// License: LGPL-3.0-or-later
// from app/views/layouts/_admin_menu.html.erb

import React from 'react';
import nonprofitRoutes from '../../../routes/nonprofits';
import supporterRoutes from '../../../routes/nonprofits/supporters';
import paymentRoutes from '../../../routes/nonprofits/payments';
import eventRoutes from '../../../routes/nonprofits/events';
import campaignRoutes from '../../../routes/nonprofits/campaigns';
import buttonRoutes from '../../../routes/nonprofits/button';
import Nonprofit from '../../../legacy/app_data/Nonprofit';


export interface AdminMenuProps {
	administeredNonprofit: Nonprofit;
}

export default function AdminMenu(props: AdminMenuProps): JSX.Element {
	return (
		<section className='sideNav-section'>
			<a className='sideNav-link' href={nonprofitRoutes.nonprofit.path(props.administeredNonprofit)}>
				<img src={props.administeredNonprofit.logo.small} className={"sideNav-profile"} alt={props.administeredNonprofit.name} />

				<span className='sideNav-text'>{props.administeredNonprofit.name}</span>
			</a>

			<a className='sideNav-link' href={nonprofitRoutes.dashboardNonprofit.path(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-camera-graph-2'></i>
				<span className='sideNav-text'>Dashboard</span>
			</a>


			<a className='sideNav-link' href={supporterRoutes.nonprofitsSupporters.path(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-contacts-3'></i>
				<span className='sideNav-text'>Supporters</span>
			</a>

			<a className='sideNav-link' href={paymentRoutes.nonprofitsPayments.path(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-piggy-bank'></i>
				<span className='sideNav-text'>Payments</span>
			</a>

			<a className='sideNav-link' href={eventRoutes.nonprofitEvents.path(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-ticket-2'></i>
				<span className='sideNav-text'>Events</span>
			</a>

			<a className='sideNav-link' href={campaignRoutes.nonprofitsCampaigns.path(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-thermometer-medium'></i>
				<span className='sideNav-text'>Campaigns</span>
			</a>

			<a className='sideNav-link' href={buttonRoutes.nonprofitsButtonBasic.path(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-credit-card'></i>
				<span className='sideNav-text'>Donate Button</span>
			</a>

		</section>);
}
