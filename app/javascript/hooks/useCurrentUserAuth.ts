// License: LGPL-3.0-or-later
import {useCallback, useEffect, useState} from "react";
import useCurrentUser, {CurrentUser, SetCurrentUserReturnType} from "./useCurrentUser";
import WebUserSignInOut from '../legacy_react/src/lib/api/sign_in';
import { SignInError } from "../legacy_react/src/lib/api/errors";

interface UseCurrentUserAuthReturnType {
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
	 * The {@link SignInError} from the last finished call to {@link signIn}. null
	 * if the last call succeeded.
	 *
	 * @type {SignInError}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	lastError?: SignInError;

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
	signedIn: boolean;

	/**
	 * Whether a signIn is currently being attempted. true if it is, false otherwise
	 *
	 * @type {boolean}
	 * @memberof UseCurrentUserAuthReturnType
	 */
	submitting: boolean;
}

/**
 * Sign the in a user, get access to the current user and check whether a signin
 * is occurring. Reexports the `currentUser` and `signedIn` properties from `useCurrentUser`
 *
 * @export
 * @returns {UseCurrentUserAuthReturnType}
 */
export default function useCurrentUserAuth() : UseCurrentUserAuthReturnType {
	const {currentUser, signedIn, setCurrentUser} = useCurrentUser<SetCurrentUserReturnType>();
	const [submitting, setSubmitting] = useState(false);
	const [lastError, setLastError] = useState<SignInError|null>(null);
	const [failed, setFailed] = useState<boolean>(false);

	const signIn = useCallback(async ({email, password}:{email:string, password:string}): Promise<CurrentUser> => {
		try {
			setSubmitting(true);
			const user = await WebUserSignInOut.postSignIn({email, password}) as CurrentUser;
			setCurrentUser(user);
			setLastError(null);
			return user;
		}
		catch(e:unknown) {
			const error = e as SignInError;
			setLastError(error);
			throw error;
		}
		finally {
			setSubmitting(false);
		}
	}, [setSubmitting, setCurrentUser, setLastError]);

	useEffect(() => {
		setFailed(!!lastError);
	}, [lastError]);

	return {
		currentUser,
		submitting,
		lastError,
		failed,
		signedIn,
		signIn,
	};
}