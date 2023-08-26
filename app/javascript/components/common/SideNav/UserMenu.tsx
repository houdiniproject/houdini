// License: LGPL-3.0-or-later
// from app/views/layouts/_user_menu.html.erb

import React from 'react';
import {
	profilePath,
	settingsPath,
	destroyUserSessionPath,
} from '../../../routes';

import UserWithProfileAsChild from '../../../legacy/app_data/UserWithProfileAsChild';
import Section from './Section';
import Link from './Link';
export interface UserMenuProps {
	currentUser: UserWithProfileAsChild;
}

export default function UserMenu(props: UserMenuProps): JSX.Element {
	return (<>

		<Section>
			<Link href={(props.currentUser.profile && profilePath(props.currentUser.profile)) || "#"}>
				{
					props.currentUser.profile?.pic_tiny ?
						<img
							src={props.currentUser.profile?.pic_tiny} className='sideNav-profile' />
						: <i className="sideNav-icon icon-user-1"></i>
				}
				<span className='sideNav-text'>{(props.currentUser?.profile?.name || '').length > 0 ? props.currentUser?.profile?.name : "Your Profile"}
				</span>
			</Link>
		</Section>

		<Section>
			<Link href={settingsPath()}>
				<i className='sideNav-icon icon-setting-gear'></i>
				<span className='sideNav-text'>Settings</span>
			</Link>

			<Link href={destroyUserSessionPath()}>
				<i className='sideNav-icon icon-log-out-1'></i>
				<span className='sideNav-text'>Logout</span>
			</Link>
		</Section>



	</>
	);
}
