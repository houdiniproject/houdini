export default function useIsLoading(submitting: boolean, showProgressAndSuccess: boolean): boolean {
  return (submitting && showProgressAndSuccess);
}