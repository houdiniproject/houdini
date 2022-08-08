// License: LGPL-3.0-or-later

import {userSessionPath} from '../routes';
import { NotLoggedInStatus } from '../hooks/useCurrentUser';
import { NetworkError } from './errors';


export async function postSignIn(loginInfo: WebLoginModel, init: RequestInit = {}): Promise<boolean> {
	const defaultConfig = {
		method: 'POST',
		credentials: 'include',
		headers: {
			'Accept': 'application/json',
			'Content-Type': 'application/json',
		},
	} as const;

	const data = {
		user: loginInfo,
	};

	const response = await fetch(userSessionPath(), {
		...defaultConfig,
		...init,
		body: JSON.stringify(data),
	});

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

export interface WebLoginModel {
	email: string;
	password: string;
}

