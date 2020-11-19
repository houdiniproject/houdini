// License: LGPL-3.0-or-later
import {createContext, useContext, useEffect, useState} from "react";

/**
 * A context which provides information about the current user and for setting
 * the current user.
 */
export const CurrentUserContext = createContext<{currentUser:CurrentUser|null, setCurrentUser(user:CurrentUser): void}|null>(null);

export interface CurrentUser {
	id: number;
}
/**
 * Information about the current user
 */
export interface UserCurrentUserReturnType {
	/**
	 * The current user signed in. If falsey, there's not current user.
	 *
	 * @type {CurrentUser}
	 * @memberof UserCurrentUserReturnType
	 */
	currentUser?: CurrentUser;
	/**
	 * true if there's a current user, false otherwise.
	 *
	 * @type {boolean}
	 * @memberof UserCurrentUserReturnType
	 */
	signedIn:boolean;
}
/**
 * Pass this type as the TReturnType to useCurrentUser to be able to set the
 * current user. You should only use this in testing or from inside the
 * `useCurrentAuth` hook.
 *
 * @export
 * @interface SetUserReturnType
 * @extends {UserCurrentUserReturnType}
 */
export interface SetCurrentUserReturnType extends UserCurrentUserReturnType {
	/**
	 * Set the current user. YYou should only use this intesting or from
	 * inside the `useCurrentAuth` hook.
	 */
	setCurrentUser(user:CurrentUser): void;
}

/**
 * Get information related to the current user, if any
 *
 * This returns an undocumented hidden setCurrentUser function (see: `SetUserReturnType`).
 * Pass `SetUserReturnType` as the template type if you need this. (This rare
 * and almost only needing for testing or inside the `useCurrentUserAuth` hook)
 *
 * Use this if you need to know whether the currentuser is signed in and who it
 * is but have no interest in logging the user in.
 *
 * @template TReturnType A type extending `UserCurrentUserReturnType`, defaults
 * to `UserCurrentUserReturnType`
 * @returns {TReturnType}
 */
function useCurrentUser<TReturnType extends UserCurrentUserReturnType=UserCurrentUserReturnType>(): TReturnType {
	const {currentUser, setCurrentUser} = useContext(CurrentUserContext);

	const [output, setOutput] = useState<SetCurrentUserReturnType>({
		currentUser,
		setCurrentUser,
		signedIn: !!currentUser,
	});

	useEffect(() => {
		setOutput({
			currentUser,
			setCurrentUser,
			signedIn: !!currentUser,
		});
	}, [currentUser, setOutput, setCurrentUser]);

	return output as unknown as TReturnType;
}

export default useCurrentUser;