// License: LGPL-3.0-or-later
// from app/views/layouts/_side_nav.html.erb

import React, { useState } from 'react';
import AdminMenu from './AdminMenu';
import Logo from './Logo';
import UserMenu from './UserMenu';
import Nonprofit from '../../legacy/app_data/Nonprofit';
import UserWithProfileAsChild from '../../legacy/app_data/UserWithProfileAsChild';


export interface SideNavInput {
	administeredNonprofit?: Nonprofit | null;
	currentUser?: UserWithProfileAsChild | null;
	logo: {
		alt: string; // from app/views/common/_logo.html.erb
		url: string;  // from app/views/common/_logo.html.erb
	};

}

function currentUserIsSet(currentUser:UserWithProfileAsChild | null |undefined) : currentUser is UserWithProfileAsChild {
	return !!currentUser;
}

function userisNonprofitUser(_currentUser?:UserWithProfileAsChild | null | undefined,
	administeredNonprofit?: Nonprofit | null |undefined ) : administeredNonprofit is Nonprofit {

	return !!administeredNonprofit;

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


	return (<>
		<aside className={sideNavToggleClasses} onClick={toggleSideNav}>


			<i className='fa fa-bars' title='Show Menu'></i>
			<i className='fa fa-times' title='Hide Menu'></i>
		</aside>

		<nav className={sideNavClasses} >
			{
				!userisNonprofitUser(props.currentUser, props.administeredNonprofit) ? (
					<section className='sideNav-section'>
						<a className='sideNav-commitchangeLogo' href='<%= root_path %>' title='Go To Home Page'>
							<Logo {...props.logo} />
						</a>
					</section>) : ''
			}


			{
				userisNonprofitUser(props.currentUser, props.administeredNonprofit) ?
					<AdminMenu administeredNonprofit={props.administeredNonprofit} /> :
					''
			}

			{
				currentUserIsSet(props.currentUser) ?
					<UserMenu currentUser={props.currentUser}/>
					: ''
			}
		</nav>

		<div className={sideNavScrimClasses} >

		</div>
	</>);
}
