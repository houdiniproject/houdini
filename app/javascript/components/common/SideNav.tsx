// License: LGPL-3.0-or-later
// from app/views/layouts/_side_nav.html.erb

import React, { useState } from 'react';
import AdminMenu from './AdminMenu';
import Logo from './Logo';
import UserMenu from './UserMenu';


export interface SideNavInput {
	administeredNonprofit?: {
		id: string;
		name: string;
	} | null;

	currentUser?: {
		id: string;
		profile?: {
			country: string;
			id: string;
			name: string;
			pic_tiny?: string;
			url: string;
		};
	};

	logo: {
		alt: string; // from app/views/common/_logo.html.erb
		url: string;  // from app/views/common/_logo.html.erb
	};

}



export default function SideNav(props: SideNavInput): JSX.Element {

	const [sideNavOpen, setSideNavOpen] = useState(false);

	function toggleSideNav() {
		setSideNavOpen(!sideNavOpen);
	}

	const sideNavToggleClasses = [
		"sideNav-toggle ",
		sideNavOpen && "is-togglingOpen",
	].filter(Boolean).join(' ');

	const sideNavClasses = [
		"sideNav",
		sideNavOpen && 'is-open',
	].filter(Boolean).join(' ');

	const sideNavScrimClasses = [
		"sideNav-scrim",
		sideNavOpen && 'is-showing',
	].filter(Boolean).join(' ');

	const userIsNonprofitUser = !!props.administeredNonprofit;

	const hasCurrentUser = !!props.currentUser;

	return (<>
		<aside className={sideNavToggleClasses} onClick={toggleSideNav}>


			<i className='fa fa-bars' title='Show Menu'></i>
			<i className='fa fa-times' title='Hide Menu'></i>
		</aside>

		<nav className={sideNavClasses} >
			{
				!userIsNonprofitUser ? (
					<section className='sideNav-section'>
						<a className='sideNav-commitchangeLogo' href='<%= root_path %>' title='Go To Home Page'>
							<Logo {...props.logo} />
						</a>
					</section>) : ''
			}


			{
				userIsNonprofitUser ?
					<AdminMenu administeredNonprofit={props.administeredNonprofit} /> :
					''
			}

			{
				hasCurrentUser ?
					<UserMenu currentUser={props.currentUser}/>
					: ''
			}

			{/* <% unless current_role?([:nonprofit_admin,:nonprofit_associate]) %>
		<section className='sideNav-section'>
				<% if Houdini.hoster.terms_and_privacy&.help_url %>
        <a className='sideNav-link' href="<%=Houdini.terms_and_privacy.help_url %>">
					<i className='sideNav-icon icon-bubble-ask-2'></i>
					<span className='sideNav-text'>Help</span>
				</a>
				<% end %>
		</section>
			<% end %> */}
		</nav>

		<div className={sideNavScrimClasses} >

		</div>
	</>);
}
