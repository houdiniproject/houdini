// License: LGPL-3.0-or-later
// from app/views/layouts/_admin_menu.html.erb

import React from 'react';
import nonprofitRoutes from '../../routes/nonprofits';



export interface AdminMenuProps {
	currentNonprofit: {
		id: string
		name: string
	}
	
}

export default function AdminMenu(props: AdminMenuProps): JSX.Element {
	return (
		<section className='sideNav-section'>
		<a className='sideNav-link' href={administered_nonprofit.url}>
			<%= image_tag rails_storage_proxy_url(administered_nonprofit.logo_by_size(:small)), class:"sideNav-profile" %>
			<span className='sideNav-text'><%= administered_nonprofit.name %></span>
		</a>

		<a className='sideNav-link' href='<%= NonprofitPath.dashboard(administered_nonprofit) %>'>
			<i className='sideNav-icon icon-camera-graph-2'></i>
			<span className='sideNav-text'>Dashboard</span>
		</a>


		<a className='sideNav-link' href='<%= nonprofits_supporters_path(administered_nonprofit) %>'>
			<i className='sideNav-icon icon-contacts-3'></i>
			<span className='sideNav-text'>Supporters</span>
		</a>

		<a className='sideNav-link' href='<%= nonprofits_payments_path(administered_nonprofit) %>'>
			<i className='sideNav-icon icon-piggy-bank'></i>
			<span className='sideNav-text'>Payments</span>
		</a>

			<a className='sideNav-link' href='<%= administered_nonprofit.url + '/events' %>'>
			<i className='sideNav-icon icon-ticket-2'></i>
			<span className='sideNav-text'>Events</span>
		</a>

		<a className='sideNav-link' href='<%= administered_nonprofit.url + '/campaigns' %>'>
			<i className='sideNav-icon icon-thermometer-medium'></i>
			<span className='sideNav-text'>Campaigns</span>
		</a>

		<a className='sideNav-link' href='<%= nonprofits_button_basic_path(administered_nonprofit) %>'>
			<i className='sideNav-icon icon-credit-card'></i>
			<span className='sideNav-text'>Donate Button</span>
		</a>

	</section>);
}
