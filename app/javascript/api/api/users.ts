// License: LGPL-3.0-or-later
import type { CurrentUser } from "../../hooks/useCurrentUser";
import userRoutes from '../../routes/api/users';
import { NetworkError } from "../errors";

export async function getCurrent(init: RequestInit={}): Promise<CurrentUser> {
	const defaultConfig = {
		method: 'GET',
		credentials: 'include',
		headers: {
			'Content-Type': 'application/json',
		},
	} as const;

	const response = await fetch(userRoutes.apiUsersCurrent.url(), { ...defaultConfig, ...init });

	if (response.ok) {
		return (await response.json()) as CurrentUser;
	}
	else {
		throw new NetworkError({status: response.status, data: await response.json()});
	}
}