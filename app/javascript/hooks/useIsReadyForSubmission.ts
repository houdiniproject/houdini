export default function useIsReadyForSubmission(isValid: boolean, showProgressAndSuccess: boolean, canSubmit: boolean): boolean {
  return !(!isValid || !showProgressAndSuccess && !canSubmit);
}
