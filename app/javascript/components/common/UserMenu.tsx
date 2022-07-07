// License: LGPL-3.0-or-later
// from app/views/layouts/_user_menu.html.erb

import React from 'react';
import profileRoutes from '../../routes/profiles';
import settingsRoutes from '../../routes/settings';
import usersRoutes from '../../routes/users';


export interface UserMenuProps {
	currentUser: {
		profile?: {
			id: string;
			name: string;
		};
	};
}

export default function UserMenu(props: UserMenuProps): JSX.Element {
	return (<>

		<section className='sideNav-section'>
			<a className='sideNav-link' href={profileRoutes.profile.path(props.currentUser.profile)}>

				{/* // <a className='sideNav-link' href={<%= profile_url(current_user.profile) %>'>
		// <% if current_user.profile.picture.attached? %>
		// 	<%= image_tag  rails_storage_proxy_url(current_user.profile.picture_by_size(:tiny)), class: 'sideNav-profile' %>
		// 	<% else %>
		*/}
				<i className="sideNav-icon icon-user-1"></i>
				{/* <% end %> */}
				<span className='sideNav-text'>
					{/* <%= current_user.profile.name.blank? ?  */}
							&apos;Your Profile&apos;
					{/* : current_user.profile.name %> */}
				</span>


			</a>
		</section>

		<section className='sideNav-section'>
			<a className='sideNav-link' href={settingsRoutes.settings.url()}>
				<i className='sideNav-icon icon-setting-gear'></i>
				<span className='sideNav-text'>Settings</span>
			</a>

			<a className='sideNav-link' href={usersRoutes.destroyUserSession.path()}>
				<i className='sideNav-icon icon-log-out-1'></i>
				<span className='sideNav-text'>Logout</span>
			</a>
		</section>



	</>
	);
}
