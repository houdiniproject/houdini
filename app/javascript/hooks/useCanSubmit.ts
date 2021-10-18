// License: LGPL-3.0-or-later
import { useEffect, useState } from "react";

export default function useCanSubmit(isValid: boolean, showProgressAndSuccess: boolean, isReady: boolean, touched: boolean): boolean {
	const [state, setState] = useState(false);

	useEffect(() => {
		if (isValid && isReady && showProgressAndSuccess && touched) {
			setState(true);
		} else {
			setState(false);
		}
	}, [isValid, showProgressAndSuccess, isReady, touched, setState]);

	return state;
}
