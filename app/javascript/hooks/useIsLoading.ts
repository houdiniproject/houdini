// License: LGPL-3.0-or-later
import { useEffect, useState } from "react";

export default function useIsLoading(submitting: boolean, showProgressAndSuccess: boolean): boolean {
	const [state, setState] = useState(false);

	useEffect(() => {
		if (submitting && showProgressAndSuccess) {
			setState(true);
		} else {
			setState(false);
		}
	}, [submitting, showProgressAndSuccess]);

	return state;
}