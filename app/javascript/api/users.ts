// License: LGPL-3.0-or-later

import userRoutes from '../routes/users';
import { CurrentUser, NotLoggedInStatus } from '../hooks/useCurrentUser';
import { NetworkError } from './errors';


export async function postSignIn(loginInfo: WebLoginModel, init: RequestInit = {}): Promise<boolean> {
	const defaultConfig = {
		method: 'POST',
		credentials: 'include',
		headers: {
			'Accept': 'application/json',
		},
	} as const;

	const data = new FormData();
	data.set("user[email]", loginInfo.email);
	data.set("user[password]", loginInfo.password);

	const response = await fetch(userRoutes.userSession.url(), { ...defaultConfig,
		...init,
			body: data,
		}
	);

	if (response.ok) {
		return true;
	} else {
		throw new NetworkError({ status: response.status, data: await safelyGetJson(response) });
	}
}

async function safelyGetJson(response: Response): Promise<unknown | null> {
	try {
		return await response.json();
	}
	catch {
		return null;
	}
}


export const InvalidUsernameAndPassword = NotLoggedInStatus;

export const postSignInRoute: typeof userRoutes['userSession'] = userRoutes.userSession;

export interface WebLoginModel {
	email: string;
	password: string;
}

