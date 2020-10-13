// License: LGPL-3.0-or-later
import React, {PropsWithChildren, useEffect, useState} from 'react';
import { CurrentUserContext } from '../../hooks/useCurrentUser';

interface MockCurrentUserProviderProps {
	/**
	 * The userId of the currentUser when initializing, if userId is falsy,
	 * currentUser is null.
	 *
	 * This field only updates the currentUser on initialization. If you update
	 * this after your component is initialized, no change will occur. This is
	 * normally good.
	 *
	 * To override this behavior, set updateAfterInitialize to true
	 *
	 * @type {number}
	 * @memberof MockCurrentUserProviderProps
	 */
	initialUserId?:number;

	/**
	 * Whether to update the currentUser with the provided initialUserId after
	 * initialization. true if you want to, otherwise false. Defaults to false.
	 *
	 * @type {boolean}
	 * @memberof MockCurrentUserProviderProps
	 */
	updateAfterInitialize:boolean;
}

/**
 * Provides the context needed for useCurrentUser as well as for providing new
 * user information during a test.
 *
 * @export
 * @param {PropsWithChildren<MockCurrentUserProviderProps>} props
 * @returns {JSX.Element}
 */
export default function MockCurrentUserProvider(props:PropsWithChildren<MockCurrentUserProviderProps>) : JSX.Element {
	const userFromProps = props.initialUserId ? {id: props.initialUserId} : null;
	const [currentUser, setCurrentUser] = useState(userFromProps);
	const [alreadyInitialized, setAlreadyInitialized] = useState(false);
	useEffect(() => {
		if (!alreadyInitialized || props.updateAfterInitialize) {
			setCurrentUser(userFromProps);
		}
		if (!alreadyInitialized) {
			setAlreadyInitialized(true);
		}
	}, [props.initialUserId, props.updateAfterInitialize, alreadyInitialized]);

	const values = {currentUser, setCurrentUser};
	return (<CurrentUserContext.Provider value={values}>
		{props.children}
	</CurrentUserContext.Provider>);
}

MockCurrentUserProvider.defaultProps = {
	updateAfterInitialize:false,
};