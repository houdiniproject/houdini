// License: LGPL-3.0-or-later
import { createContext, useContext } from "react";
import useSWR from "swr";
import { getCurrent, NotLoggedInStatus } from "../api/api/users";
import users from "../routes/api/users";
export {NotLoggedInStatus} from '../api/api/users';

/**
 * A context which provides information about the current user and for setting
 * the current user.
 */
export const InitialCurrentUserContext = createContext< CurrentUser | null>(null);



export interface CurrentUser {
	id: number;
}
/**
 * Information about the current user
 */
export interface UseCurrentUserReturnType {
	/**
	 * The current user signed in. If falsey, there's no current user.
	 *
	 * @type {CurrentUser}
	 * @memberof UserCurrentUserReturnType
	 */
	currentUser?: CurrentUser;

	error: unknown;

	/**
	 * true if there's a current user, false otherwise.
	 *
	 * @type {boolean}
	 * @memberof UserCurrentUserReturnType
	 */
	signedIn: boolean;

	validatingCurrentUser: boolean;
}
/**
 * Pass this type as the TReturnType to useCurrentUser to be able to set the
 * current user. You should only use this in testing or from inside the
 * `useCurrentAuth` hook.
 *
 * @export
 * @interface SetUserReturnType
 * @extends {UseCurrentUserReturnType}
 */
export interface SetCurrentUserReturnType extends UseCurrentUserReturnType {
	/**
	 * Set the current user. YYou should only use this intesting or from
	 * inside the `useCurrentAuth` hook.
	 */
	revalidate(): Promise<CurrentUser>;
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
function useCurrentUser<TReturnType extends UseCurrentUserReturnType = UseCurrentUserReturnType>(): TReturnType {
	const initialCurrentUser = useContext(InitialCurrentUserContext);

	const { data, mutate, error, isValidating:validatingCurrentUser } = useSWR(users.apiUsersCurrent.url(), getCurrent, { fallbackData: initialCurrentUser });
	const currentUser = error?.status === NotLoggedInStatus ? null : data;

	async function revalidate() {
		return mutate();
	}
	const output: SetCurrentUserReturnType = {
		currentUser,
		revalidate,
		signedIn: !!currentUser,
		error,
		validatingCurrentUser,
	};

	return output as unknown as TReturnType;
}

export default useCurrentUser;