import { useEffect, useState } from "react";
import useCurrentUserAuth from "./useCurrentUserAuth";

export default function useIsReadyForSubmission(formState: string, showProgressAndSuccess: boolean): boolean {
  const [state, setState] = useState(false);

  const { currentUser } = useCurrentUserAuth();

  useEffect(() => {
    if (formState === 'success' && currentUser && showProgressAndSuccess) {
      setState(true);
    } else {
      setState(false);
    }
  }, [formState, currentUser, showProgressAndSuccess, setState]);
  return state;
}
