// License: LGPL-3.0-or-later
// from app/views/layouts/_admin_menu.html.erb

import React from 'react';
import {
	nonprofitPath,
	dashboardNonprofitPath,
	nonprofitsSupportersPath,
	nonprofitsPaymentsPath,
	nonprofitEventsPath,
	nonprofitCampaignsPath,
	nonprofitsButtonBasicPath,
} from '../../../routes';

import Nonprofit from '../../../legacy/app_data/Nonprofit';
import Section from './Section';
import Link from './Link';


export interface AdminMenuProps {
	administeredNonprofit: Nonprofit;
}

export default function AdminMenu(props: AdminMenuProps): JSX.Element {
	return (
		<Section>
			<Link href={nonprofitPath(props.administeredNonprofit)}>
				<img src={props.administeredNonprofit.logo.small} className={"sideNav-profile"} alt={props.administeredNonprofit.name} />

				<span className='sideNav-text'>{props.administeredNonprofit.name}</span>
			</Link>

			<Link href={dashboardNonprofitPath(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-camera-graph-2'></i>
				<span className='sideNav-text'>Dashboard</span>
			</Link>


			<Link href={nonprofitsSupportersPath(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-contacts-3'></i>
				<span className='sideNav-text'>Supporters</span>
			</Link>

			<Link href={nonprofitsPaymentsPath(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-piggy-bank'></i>
				<span className='sideNav-text'>Payments</span>
			</Link>

			<Link href={nonprofitEventsPath(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-ticket-2'></i>
				<span className='sideNav-text'>Events</span>
			</Link>

			<Link href={nonprofitCampaignsPath(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-thermometer-medium'></i>
				<span className='sideNav-text'>Campaigns</span>
			</Link>

			<Link href={nonprofitsButtonBasicPath(props.administeredNonprofit)}>
				<i className='sideNav-icon icon-credit-card'></i>
				<span className='sideNav-text'>Donate Button</span>
			</Link>

		</Section>);
}
