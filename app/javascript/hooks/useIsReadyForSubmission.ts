// License: LGPL-3.0-or-later
export default function useIsReadyForSubmission(isValid: boolean, showProgressAndSuccess: boolean, formState: string): boolean {
	return !(!isValid || !showProgressAndSuccess && !(formState === 'canSubmit'));
}
