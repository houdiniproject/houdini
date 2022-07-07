// License: LGPL-3.0-or-later
// from app/views/layouts/_side_nav.html.erb

import React, { useState } from 'react';


export interface SideNavInput {
	currentUser?: number | null;

}



export default function SideNav(props: React.PropsWithChildren<SideNavInput>): JSX.Element {

	const [sideNavOpen, setSideNavOpen] = useState(false);

	function toggleSideNav() {
		setSideNavOpen(!sideNavOpen);
	}


	const sideNavToggleClasses = [
		"sideNav-toggle ",
		sideNavOpen && "is-togglingOpen"
	].filter(Boolean).join(' ');

	const sideNavClasses = [
		"sideNav",
		sideNavOpen && 'is-open'
	].filter(Boolean).join(' ');

	const userIsNonprofitUser = false

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
							<%= render 'common/logo' %>
					</a>
				</section>) : ''
			 }
			{userIsAdmin ? (<section className='sideNav-section'>
				<a className='sideNav-commitchangeLogo' href='<%= root_path %>' title='Go To Home Page'>
					<%= render 'common/logo' %>
			</a>
			</section>)

			) : ''}
	<% unless current_role? [:nonprofit_admin,:nonprofit_associate] %>
		
			<% end %>

	<%= render 'layouts/admin_menu' %>

	<%= render 'layouts/user_menu' %>

	<% unless current_role?([:nonprofit_admin,:nonprofit_associate]) %>
		<section className='sideNav-section'>
				<% if Houdini.hoster.terms_and_privacy&.help_url %>
        <a className='sideNav-link' href="<%=Houdini.terms_and_privacy.help_url %>">
					<i className='sideNav-icon icon-bubble-ask-2'></i>
					<span className='sideNav-text'>Help</span>
				</a>
				<% end %>
		</section>
			<% end %>
</nav>

		<div className='sideNav-scrim'>
			<!--= on 'click' (def 'side_nav_is_open' false) -->
	<!--= add_class_if side_nav_is_open 'is-showing' -->
</div>
	</>)
}
