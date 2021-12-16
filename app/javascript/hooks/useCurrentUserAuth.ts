// License: LGPL-3.0-or-later
import { useCallback, useEffect, useReducer, useRef, useState } from "react";
import useCurrentUser, { CurrentUser, SetCurrentUserReturnType } from "./useCurrentUser";
import { postSignIn } from '../api/users';
import { NetworkError } from "../api/errors";
import useMountedState from "react-use/lib/useMountedState";
import { useAsyncFn, usePrevious, useUpdateEffect } from "react-use";
import { AsyncFnReturn } from "react-use/lib/useAsyncFn";

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
	 * a {@link boolean} if resolved, throws a {@link SignInError} if failed
	 * @memberof UseCurrentUserAuthReturnType
	 */
	signIn: (credentials: { email: string, password: string }) => Promise<boolean>;

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

interface CurrentAuthState {
	readonly lastSignInAttemptError?: NetworkError | undefined;
	readonly submitting: boolean;
}


type CurrentAuthStateAction = {
	type: 'beginSubmit';
} | {
	type: 'endSubmit';
} |
{
	lastSignInAttemptError?: NetworkError | undefined;
	type: 'setLastError';
};

function currentUserAuthReducer(state: CurrentAuthState, args: CurrentAuthStateAction): CurrentAuthState {
	switch (args.type) {
		case 'beginSubmit': {
			return { ...state, submitting: true };
		}
		case 'endSubmit':
			return { ...state, submitting: false };
		case 'setLastError':
		{
			return { ...state, lastSignInAttemptError: args.lastSignInAttemptError };
		}
	}
}

function usePostSignIn(revalidate: () => Promise<CurrentUser>): [{error?:Error, loading:boolean}, (props: {
	email: string;
	password: string;
}) => Promise<boolean>] {
	const lastCallId = useRef(0);
	const isMounted = useMountedState();
	const [{loading, error}, runPostSignIn] = useAsyncFn(async(props:{
		email: string;
		password: string;
	}) => {
		const callId = ++lastCallId.current;
		try {
			return await postSignIn(props);
		}
		finally {
			isMounted() && callId === lastCallId.current &&	await revalidate();
		}
	}, [revalidate]);




	// const [{loading, value, error}, runSignIn] = useAsyncFn(async (props:{email:string, password:string}) => {
	// 	try {
	// 		return await runPostSignInRef.current(props);
	// 	}
	// 	finally {
	// 		await runRevalidateRef.current();
	// 	}
	// }, [runRevalidateRef, runPostSignInRef]);

	// const runSignInRef = useRef(runSignIn);
	// runSignInRef.current = runSignIn;

	// const [output, setOutput] = useState<[{error?:Error, loading:boolean, value?:boolean}, (props: {
	// 	email: string;
	// 	password: string;
	// }) => Promise<boolean>]>([{loading, value, error}, runSignIn]);
	// useEffect(() => {
	// 	setOutput([{loading, value, error}, runSignInRef.current]);
	// }, [loading, value, error, runSignInRef]);

	return [{loading, error}, runPostSignIn ];
}

/**
 * Sign the in a user, get access to the current user and check whether a signin
 * is occurring. Reexports the `currentUser`, `signedIn`, `validatingCurrentUser` and
 * `error` (as `lastGetCurrentUserError`) properties from `useCurrentUser`.
 *
 * @export
 * @returns {UseCurrentUserAuthReturnType}
 */
export default function useCurrentUserAuth(): UseCurrentUserAuthReturnType {
	const { currentUser,
		signedIn,
		revalidate,
		error: lastGetCurrentUserError,
		validatingCurrentUser } = useCurrentUser<SetCurrentUserReturnType>();

	const [{ loading: submitting, error: lastSignInAttemptError }, signIn] = usePostSignIn(revalidate);

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