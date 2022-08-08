// License: LGPL-3.0-or-later
import type { CurrentUser } from "../../hooks/useCurrentUser";
import {currentApiUsersPath} from '../../routes';
import { NetworkError } from "../errors";
import {StatusCode} from '../status_codes';
import 'whatwg-fetch';

export async function getCurrent(init: RequestInit={}): Promise<CurrentUser> {
	const defaultConfig = {
		method: 'GET',
		credentials: 'include',
		headers: {
			'Content-Type': 'application/json',
		},
	} as const;

	const response = await fetch(currentApiUsersPath(), { ...defaultConfig, ...init });

	if (response.ok) {
		return (await response.json()) as CurrentUser;
	}
	else {
		throw new NetworkError({status: response.status, data: await safelyGetJson(response)});
	}
}

async function safelyGetJson(response:Response) :Promise<unknown|null>
{
	try {
		await response.json();
	}
	catch {
		return null;
	}
}


export const NotLoggedInStatus = StatusCode.Forbidden;

export const getCurrentRoute  = currentApiUsersPath;