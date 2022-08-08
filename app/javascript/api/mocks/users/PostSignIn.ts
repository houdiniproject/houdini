// License: LGPL-3.0-or-later

import { rest } from 'msw';
import { SetAuthenticated } from '../../api/mocks/users';
import { waitFor } from '@testing-library/react';
import { InvalidUsernameAndPassword} from '../../users';
import { userSessionPath} from '../../../routes';

const AllowUserSignIn = 'allow-user-sign-in';
const WaitDuringPostSignIn = 'wait-during-post-sign-in';

export const UserSignInSucceeds = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		SetAuthenticated();
		return res(
			ctx.json({ "status": "success" })
		);
	}),
];


export const UserSignInSucceedsWithDelay = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		SetAuthenticated();
		return res(
			ctx.delay(5000),
			ctx.json({ "status": "success" })
		);
	}),
];

export const UserSignInFailsFromServerError = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		return res(ctx.status(500));
	}),
];

export const UserSignInFailsFromServerErrorWithDelay = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		return res(ctx.delay(5000), ctx.status(500));
	}),
];

export const UserSignInFailsFromInvalidLogin = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		return res(ctx.status(InvalidUsernameAndPassword));
	}),
];

export const UserSignInFailsOnceAndThenSucceeds = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		if (WillAllowUserSignIn()) {
			SetAuthenticated();
			return res(
				ctx.json({ "status": "success" })
			);
		}
		else {
			SetAllowUserSignIn();
			return res(ctx.status(InvalidUsernameAndPassword));
		}
	}),
];

export const UserSignInWaitUntilSignal = [
	rest.post(userSessionPath(), async (_req, res, ctx) => {
		await waitFor(() => WillWaitDuringUserSignIn());
		return res(
			ctx.json({ "status": "success" })
		);
	}),
];

export function WillAllowUserSignIn(): boolean {
	return !!sessionStorage.getItem(AllowUserSignIn);
}

export function SetAllowUserSignIn(): void {
	sessionStorage.setItem(AllowUserSignIn, 'true');
}

export function WillWaitDuringUserSignIn(): boolean {
	return !!sessionStorage.getItem(WaitDuringPostSignIn);
}

export function StopWaitingDuringUserSignIn(): void {
	sessionStorage.setItem(WaitDuringPostSignIn, 'true');
}