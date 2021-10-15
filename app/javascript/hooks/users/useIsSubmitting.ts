// License: LGPL-3.0-or-later

import { useEffect, useState } from "react";

export default function useIsSubmitting(onSubmitting: () => void, isValid: boolean, submitting: boolean): boolean {
	const [state, setState] = useState(false);

	useEffect(() => {
		if (isValid && submitting) {
			setState(true);
			onSubmitting();
		} else {
			setState(false);
		}
	}, [submitting, isValid, onSubmitting]);

	return state;
}