// License: LGPL-3.0-or-later
import { rest } from 'msw';
import { getCurrentRoute } from '../../users';
import { waitFor } from '@testing-library/react';
import { DefaultUser } from '.';
import {NotLoggedInStatus} from '../../users';
const IsCurrentUserAuthenticated = 'is-current-user-authenticated';
const WaitDuringGetCurrent = 'wait-during-get-current';


export const UserPresignedIn = [
	rest.get(getCurrentRoute(), (_req, res, ctx) => {
		return res(
			ctx.json(DefaultUser)
		);
	}),
];

export const UserSignedInIfAuthenticated = [
	rest.get(getCurrentRoute(), (_req, res, ctx) => {
		if (!IsAuthenticated()) {
			return res(ctx.status(NotLoggedInStatus));
		}
		else {
			return res(ctx.json(DefaultUser));
		}
	}),
];

export const UserPresignedInAndWaitUntilSignal = [
	rest.get(getCurrentRoute(), async (_req, res, ctx) => {
		await waitFor(() => ShouldWaitDuringGetCurrent());
		return res(
			ctx.json(DefaultUser)
		);
	}),
];

export function IsAuthenticated(): boolean {
	return !!sessionStorage.getItem(IsCurrentUserAuthenticated);
}

export function SetAuthenticated(): void {
	sessionStorage.setItem(IsCurrentUserAuthenticated, 'true');
}

export function ShouldWaitDuringGetCurrent(): boolean {
	return !!sessionStorage.getItem(WaitDuringGetCurrent);
}

export function StopWaitingDuringGetCurrent(): void {
	sessionStorage.setItem(WaitDuringGetCurrent, 'true');
}