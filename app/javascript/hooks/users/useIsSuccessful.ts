// License: LGPL-3.0-or-later

import { useEffect, useState } from "react";
import useCurrentUserAuth from "../useCurrentUserAuth";

export default function useIsSuccessful(showProgressAndSuccess: boolean, onSuccess: () => void): boolean {
	const [state, setState] = useState(false);

	const { currentUser } = useCurrentUserAuth();

	useEffect(() => {
		if (currentUser && showProgressAndSuccess) {
			setState(true);
			onSuccess();
		} else {
			setState(false);
		}
	}, [currentUser, showProgressAndSuccess, onSuccess, setState]);

	return state;
}
