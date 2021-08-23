// License: LGPL-3.0-or-later
import {useCallback, useState} from "react";
import useCurrentUser, {CurrentUser, SetCurrentUserReturnType} from "./useCurrentUser";
import {postSignIn} from '../api/users';
import { NetworkError } from "../api/errors";

export interface UseCurrentUserAuthReturnType {
	/**
	 * Reexported from {@link ./useCurrentUser.ts}
	 * @see {@link ./useCurrentUser.ts}
	 * @type {CurrentUser}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	currentUser?: CurrentUser;

	/**
	 * Whether the last finished call to {@link signIn} failed. true if it did,
	 * false otherwise
	 *
	 * @type {boolean}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	failed: boolean;


	/**
	 * The error from the last finished call to getCurrentUser.
	 */
	lastGetCurrentUserError?: ReturnType<typeof useCurrentUser>["error"];

	/**
	 * The {@link SignInError} from the last finished call to {@link signIn}. null
	 * if the last call succeeded.
	 *
	 * @type {SignInError}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	lastSignInAttemptError?: NetworkError;

	/**
	 * Sign in the user with the provided credentials. Promise that results
	 * a {@link CurrentUser} if resolved, throws a {@link SignInError} if failed
	 * @memberof UseCurrentUserAuthReturnType
	 */
	signIn: (credentials:{email:string, password:string}) => Promise<CurrentUser>;

	/**
	 * Reexported from {@link ./useCurrentUser.ts}
	 * @see {@link ./useCurrentUser.ts}
	 * @type {boolean}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	signedIn: ReturnType<typeof useCurrentUser>["signedIn"];

	/**
	 * Whether a signIn is currently being attempted. true if it is, false otherwise
	 *
	 * @type {boolean}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	submitting: boolean;

	/**
	 * Whether the current user is being validated. This could happen after the sign_in call is made
	 * or the timer has decided that the current user
	 */
	validatingCurrentUser: ReturnType<typeof useCurrentUser>["validatingCurrentUser"];
}



/**
 * Sign the in a user, get access to the current user and check whether a signin
 * is occurring. Reexports the `currentUser`, `signedIn`, `validatingCurrentUser` and
 * `error` (as `lastGetCurrentUserError`) properties from `useCurrentUser`.
 *
 * @export
 * @returns {UseCurrentUserAuthReturnType}
 */
export default function useCurrentUserAuth() : UseCurrentUserAuthReturnType {
	const {currentUser,
		signedIn,
		revalidate,
		error:lastGetCurrentUserError,
		validatingCurrentUser} = useCurrentUser<SetCurrentUserReturnType>();
	const [submitting, setSubmitting] = useState(false);
	const [lastSignInAttemptError, setLastSignInAttemptError] = useState<NetworkError|undefined>(undefined);

	const signIn = useCallback(async ({email, password}:{email:string, password:string}): Promise<CurrentUser> => {
		try {
			setSubmitting(true);
			const user = await postSignIn({email, password}) as CurrentUser;
			setLastSignInAttemptError(undefined);
			return user;
		}
		catch(e:unknown) {
			const error = e as NetworkError;
			setLastSignInAttemptError(error);
			throw error;
		}
		finally {
			await revalidate();
			setSubmitting(false);
		}
	}, [setSubmitting, revalidate, setLastSignInAttemptError]);

	return {
		currentUser,
		submitting,
		lastGetCurrentUserError,
		lastSignInAttemptError,
		failed: !!lastSignInAttemptError,
		signedIn,
		signIn,
		validatingCurrentUser,
	};
}