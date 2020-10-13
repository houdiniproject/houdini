// License: LGPL-3.0-or-later
import {useState} from "react";
import useCurrentUser, {CurrentUser, SetCurrentUserReturnType} from "./useCurrentUser";
import WebUserSignInOut, {SignInError} from '../legacy_react/src/lib/api/sign_in';

interface UseCurrentUserAuthReturnType {
	currentUser?: CurrentUser;
	lastError?: SignInError;
	signIn: (credentials:{email:string, password:string}) => Promise<CurrentUser>;
	signedIn: boolean;
	submitting: boolean;
}

export default function useCurrentUserAuth() : UseCurrentUserAuthReturnType {
	const {currentUser, signedIn, setCurrentUser} = useCurrentUser<SetCurrentUserReturnType>();
	const [submitting, setSubmitting] = useState(false);
	const [lastError, setLastError] = useState<SignInError|null>(null);

	const [webUserSignInOut] = useState(WebUserSignInOut());

	async function signIn({email, password}:{email:string, password:string}): Promise<CurrentUser> {
		try {
			setSubmitting(true);
			const user = await webUserSignInOut.postLogin({email, password}) as CurrentUser;
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
	}

	return {
		currentUser,
		submitting,
		lastError,
		signedIn,
		signIn,
	};
}