// License: LGPL-3.0-or-later
// from app/views/layouts/_user_menu.html.erb

import React from 'react';
import profileRoutes from '../../routes/profiles';
import settingsRoutes from '../../routes/settings';
import usersRoutes from '../../routes/users';
import UserWithProfileAsChild from '../../legacy/app_data/UserWithProfileAsChild';

export interface UserMenuProps {
	currentUser: UserWithProfileAsChild;
}

export default function UserMenu(props: UserMenuProps): JSX.Element {
	return (<>

		<section className='sideNav-section'>
			<a className='sideNav-link' href={profileRoutes.profile.path(props.currentUser.profile)}>
				{
					props.currentUser.profile?.pic_tiny ?
						<img
							src={props.currentUser.profile?.pic_tiny} className='sideNav-profile' />
						: <i className="sideNav-icon icon-user-1"></i>
				}
				<span className='sideNav-text'>{(props.currentUser?.profile?.name || '').length > 0 ? props.currentUser.profile.name : "Your Profile"}
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
