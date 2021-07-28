// License: LGPL-3.0-or-later

import userRoutes from '../routes/users';
import { CurrentUser } from '../hooks/useCurrentUser';
import { NetworkError } from './errors';



export async function postSignIn(loginInfo: WebLoginModel, init: RequestInit = {}): Promise<CurrentUser> {
	const defaultConfig = {
		method: 'POST',
		credentials: 'include',
		headers: {
			'Content-Type': 'application/json',
			'Accept': 'application/json'
		}
	} as const;

	const response = await fetch(userRoutes.userSession.url(), {
		...defaultConfig,
		...init,
		body: JSON.stringify({ "user": loginInfo })
	});

	if (response.ok) {
		return (await response.json()) as CurrentUser;
	}
	else {
		throw new NetworkError({ status: response.status, data: await response.json() });
	}
}


export interface WebLoginModel {
	email: string;
	password: string;
}

